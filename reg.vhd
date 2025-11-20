library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    generic (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 5      -- 2^5 = 32 registres
    );
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        WE    : in  std_logic;         -- write enable
        rw    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);  -- registre à écrire
        rs1   : in  std_logic_vector(ADDR_WIDTH-1 downto 0);  -- source 1
        rs2   : in  std_logic_vector(ADDR_WIDTH-1 downto 0);  -- source 2
        busW  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data à écrire
        busA  : out std_logic_vector(DATA_WIDTH-1 downto 0);  -- sortie RS1
        busB  : out std_logic_vector(DATA_WIDTH-1 downto 0)   -- sortie RS2
    );
end entity reg;

architecture rtl of reg is

    type reg_array_t is array (0 to 2**ADDR_WIDTH-1)
                        of std_logic_vector(DATA_WIDTH-1 downto 0);

    -- init simple à 0, la vraie initialisation se fait au reset
    signal regs : reg_array_t := (others => (others => '0'));

    signal idx_rw  : integer range 0 to 2**ADDR_WIDTH-1;
    signal idx_rs1 : integer range 0 to 2**ADDR_WIDTH-1;
    signal idx_rs2 : integer range 0 to 2**ADDR_WIDTH-1;

begin

    idx_rw  <= to_integer(unsigned(rw));
    idx_rs1 <= to_integer(unsigned(rs1));
    idx_rs2 <= to_integer(unsigned(rs2));

    -------------------------------------------------
    -- ÉCRITURE SYNCHRONE + INITIALISATION
    -------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            -- registre i = i
            for i in 0 to 2**ADDR_WIDTH-1 loop
                regs(i) <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            end loop;

        elsif rising_edge(clk) then
            if WE = '1' then
                -- x0 reste à 0
                if idx_rw /= 0 then
                    regs(idx_rw) <= busW;
                end if;
            end if;
        end if;
    end process;

    -------------------------------------------------
    -- LECTURE ASYNCHRONE
    -------------------------------------------------
    busA <= (others => '0') when idx_rs1 = 0 else regs(idx_rs1);
    busB <= (others => '0') when idx_rs2 = 0 else regs(idx_rs2);

end architecture rtl;
