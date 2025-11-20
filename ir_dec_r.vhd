library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ir_dec_r is
    generic (
        dataWidth  : integer := 32;
        aluOpWidth : integer := 4
    );
    port (
        instr    : in  std_logic_vector(dataWidth-1 downto 0);

        -- sorties vers ALU & datapath
        aluOp    : out std_logic_vector(aluOpWidth-1 downto 0);
        RI_sel   : out std_logic;                 -- 1 = opB = imm
        instType : out std_logic_vector(2 downto 0);

        -- LOAD / STORE / MEM
        load     : out std_logic;                -- 1 = lw
        wrMem    : out std_logic;                -- 1 = sw (pour plus tard)

        clk      : in  std_logic;
        reset    : in  std_logic
    );
end entity ir_dec_r;


architecture behav of ir_dec_r is

    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);

begin

    opcode <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);

    ------------------------------------------------------------------
    -- PUREMENT COMBINATOIRE : pas de clk/reset dans le process
    ------------------------------------------------------------------
    process(opcode, funct3, funct7)
    begin
        -- valeurs par défaut
        RI_sel   <= '0';
        load     <= '0';
        wrMem    <= '0';
        aluOp    <= (others => '0');
        instType <= "000";

        --------------------------------
        -- TYPE R : opcode = 0110011
        --------------------------------
        if opcode = "0110011" then
            instType <= "000";   -- type R
            RI_sel   <= '0';     -- opB = rs2
            load     <= '0';
            wrMem    <= '0';

            case funct3 is
                when "000" =>
                    if funct7 = "0000000" then
                        aluOp <= "0000";     -- ADD
                    else
                        aluOp <= "0001";     -- SUB
                    end if;
                when "111" => aluOp <= "0010";   -- AND
                when "110" => aluOp <= "0011";   -- OR
                when "100" => aluOp <= "0100";   -- XOR
                when "001" => aluOp <= "0101";   -- SLL
                when "101" =>
                    if funct7 = "0000000" then
                        aluOp <= "0110";   -- SRL
                    else
                        aluOp <= "0111";   -- SRA
                    end if;
                when "010" => aluOp <= "1000";   -- SLT
                when "011" => aluOp <= "1001";   -- SLTU
                when others =>
                    aluOp <= (others => '0');
            end case;

        --------------------------------
        -- TYPE I arithmétique : opcode = 0010011
        --------------------------------
        elsif opcode = "0010011" then
            instType <= "001";   -- type I
            RI_sel   <= '1';     -- opB = imm
            load     <= '0';
            wrMem    <= '0';

            case funct3 is
                when "000" => aluOp <= "0000";   -- ADDI
                when "111" => aluOp <= "0010";   -- ANDI
                when "110" => aluOp <= "0011";   -- ORI
                when "100" => aluOp <= "0100";   -- XORI
                when "001" => aluOp <= "0101";   -- SLLI
                when "101" =>
                    -- SRLI / SRAI -> on pourrait regarder instr(30)
                    aluOp <= "0110";            -- simplification : SRL
                when "010" => aluOp <= "1000";   -- SLTI
                when "011" => aluOp <= "1001";   -- SLTIU
                when others =>
                    aluOp <= (others => '0');
            end case;

        --------------------------------
        -- TYPE LOAD (lw) : opcode = 0000011
        --------------------------------
        elsif opcode = "0000011" then
            instType <= "010";    -- type LOAD
            RI_sel   <= '1';      -- opB = imm
            load     <= '1';      -- on prendra DMEM en sortie
            wrMem    <= '0';      -- pas d'écriture mémoire

            -- lw : adresse = rs1 + imm -> ALU = ADD
            aluOp <= "0000";      -- code ADD dans notre ALU

        end if;
    end process;

end architecture behav;
