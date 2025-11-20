library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- pour to_unsigned

entity tb_pc is
end entity; 

architecture arch of tb_pc is

	component pc is
		generic
		(
			ADDR_WIDTH : natural := 5
		);
		port
		(
			din   : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			dout  : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
			reset : in std_logic;
			load  : in std_logic;
			clk   : in std_logic
		);
	end component;

	constant clk_demi_periode : time := 5 ns;
	constant ADDR_WIDTH_t     : natural := 5;

	signal din_t   : std_logic_vector(ADDR_WIDTH_t - 1 downto 0) := (others => '0');
	signal dout_t  : std_logic_vector(ADDR_WIDTH_t - 1 downto 0);
	signal reset_t : std_logic := '0';
	signal load_t  : std_logic := '0';
	signal clk_t   : std_logic := '0';

begin

	pc_1 : pc
		generic map (
			ADDR_WIDTH => ADDR_WIDTH_t
		)
		port map (
			din   => din_t,
			dout  => dout_t,
			reset => reset_t,
			load  => load_t,
			clk   => clk_t
		);

	-- Clock
	clk_t <= not clk_t after clk_demi_periode;

	-- Test process
	process
	begin
		din_t <= std_logic_vector(to_unsigned(10, ADDR_WIDTH_t)); -- conversion
		load_t <= '1';
		wait for 2*clk_demi_periode;
		load_t <= '0';
		wait for 2*clk_demi_periode;

		reset_t <= '1';
		wait for 2*clk_demi_periode;
		reset_t <= '0';

		wait;
	end process;

end architecture;