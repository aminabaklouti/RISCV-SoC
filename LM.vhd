library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- LM : sélectionne l'octet ou le demi-mot lu en mémoire
-- et fait l'extension de signe / de zéro selon funct3.
--
-- funct3 :
--   000 -> LB  (sign extend)
--   100 -> LBU (zero extend)
--   001 -> LH  (sign extend)
--   101 -> LHU (zero extend)
--   010 -> LW  (word)
--
entity LM is
    port (
        funct3   : in  std_logic_vector(2 downto 0);  -- type de load
        addr_lsb : in  std_logic_vector(1 downto 0);  -- adresse[1:0]
        data_in  : in  std_logic_vector(31 downto 0); -- mot lu en DMEM
        data_out : out std_logic_vector(31 downto 0)  -- valeur à écrire dans rd
    );
end entity LM;

architecture rtl of LM is
begin
    process(funct3, addr_lsb, data_in)
        variable byte_v : std_logic_vector(7 downto 0);
        variable half_v : std_logic_vector(15 downto 0);
        variable tmp    : std_logic_vector(31 downto 0);
    begin
        tmp := (others => '0');

        case funct3 is

            ----------------------------------------------------------------
            -- LB : load byte (sign extend)
            ----------------------------------------------------------------
            when "000" =>
                case addr_lsb is
                    when "00" => byte_v := data_in(7  downto 0);
                    when "01" => byte_v := data_in(15 downto 8);
                    when "10" => byte_v := data_in(23 downto 16);
                    when "11" => byte_v := data_in(31 downto 24);
                    when others => byte_v := (others => '0');
                end case;

                -- extension de signe 8 -> 32
                if byte_v(7) = '1' then
                    tmp := (31 downto 8 => '1') & byte_v;
                else
                    tmp := (31 downto 8 => '0') & byte_v;
                end if;

            ----------------------------------------------------------------
            -- LBU : load byte (zero extend)
            ----------------------------------------------------------------
            when "100" =>
                case addr_lsb is
                    when "00" => byte_v := data_in(7  downto 0);
                    when "01" => byte_v := data_in(15 downto 8);
                    when "10" => byte_v := data_in(23 downto 16);
                    when "11" => byte_v := data_in(31 downto 24);
                    when others => byte_v := (others => '0');
                end case;
                tmp := (31 downto 8 => '0') & byte_v;

            ----------------------------------------------------------------
            -- LH : load halfword (sign extend)
            ----------------------------------------------------------------
            when "001" =>
                case addr_lsb is
                    when "00" =>
                        half_v := data_in(15 downto 0);
                    when "10" =>
                        half_v := data_in(31 downto 16);
                    when others =>
                        -- adresse non alignée : on prend moitié basse
                        half_v := data_in(15 downto 0);
                end case;

                if half_v(15) = '1' then
                    tmp := (31 downto 16 => '1') & half_v;
                else
                    tmp := (31 downto 16 => '0') & half_v;
                end if;

            ----------------------------------------------------------------
            -- LHU : load halfword (zero extend)
            ----------------------------------------------------------------
            when "101" =>
                case addr_lsb is
                    when "00" =>
                        half_v := data_in(15 downto 0);
                    when "10" =>
                        half_v := data_in(31 downto 16);
                    when others =>
                        half_v := data_in(15 downto 0);
                end case;
                tmp := (31 downto 16 => '0') & half_v;

            ----------------------------------------------------------------
            -- LW : load word (pas de changement)
            ----------------------------------------------------------------
            when "010" =>
                tmp := data_in;

            ----------------------------------------------------------------
            -- autres : on renvoie data_in
            ----------------------------------------------------------------
            when others =>
                tmp := data_in;
        end case;

        data_out <= tmp;
    end process;

end architecture rtl;
