library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_SM is
end entity;

architecture behav of tb_SM is

    signal funct3_s   : std_logic_vector(2 downto 0);
    signal addr_lsb_s : std_logic_vector(1 downto 0);
    signal data_in_s  : std_logic_vector(31 downto 0);
    signal q_s        : std_logic_vector(31 downto 0);
    signal data_out_s : std_logic_vector(31 downto 0);

begin

    -- DUT
    dut : entity work.SM
        port map (
            funct3   => funct3_s,
            addr_lsb => addr_lsb_s,
            data_in  => data_in_s,
            q        => q_s,
            data_out => data_out_s
        );

    -- Stimuli
    stim_proc : process
        procedure do_test(
            constant name      : in string;
            constant f3        : in std_logic_vector(2 downto 0);
            constant addr_lsb  : in std_logic_vector(1 downto 0);
            constant data_in_c : in std_logic_vector(31 downto 0);
            constant q_c       : in std_logic_vector(31 downto 0);
            constant expected  : in std_logic_vector(31 downto 0)
        ) is
        begin
            funct3_s   <= f3;
            addr_lsb_s <= addr_lsb;
            data_in_s  <= data_in_c;
            q_s        <= q_c;
            wait for 1 ns;

            -- Vérification simple, sans to_hstring
            assert data_out_s = expected
                report "Echec test : " & name
                severity error;
        end procedure;
    begin
        ----------------------------------------------------------------
        -- 1) sw : écrire un mot complet
        ----------------------------------------------------------------
        do_test(
            "sw full word 1",
            "010",                       -- sw
            "00",
            x"12345678",                 -- data_in
            x"AAAAAAAA",                 -- q
            x"12345678"                  -- attendu
        );

        ----------------------------------------------------------------
        -- 2) sb : offset 0 (octet 0)
        ----------------------------------------------------------------
        do_test(
            "sb offset 0",
            "000",
            "00",
            x"000000FF",
            x"00000000",
            x"000000FF"
        );

        ----------------------------------------------------------------
        -- 3) sb : offset 1 (octet 1)
        ----------------------------------------------------------------
        do_test(
            "sb offset 1",
            "000",
            "01",
            x"000000AA",
            x"00000000",
            x"0000AA00"
        );

        ----------------------------------------------------------------
        -- 4) sb : offset 2 (octet 2)
        ----------------------------------------------------------------
        do_test(
            "sb offset 2",
            "000",
            "10",
            x"000000BB",
            x"00000000",
            x"00BB0000"
        );

        ----------------------------------------------------------------
        -- 5) sb : offset 3 (octet 3)
        ----------------------------------------------------------------
        do_test(
            "sb offset 3",
            "000",
            "11",
            x"000000CC",
            x"00000000",
            x"CC000000"
        );

        ----------------------------------------------------------------
        -- 6) sb sur mot non nul (changer un seul octet)
        ----------------------------------------------------------------
        do_test(
            "sb change middle byte",
            "000",
            "10",                        -- octet 2
            x"000000FF",
            x"11223344",
            x"11FF3344"
        );

        ----------------------------------------------------------------
        -- 7) sh, demi-mot bas
        ----------------------------------------------------------------
        do_test(
            "sh lower half",
            "001",
            "00",
            x"0000BEEF",
            x"00000000",
            x"0000BEEF"
        );

        ----------------------------------------------------------------
        -- 8) sh, demi-mot haut
        ----------------------------------------------------------------
        do_test(
            "sh upper half",
            "001",
            "10",
            x"00001234",
            x"DEADBEEF",
            x"1234BEEF"
        );

        ----------------------------------------------------------------
        -- 9) sh misaligné (adresse non alignée : pas de changement)
        ----------------------------------------------------------------
        do_test(
            "sh misaligned (no change)",
            "001",
            "01",                        -- pas 00 ni 10
            x"00001234",
            x"CAFEBABE",
            x"CAFEBABE"
        );

        ----------------------------------------------------------------
        -- 10) sw : écraser complètement
        ----------------------------------------------------------------
        do_test(
            "sw full word 2",
            "010",
            "00",
            x"CAFEBABE",
            x"DEADBEEF",
            x"CAFEBABE"
        );

        report "Tous les tests SM passes" severity note;
        wait;
    end process;

end architecture behav;
