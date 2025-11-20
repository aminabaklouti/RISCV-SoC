library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RISCV_R is
    generic (
        dataWidth  : integer := 32;
        addrWidth  : integer := 8;               -- PC en octets (2 bits LSB ignorés pour indexer les mots)
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

    signal src1       : std_logic_vector(dataWidth-1 downto 0);
    signal src2       : std_logic_vector(dataWidth-1 downto 0);
    signal result     : std_logic_vector(dataWidth-1 downto 0);
    signal writeData  : std_logic_vector(dataWidth-1 downto 0);
    signal rdWrite    : std_logic;

    --------------------------------------------------------------------
    -- PC & IMEM
    --------------------------------------------------------------------
    signal pc_val     : std_logic_vector(addrWidth-1 downto 0);
    signal pc_in      : std_logic_vector(addrWidth-1 downto 0);
    signal pc_load    : std_logic;
    signal imem_addr  : std_logic_vector(addrWidth-3 downto 0);  -- addrWidth-2 bits

    --------------------------------------------------------------------
    -- ALU, Imm, contrôle
    --------------------------------------------------------------------
    signal aluOp      : std_logic_vector(aluOpWidth-1 downto 0);
    signal instType   : std_logic_vector(2 downto 0);
    signal RI_sel     : std_logic;  -- 1 = instructions I
    signal load       : std_logic;  -- 1 = lw
    signal wrMem      : std_logic;  -- 1 = sw
    signal immExt     : std_logic_vector(dataWidth-1 downto 0);
    signal opB        : std_logic_vector(dataWidth-1 downto 0);

    --------------------------------------------------------------------
    -- DMEM
    --------------------------------------------------------------------
    signal dmem_addr      : std_logic_vector(addrWidth-3 downto 0);  -- même largeur que imem_addr
    signal dmem_data_out  : std_logic_vector(dataWidth-1 downto 0);

begin
    --------------------------------------------------------------------
    -- PC / 4 pour IMEM : PC en octets -> index de mot
    --------------------------------------------------------------------
    imem_addr <= pc_val(addrWidth-1 downto 2);

    -- Ici tu fixes pc_in/pc_load, en supposant que ton PC interne s'auto-incrémente.
    -- Si ton composant pc a une logique "PC+4" interne, c'est ok.
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
    -- Register File
    --------------------------------------------------------------------
    rdWrite <= '1';  -- pour l'instant on écrit toujours (à affiner éventuellement)

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
    -- Immédiat
    --------------------------------------------------------------------
    imm_ext_1 : entity work.Imm_ext
        generic map ( dataWidth => dataWidth )
        port map (
            instr    => instr,
            instType => instType,
            immExt   => immExt
        );

    --------------------------------------------------------------------
    -- MUX ALU Operand B
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
    -- DMEM : adresse = résultat ALU (en octets) >> 2 = index de mot
    --------------------------------------------------------------------
    dmem_addr <= result(addrWidth-1 downto 2);  -- on enlève les 2 LSB

    dmem_1 : entity work.dmem
        generic map (
            DATA_WIDTH => dataWidth,
            ADDR_WIDTH => addrWidth-2        -- même logique que IMEM : index de mot
        )
        port map (
            clk      => clk,
            addr     => dmem_addr,
            data_in  => src2,               -- sw : rs2
            we       => wrMem,
            data_out => dmem_data_out
        );

    --------------------------------------------------------------------
    -- MUX final : résultat ALU OU données mémoire (lw)
    --------------------------------------------------------------------
    mux_load : entity work.mux2
        generic map ( dataWidth => dataWidth )
        port map (
            d0  => result,
            d1  => dmem_data_out,
            sel => load,
            y   => writeData
        );

    --------------------------------------------------------------------
    -- Décodeur étendu (R + I + LOAD, et plus tard STORE)
    --------------------------------------------------------------------
    dec_1 : entity work.ir_dec_r
        generic map (
            dataWidth  => dataWidth,
            aluOpWidth => aluOpWidth
        )
        port map (
            instr    => instr,
            aluOp    => aluOp,
            RI_sel   => RI_sel,
            instType => instType,
            load     => load,
            wrMem    => wrMem,
            clk      => clk,
            reset    => reset
        );

end architecture behav;
