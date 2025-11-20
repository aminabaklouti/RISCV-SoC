library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reg is
end entity tb_reg;

architecture behav of tb_reg is

    constant DATA_WIDTH_C : natural := 32;
    constant ADDR_WIDTH_C : natural := 5;    -- 32 registres

    signal clk_t   : std_logic := '0';
    signal reset_t : std_logic := '0';
    signal we_t    : std_logic := '0';
    signal rw_t    : std_logic_vector(ADDR_WIDTH_C-1 downto 0) := (others => '0'); -- RW
    signal rs1_t   : std_logic_vector(ADDR_WIDTH_C-1 downto 0) := (others => '0'); -- RA
    signal rs2_t   : std_logic_vector(ADDR_WIDTH_C-1 downto 0) := (others => '0'); -- RB
    signal busW_t  : std_logic_vector(DATA_WIDTH_C-1 downto 0) := (others => '0');
    signal busA_t  : std_logic_vector(DATA_WIDTH_C-1 downto 0);
    signal busB_t  : std_logic_vector(DATA_WIDTH_C-1 downto 0);

    constant CLK_HALF : time := 5 ns;

begin

    -- Horloge
    clk_t <= not clk_t after CLK_HALF;

    -- Instanciation du banc de registres
    reg_1 : entity work.reg
        generic map (
            DATA_WIDTH => DATA_WIDTH_C,
            ADDR_WIDTH => ADDR_WIDTH_C
        )
        port map (
            clk   => clk_t,
            reset => reset_t,
            we    => we_t,
            rw    => rw_t,
            rs1   => rs1_t,
            rs2   => rs2_t,
            busW  => busW_t,
            busA  => busA_t,
            busB  => busB_t
        );

    stim_proc : process
    begin
        ------------------------------------------------
        -- RESET
        ------------------------------------------------
        reset_t <= '1';
        wait for 20 ns;
        reset_t <= '0';

        ------------------------------------------------
        -- PHASE 1 : ECRITURE (31 - numéro_reg) dans Rx_i
        ------------------------------------------------
        we_t <= '1';
        for i in 0 to 31 loop
            rw_t   <= std_logic_vector(to_unsigned(i, ADDR_WIDTH_C));
            busW_t <= std_logic_vector(to_unsigned(31 - i, DATA_WIDTH_C));
            wait for 10 ns;               -- un cycle d'horloge
        end loop;
        we_t <= '0';

        ------------------------------------------------
        -- PHASE 2 : LECTURE 2 PAR 2
        -- (x0,x15), (x1,x14), (x2,x13), ...
        ------------------------------------------------
        for i in 0 to 15 loop
            rs1_t <= std_logic_vector(to_unsigned(i, ADDR_WIDTH_C));          -- RA = i
            rs2_t <= std_logic_vector(to_unsigned(31 - i, ADDR_WIDTH_C));     -- RB = 31 - i
            wait for 20 ns;   -- laisser le temps de voir busA_t / busB_t dans la wave
        end loop;

        wait;
    end process;

end architecture behav;
