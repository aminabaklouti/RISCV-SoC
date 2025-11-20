library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is
end entity tb_alu;

architecture behav of tb_alu is

    constant DATA_WIDTH_C : integer := 32;

    signal opA_t   : std_logic_vector(DATA_WIDTH_C-1 downto 0) := (others => '0');
    signal opB_t   : std_logic_vector(DATA_WIDTH_C-1 downto 0) := (others => '0');
    signal aluOp_t : std_logic_vector(3 downto 0) := (others => '0');
    signal res_t   : std_logic_vector(DATA_WIDTH_C-1 downto 0);

begin

    -- Instanciation directe de l'entité alu
    dut : entity work.alu
        port map (
            opA   => opA_t,
            opB   => opB_t,
            aluOp => aluOp_t,
            res   => res_t
        );

    stim_proc : process
    begin
        ------------------------------------------------
        -- 0000 : ADD : 10 + 5 = 15
        ------------------------------------------------
        opA_t   <= std_logic_vector(to_signed(10, DATA_WIDTH_C));
        opB_t   <= std_logic_vector(to_signed(5,  DATA_WIDTH_C));
        aluOp_t <= "0000";
        wait for 20 ns;

        ------------------------------------------------
        -- 0001 : SUB : 10 - 20 = -10
        ------------------------------------------------
        opA_t   <= std_logic_vector(to_signed(10, DATA_WIDTH_C));
        opB_t   <= std_logic_vector(to_signed(20, DATA_WIDTH_C));
        aluOp_t <= "0001";
        wait for 20 ns;

        ------------------------------------------------
        -- 0010 : AND
        ------------------------------------------------
        opA_t   <= x"00000F0F";
        opB_t   <= x"000000FF";
        aluOp_t <= "0010";
        wait for 20 ns;

        ------------------------------------------------
        -- 0011 : OR
        ------------------------------------------------
        opA_t   <= x"00000F00";
        opB_t   <= x"000000F0";
        aluOp_t <= "0011";
        wait for 20 ns;

        ------------------------------------------------
        -- 0100 : XOR
        ------------------------------------------------
        opA_t   <= x"00000FF0";
        opB_t   <= x"000000F0";
        aluOp_t <= "0100";
        wait for 20 ns;

        ------------------------------------------------
        -- 0101 : SLL : 1 << 4
        ------------------------------------------------
        opA_t   <= x"00000001";
        opB_t   <= x"00000004";  -- shamt = 4
        aluOp_t <= "0101";
        wait for 20 ns;

        ------------------------------------------------
        -- 0110 : SRL
        ------------------------------------------------
        opA_t   <= x"00000080";
        opB_t   <= x"00000003";  -- shamt = 3
        aluOp_t <= "0110";
        wait for 20 ns;

        ------------------------------------------------
        -- 0111 : SRA
        ------------------------------------------------
        opA_t   <= x"FFFFFF80";  -- -128 en signé
        opB_t   <= x"00000003";  -- shamt = 3
        aluOp_t <= "0111";
        wait for 20 ns;

        ------------------------------------------------
        -- 1000 : SLT (signed)
        ------------------------------------------------
        opA_t   <= std_logic_vector(to_signed(-5, DATA_WIDTH_C));
        opB_t   <= std_logic_vector(to_signed(3,  DATA_WIDTH_C));
        aluOp_t <= "1000";
        wait for 20 ns;

        ------------------------------------------------
        -- 1001 : SLTU (unsigned)
        ------------------------------------------------
        opA_t   <= x"FFFFFFF0";
        opB_t   <= x"00000010";
        aluOp_t <= "1001";
        wait for 20 ns;

        wait;
    end process;

end architecture behav;
