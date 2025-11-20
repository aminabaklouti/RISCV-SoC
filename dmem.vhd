library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmem is
    generic (
        DATA_WIDTH : natural := 32;  -- largeur d'un mot
        ADDR_WIDTH : natural := 8    -- nombre de bits d'adresse -> 2^ADDR_WIDTH mots
    );
    port (
        clk      : in  std_logic;
        addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);  -- adresse unique R/W
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- données à écrire
        we       : in  std_logic;                                -- write enable
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)   -- données lues
    );
end entity dmem;

architecture rtl of dmem is

    --------------------------------------------------------------------
    -- Mémoire : 2^ADDR_WIDTH mots de DATA_WIDTH bits
    --------------------------------------------------------------------
    subtype word_t  is std_logic_vector(DATA_WIDTH-1 downto 0);
    type    memory_t is array (0 to 2**ADDR_WIDTH - 1) of word_t;

    -- Contenu initial : la case i contient la valeur i (en 32 bits)
    function init_mem return memory_t is
        variable tmp : memory_t := (others => (others => '0'));
    begin
        for i in 0 to 2**ADDR_WIDTH - 1 loop
            tmp(i) := std_logic_vector(to_unsigned(i, DATA_WIDTH));
        end loop;
        return tmp;
    end function;

    signal ram      : memory_t := init_mem;
    signal addr_int : integer range 0 to 2**ADDR_WIDTH - 1;

begin

    -- conversion adresse std_logic_vector -> entier pour indexer le tableau
    addr_int <= to_integer(unsigned(addr));

    ----------------------------------------------------------------
    -- ÉCRITURE SYNCHRONE
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(addr_int) <= data_in;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- LECTURE ASYNCHRONE
    ----------------------------------------------------------------
    data_out <= ram(addr_int);

end architecture rtl;
