library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_ram is
    generic (
        DATA_WIDTH : natural := 32;  -- 32 bits par mot
        ADDR_WIDTH : natural := 3    -- 3 bits -> 2^3 = 8 adresses
    );
    port (
        clk  : in std_logic;
        addr : in natural range 0 to 2**ADDR_WIDTH - 1;
        data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        we   : in std_logic := '1';
        q    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end single_port_ram;

architecture rtl of single_port_ram is

    -- RAM : 8 mots de 32 bits
    subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
    type memory_t is array(0 to 2**ADDR_WIDTH-1) of word_t;

    -- Initialisation : par défaut, chaque case contient son adresse
    function init_ram return memory_t is
        variable tmp : memory_t := (others => (others => '0'));
    begin
        for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop
            tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
        end loop;
        return tmp;
    end function;

    signal ram : memory_t := init_ram;

begin

    ----------------------------------------------------------------
    -- ÉCRITURE SYNCHRONE
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(addr) <= data;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- LECTURE ASYNCHRONE (directement sur l'adresse)
    ----------------------------------------------------------------
    q <= ram(addr);

end architecture rtl;
