library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Imm_ext is
    generic (
        dataWidth : integer := 32
    );
    port (
        instr    : in  std_logic_vector(dataWidth-1 downto 0); -- instruction
        instType : in  std_logic_vector(2 downto 0);           -- R/I/S/...
        immExt   : out std_logic_vector(dataWidth-1 downto 0)  -- imm 32 bits
    );
end entity Imm_ext;

architecture behav of Imm_ext is
begin

    process(instr, instType)
        variable imm12 : std_logic_vector(11 downto 0);
    begin
        ----------------------------------------------------------------
        -- Sélection du format d'immédiat selon instType
        ----------------------------------------------------------------
        case instType is

            -- Type I arithmétique + LOAD (I-type classique)
            when "001" | "010" =>
                -- imm[11:0] = instr(31 downto 20)
                imm12 := instr(31 downto 20);

            -- Type S (store) : imm[11:0] = instr[31:25] & instr[11:7]
            when "011" =>
                imm12 := instr(31 downto 25) & instr(11 downto 7);

            -- autres types : pour l'instant 0
            when others =>
                imm12 := (others => '0');

        end case;

        ----------------------------------------------------------------
        -- Extension de signe sur 32 bits
        ----------------------------------------------------------------
        if imm12(11) = '0' then
            immExt <= (31 downto 12 => '0') & imm12;
        else
            immExt <= (31 downto 12 => '1') & imm12;
        end if;
    end process;

end architecture behav;
