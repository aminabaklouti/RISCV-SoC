library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SM is
    port(
        funct3   : in  std_logic_vector(2 downto 0);  -- 000=sb, 001=sh, 010=sw
        addr_lsb : in  std_logic_vector(1 downto 0);  -- res(1 downto 0)
        data_in  : in  std_logic_vector(31 downto 0); -- valeur à stocker (rs2)
        q        : in  std_logic_vector(31 downto 0); -- ancienne valeur lue en mémoire
        data_out : out std_logic_vector(31 downto 0)  -- nouvelle valeur à écrire
    );
end entity SM;

architecture rtl of SM is
begin
    process(funct3, addr_lsb, data_in, q)
        variable tmp : std_logic_vector(31 downto 0);
    begin
        -- par défaut : on garde la valeur actuelle de la mémoire
        tmp := q;

        case funct3 is

            ----------------------------------------------------------------
            -- sb : store byte (8 bits)
            ----------------------------------------------------------------
            when "000" =>
                case addr_lsb is
                    when "00" =>
                        -- octet 0 (bits 7..0)
                        tmp(7 downto 0)   := data_in(7 downto 0);
                    when "01" =>
                        -- octet 1 (bits 15..8)
                        tmp(15 downto 8)  := data_in(7 downto 0);
                    when "10" =>
                        -- octet 2 (bits 23..16)
                        tmp(23 downto 16) := data_in(7 downto 0);
                    when "11" =>
                        -- octet 3 (bits 31..24)
                        tmp(31 downto 24) := data_in(7 downto 0);
                    when others =>
                        null;
                end case;

            ----------------------------------------------------------------
            -- sh : store halfword (16 bits)
            ----------------------------------------------------------------
            when "001" =>
                case addr_lsb is
                    when "00" =>
                        -- demi-mot bas (bits 15..0)
                        tmp(15 downto 0) := data_in(15 downto 0);
                    when "10" =>
                        -- demi-mot haut (bits 31..16)
                        tmp(31 downto 16) := data_in(15 downto 0);
                    when others =>
                        -- adresses non alignées : on ne fait rien (on garde q)
                        null;
                end case;

            ----------------------------------------------------------------
            -- sw : store word (32 bits)
            ----------------------------------------------------------------
            when "010" =>
                tmp := data_in;

            ----------------------------------------------------------------
            -- autres (non utilisés ici)
            ----------------------------------------------------------------
            when others =>
                tmp := q;
        end case;

        data_out <= tmp;
    end process;
end architecture rtl;
