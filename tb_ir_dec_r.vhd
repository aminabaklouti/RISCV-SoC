library ieee;
use ieee.std_logic_1164.all;

entity tb_ir_dec_r is
end entity tb_ir_dec_r;

architecture behav of tb_ir_dec_r is

    constant DATA_WIDTH_C  : integer := 32;
    constant ALUOP_WIDTH_C : integer := 4;

    signal instr_t : std_logic_vector(DATA_WIDTH_C-1 downto 0) := (others => '0');
    signal aluOp_t : std_logic_vector(ALUOP_WIDTH_C-1 downto 0);

    signal clk_t   : std_logic := '0';
    signal reset_t : std_logic := '0';

    constant CLK_HALF : time := 5 ns;

begin

    -- horloge (pas vraiment utilisée par ir_dec_r, mais on la met pour être propre)
    clk_t <= not clk_t after CLK_HALF;

    -- instanciation du décodeur
    dut : entity work.ir_dec_r
        generic map (
            dataWidth  => DATA_WIDTH_C,
            aluOpWidth => ALUOP_WIDTH_C
        )
        port map (
            instr => instr_t,
            aluOp => aluOp_t,
            clk   => clk_t,
            reset => reset_t
        );

    stim_proc : process
    begin
        -------------------------------------------------
        -- ADD : funct7=0000000, funct3=000, opcode=0110011
        -------------------------------------------------
        -- instr = [funct7][rs2][rs1][funct3][rd][opcode]
        instr_t <= "0000000" & "00010" & "00001" & "000" & "00000" & "0110011";
        wait for 20 ns;

        -------------------------------------------------
        -- SUB : funct7=0100000, funct3=000
        -------------------------------------------------
        instr_t <= "0100000" & "00010" & "00001" & "000" & "00000" & "0110011";
        wait for 20 ns;

        -------------------------------------------------
        -- AND : funct7=0000000, funct3=111
        -------------------------------------------------
        instr_t <= "0000000" & "00010" & "00001" & "111" & "00000" & "0110011";
        wait for 20 ns;

        -------------------------------------------------
        -- OR : funct7=0000000, funct3=110
        -------------------------------------------------
        instr_t <= "0000000" & "00010" & "00001" & "110" & "00000" & "0110011";
        wait for 20 ns;

        -------------------------------------------------
        -- XOR : funct7=0000000, funct3=100
        -------------------------------------------------
        instr_t <= "0000000" & "00010" & "00001" & "100" & "00000" & "0110011";
        wait for 20 ns;

        wait;
    end process;

end architecture behav;
