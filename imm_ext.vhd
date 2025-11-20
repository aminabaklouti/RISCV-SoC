library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Unité d'extension d'immédiat (pour l'instant : type I)
entity Imm_ext is
    generic (
        dataWidth : integer := 32
    );
    port (
        instr    : in  std_logic_vector(dataWidth-1 downto 0); -- instruction complète
        instType : in  std_logic_vector(2 downto 0);           -- type d'instruction (I,S,B,...) - pas encore utilisé
        immExt   : out std_logic_vector(dataWidth-1 downto 0)  -- immédiat étendu sur 32 bits
    );
end entity Imm_ext;

architecture behav of Imm_ext is
    signal imm12 : std_logic_vector(11 downto 0);
begin
    ----------------------------------------------------------------
    -- Pour l’instant : on ne gère que les instructions de type I
    -- imm[11:0] = instr(31 downto 20)
    ----------------------------------------------------------------
    imm12 <= instr(31 downto 20);

    -- Extension de signe sur 32 bits
    process(imm12)
    begin
        if imm12(11) = '0' then
            immExt <= (31 downto 12 => '0') & imm12;
        else
            immExt <= (31 downto 12 => '1') & imm12;
        end if;
    end process;

end architecture behav;
