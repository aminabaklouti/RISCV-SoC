library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_rom is
    generic (
        DATA_WIDTH : natural := 8;
        ADDR_WIDTH : natural := 8
    );
    port (
        clk  : in  std_logic;  -- on le garde même si on ne l'utilise pas pour la lecture
        addr : in  natural range 0 to 2**ADDR_WIDTH - 1;
        q    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity single_port_rom;

architecture rtl of single_port_rom is

    -- un mot = DATA_WIDTH bits
    subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
    -- mémoire avec 2**ADDR_WIDTH mots
    type memory_t is array (0 to 2**ADDR_WIDTH - 1) of word_t;

    -- initialisation avec des valeurs arbitraires sur les 12 premières adresses
    constant rom : memory_t := (
        0  => "00000000",
        1  => "00000001",
        2  => "00000010",
        3  => "00000011",
        4  => "00000100",
        5  => "00000101",
        6  => "00000110",
        7  => "00000111",
        8  => "00001000",
        9  => "00001001",
        10 => "00001010",
        11 => "00001011",
        others => (others => '0')
    );

begin

    -- ROM totalement asynchrone : q suit addr sans horloge
    q <= rom(addr);

end architecture rtl;
