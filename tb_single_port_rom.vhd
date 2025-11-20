library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_single_port_rom is
end entity;

architecture rtl of tb_single_port_rom is

    component single_port_rom
        generic(
            DATA_WIDTH : natural := 8;
            ADDR_WIDTH : natural := 4  -- 4 bits -> 16 >= 12 adresses
        );
        port (
            clk  : in  std_logic;
            addr : in  natural range 0 to 2**ADDR_WIDTH - 1;
            q    : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    signal clk_t  : std_logic := '0';
    signal addr_t : natural   := 0;
    signal q_t    : std_logic_vector(7 downto 0);

begin

    rom_1 : single_port_rom
        generic map(
            DATA_WIDTH => 8,
            ADDR_WIDTH => 4
        )
        port map(
            clk  => clk_t,
            addr => addr_t,
            q    => q_t
        );

    -- horloge (même si la ROM est asynchrone, c'est pas grave)
    clk_t <= not clk_t after 5 ns;

    -- Parcours des 12 adresses dans l'ordre croissant
    stim_proc : process
    begin
        for i in 0 to 11 loop
            addr_t <= i;
            wait for 20 ns;
        end loop;
        wait;
    end process;

end architecture;
