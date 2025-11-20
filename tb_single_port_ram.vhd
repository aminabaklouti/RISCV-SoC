library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_single_port_ram is
end entity;

architecture behav of tb_single_port_ram is

    component single_port_ram is
        generic (
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 3
        );
        port (
            clk  : in std_logic;
            addr : in natural range 0 to 2**ADDR_WIDTH - 1;
            data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            we   : in std_logic := '1';
            q    : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    constant CLK_HALF : time := 5 ns;

    signal clk_t  : std_logic := '0';
    signal addr_t : natural range 0 to 7 := 0;
    signal data_t : std_logic_vector(31 downto 0) := (others => '0');
    signal we_t   : std_logic := '0';
    signal q_t    : std_logic_vector(31 downto 0);

begin

    -- Instanciation de la RAM
    ram_1 : single_port_ram
        generic map (
            DATA_WIDTH => 32,
            ADDR_WIDTH => 3
        )
        port map (
            clk  => clk_t,
            addr => addr_t,
            data => data_t,
            we   => we_t,
            q    => q_t
        );

    -- Horloge
    clk_t <= not clk_t after CLK_HALF;

    stim_proc : process
    begin
	 
		wait for 20 ns;
        ----------------------------------------------------------------
        -- 1) LECTURE INITIALE : lire les 8 mots dans l'ordre croissant
        ----------------------------------------------------------------
        we_t <= '0';
        for i in 0 to 7 loop
            addr_t <= i;
            wait for 20 ns;  -- on laisse le temps de voir q_t changer
        end loop;

        ----------------------------------------------------------------
        -- 2) ECRITURE : RAM[i] <- 7 - i
        ----------------------------------------------------------------
        we_t <= '1';
        for i in 0 to 7 loop
            addr_t <= i;
            data_t <= std_logic_vector(to_unsigned(7 - i, 32));
            wait for 10 ns;  -- un cycle d'horloge -> écriture sur front montant
        end loop;

        ----------------------------------------------------------------
        -- 3) LECTURE APRES ECRITURE : lire à nouveau les 8 mots
        ----------------------------------------------------------------
        we_t <= '0';
        for i in 0 to 7 loop
            addr_t <= i;
            wait for 20 ns;
        end loop;

        wait;
    end process;

end architecture behav;
