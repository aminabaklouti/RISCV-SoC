library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Imm_ext is
end entity tb_Imm_ext;

architecture behav of tb_Imm_ext is

    constant DATA_WIDTH_C : integer := 32;

    signal instr    : std_logic_vector(DATA_WIDTH_C-1 downto 0);
    signal instType : std_logic_vector(2 downto 0) := "000";  -- on met I-type par défaut
    signal immExt   : std_logic_vector(DATA_WIDTH_C-1 downto 0);

begin

    -- DUT
    dut : entity work.Imm_ext
        generic map (
            dataWidth => DATA_WIDTH_C
        )
        port map (
            instr    => instr,
            instType => instType,
            immExt   => immExt
        );

    -- Stimuli : 10 instructions I-type différentes
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- ⚠ Ici tu mets de "vraies" instructions I générées sur le site
        -- indiqué par le prof (addi, andi, ori, xori, slli, srli, srai, ...)
        -- L’important pour Imm_ext, c’est surtout les bits 31..20.
        ----------------------------------------------------------------

        -- 1) ADDI avec imm positif
        instr <= x"00500093";   -- EXEMPLE (addi x1, x0, 5) -> imm = 5
        wait for 20 ns;

        -- 2) ADDI avec imm négatif
        instr <= x"FFD00113";   -- EXEMPLE (addi x2, x0, -3) -> imm = -3
        wait for 20 ns;

        -- 3) ORI
        instr <= x"0FF0E193";   -- EXEMPLE (ori x3, x1, 0xFF)
        wait for 20 ns;

        -- 4) ANDI
        instr <= x"0F00F213";   -- EXEMPLE (andi x4, x1, 0xF0)
        wait for 20 ns;

        -- 5) XORI
        instr <= x"00F0C293";   -- EXEMPLE (xori x5, x1, 0x0F)
        wait for 20 ns;

        -- 6) SLTI
        instr <= x"00A12313";   -- EXEMPLE (slti x6, x2, 10)
        wait for 20 ns;

        -- 7) SLTIU
        instr <= x"00A1A393";   -- EXEMPLE (sltiu x7, x3, 10)
        wait for 20 ns;

        -- 8) SLLI
        instr <= x"00111413";   -- EXEMPLE (slli x8, x2, 1)
        wait for 20 ns;

        -- 9) SRLI
        instr <= x"00115493";   -- EXEMPLE (srli x9, x2, 1)
        wait for 20 ns;

        -- 10) SRAI
        instr <= x"40115513";   -- EXEMPLE (srai x10, x2, 1)
        wait for 20 ns;

        wait;
    end process;

end architecture behav;
