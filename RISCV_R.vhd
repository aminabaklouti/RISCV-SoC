library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RISCV_R is
    generic (
        dataWidth  : integer := 32;
        addrWidth  : integer := 8;               -- PC en octets
        memDepth   : integer := 100;             -- nb d'instructions dans l'IMEM
        memoryFile : string  := "file.hex"
    );
    port (
        clk   : in std_logic;
        reset : in std_logic
    );
end entity RISCV_R;

architecture behav of RISCV_R is

    constant aluOpWidth : integer := 4;

    --------------------------------------------------------------------
    -- Instruction & registres
    --------------------------------------------------------------------
    signal instr      : std_logic_vector(dataWidth-1 downto 0);
    alias  rs1        : std_logic_vector(4 downto 0) is instr(19 downto 15);
    alias  rs2        : std_logic_vector(4 downto 0) is instr(24 downto 20);
    alias  rd         : std_logic_vector(4 downto 0) is instr(11 downto 7);
    alias  funct3     : std_logic_vector(2 downto 0) is instr(14 downto 12);

    signal src1       : std_logic_vector(dataWidth-1 downto 0);
    signal src2       : std_logic_vector(dataWidth-1 downto 0);
    signal result     : std_logic_vector(dataWidth-1 downto 0);
    signal writeData  : std_logic_vector(dataWidth-1 downto 0);
    signal rdWrite    : std_logic;   -- piloté par le décodeur

    --------------------------------------------------------------------
    -- PC & IMEM
    --------------------------------------------------------------------
    signal pc_val     : std_logic_vector(addrWidth-1 downto 0);
    signal pc_in      : std_logic_vector(addrWidth-1 downto 0);
    signal pc_load    : std_logic;
    signal imem_addr  : std_logic_vector(addrWidth-3 downto 0);  -- index de mot

    --------------------------------------------------------------------
    -- ALU, Imm, contrôle
    --------------------------------------------------------------------
    signal aluOp      : std_logic_vector(aluOpWidth-1 downto 0);
    signal instType   : std_logic_vector(2 downto 0);
    signal RI_sel     : std_logic;  -- 1 = opB = imm
    signal load       : std_logic;  -- 1 = load
    signal wrMem      : std_logic;  -- 1 = store
    signal immExt     : std_logic_vector(dataWidth-1 downto 0);
    signal opB        : std_logic_vector(dataWidth-1 downto 0);

    --------------------------------------------------------------------
    -- DMEM + SM + LM
    --------------------------------------------------------------------
    signal dmem_addr      : std_logic_vector(addrWidth-3 downto 0);
    signal dmem_data_out  : std_logic_vector(dataWidth-1 downto 0);
    signal sm_data_out    : std_logic_vector(dataWidth-1 downto 0); -- vers dmem
    signal addr_lsb       : std_logic_vector(1 downto 0);            -- res(1:0)
    signal lm_data_out    : std_logic_vector(dataWidth-1 downto 0);  -- vers registres

begin
    --------------------------------------------------------------------
    -- PC / 4 pour IMEM : PC en octets -> index de mot
    --------------------------------------------------------------------
    imem_addr <= pc_val(addrWidth-1 downto 2);

    pc_in   <= (others => '0');
    pc_load <= '0';

    pc_1 : entity work.pc
        generic map ( ADDR_WIDTH => addrWidth )
        port map (
            din   => pc_in,
            clk   => clk,
            load  => pc_load,
            reset => reset,
            dout  => pc_val
        );

    --------------------------------------------------------------------
    -- IMEM
    --------------------------------------------------------------------
    imem_1 : entity work.imem
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => addrWidth-2,  -- index de mot
            MEM_DEPTH  => memDepth,
            INIT_FILE  => memoryFile
        )
        port map (
            address  => imem_addr,
            Data_Out => instr
        );

    --------------------------------------------------------------------
    -- Register File (écriture pilotée par le décodeur)
    --------------------------------------------------------------------
    regs_1 : entity work.reg
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => 5
        )
        port map (
            clk   => clk,
            reset => reset,
            WE    => rdWrite,
            rw    => rd,
            rs1   => rs1,
            rs2   => rs2,
            busW  => writeData,
            busA  => src1,
            busB  => src2
        );

    --------------------------------------------------------------------
    -- Immédiat (I + LOAD + STORE)
    --------------------------------------------------------------------
    imm_ext_1 : entity work.Imm_ext
        generic map ( dataWidth => dataWidth )
        port map (
            instr    => instr,
            instType => instType,
            immExt   => immExt
        );

    --------------------------------------------------------------------
    -- MUX ALU Operand B (registre ou immédiat)
    --------------------------------------------------------------------
    mux_opB : entity work.mux2
        generic map ( dataWidth => dataWidth )
        port map (
            d0  => src2,
            d1  => immExt,
            sel => RI_sel,
            y   => opB
        );

    --------------------------------------------------------------------
    -- ALU
    --------------------------------------------------------------------
    alu_1 : entity work.alu
        generic map (
            dataWidth  => dataWidth,
            aluOpWidth => aluOpWidth
        )
        port map (
            opA   => src1,
            opB   => opB,
            aluOp => aluOp,
            res   => result
        );

    --------------------------------------------------------------------
    -- DMEM + SM (stores)
    --------------------------------------------------------------------
    -- adresse mémoire (mot) et 2 bits LSB (offset pour SM/LM)
    dmem_addr <= result(addrWidth-1 downto 2);
    addr_lsb  <= result(1 downto 0);

    -- SM : choisit l’octet / demi-mot à écrire (sb/sh/sw)
    sm_1 : entity work.SM
        port map (
            funct3   => funct3,        -- 000=sb, 001=sh, 010=sw
            addr_lsb => addr_lsb,      -- res(1:0)
            data_in  => src2,          -- valeur à stocker (rs2)
            q        => dmem_data_out, -- ancienne valeur mémoire
            data_out => sm_data_out    -- mot complet à écrire
        );

    dmem_1 : entity work.dmem
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => addrWidth-2
        )
        port map (
            clk      => clk,
            addr     => dmem_addr,
            data_in  => sm_data_out,   -- écriture via SM
            we       => wrMem,
            data_out => dmem_data_out
        );

    --------------------------------------------------------------------
    -- LM : post-traitement des loads (lb/lbu/lh/lhu/lw)
    --------------------------------------------------------------------
    lm_1 : entity work.LM
        port map (
            funct3   => funct3,        -- instr(14 downto 12)
            addr_lsb => addr_lsb,      -- result(1 downto 0)
            data_in  => dmem_data_out, -- mot lu en DMEM
            data_out => lm_data_out    -- valeur 32 bits pour rd
        );

    --------------------------------------------------------------------
    -- MUX final : résultat ALU OU données mémoire (load)
    --------------------------------------------------------------------
    mux_load : entity work.mux2
        generic map ( dataWidth => dataWidth )
        port map (
            d0  => result,
            d1  => lm_data_out,   -- chemin mémoire via LM
            sel => load,
            y   => writeData
        );

    --------------------------------------------------------------------
    -- Décodeur : R + I + LOAD + STORE
    --------------------------------------------------------------------
    dec_1 : entity work.ir_dec_r
        generic map (
            dataWidth  => dataWidth,
            aluOpWidth => aluOpWidth
        )
        port map (
            instr       => instr,
            aluOp       => aluOp,
            RI_sel      => RI_sel,
            instType    => instType,
            load        => load,
            wrMem       => wrMem,
            writeEnable => rdWrite,
            clk         => clk,
            reset       => reset
        );

end architecture behav;
