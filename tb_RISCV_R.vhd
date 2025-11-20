library ieee;
use ieee.std_logic_1164.all;

entity tb_RISCV_R is
end entity tb_RISCV_R;

architecture behav of tb_RISCV_R is

    constant DATA_WIDTH_C : integer := 32;
    constant ADDR_WIDTH_C : integer := 8;
    constant MEM_DEPTH_C  : integer := 100;

    constant CLK_PERIOD   : time := 10 ns;

    signal clk_t   : std_logic := '0';
    signal reset_t : std_logic := '0';

begin

    --------------------------------------------------------------------
    -- Génération de l'horloge
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk_t <= '0';
            wait for CLK_PERIOD/2;
            clk_t <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    --------------------------------------------------------------------
    -- DUT : processeur RISC-V
    --------------------------------------------------------------------
    dut : entity work.RISCV_R
        generic map (
            dataWidth  => DATA_WIDTH_C,
            addrWidth  => ADDR_WIDTH_C,
            memDepth   => MEM_DEPTH_C,
            memoryFile => "load_03.hex"
        )
        port map (
            clk   => clk_t,
            reset => reset_t
        );

    --------------------------------------------------------------------
    -- Stimuli : reset puis laisser tourner
    --------------------------------------------------------------------
    stim_proc : process
    begin
        -- reset actif pendant quelques cycles
        reset_t <= '1';
        wait for 5*CLK_PERIOD;

        -- relâcher le reset
        reset_t <= '0';

        -- laisser le CPU exécuter des instructions
        wait for 600 ns;

        -- fin de la simu
        wait;
    end process;

end architecture behav;
