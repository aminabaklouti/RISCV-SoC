library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_LM is
end entity;

architecture behav of tb_LM is

    signal funct3_s   : std_logic_vector(2 downto 0);
    signal addr_lsb_s : std_logic_vector(1 downto 0);
    signal data_in_s  : std_logic_vector(31 downto 0);
    signal data_out_s : std_logic_vector(31 downto 0);

begin

    dut : entity work.LM
        port map (
            funct3   => funct3_s,
            addr_lsb => addr_lsb_s,
            data_in  => data_in_s,
            data_out => data_out_s
        );

    stim_proc : process
        procedure do_test(
            constant name      : in string;
            constant f3        : in std_logic_vector(2 downto 0);
            constant addr_lsb  : in std_logic_vector(1 downto 0);
            constant din       : in std_logic_vector(31 downto 0);
            constant expected  : in std_logic_vector(31 downto 0)
        ) is
        begin
            funct3_s   <= f3;
            addr_lsb_s <= addr_lsb;
            data_in_s  <= din;
            wait for 1 ns;

            assert data_out_s = expected
                report "Echec test LM : " & name
                severity error;
        end procedure;
    begin
        ----------------------------------------------------------------
        -- 1) LB, byte positif (bit7 = 0)
        ----------------------------------------------------------------
        do_test(
            "LB byte0 positif",
            "000",            -- LB
            "00",
            x"1234567F",
            x"0000007F"       -- signe = 0 -> 0x0000007F
        );

        ----------------------------------------------------------------
        -- 2) LB, byte négatif (bit7 = 1)
        ----------------------------------------------------------------
        do_test(
            "LB byte3 negatif",
            "000",
            "11",
            x"80FFFFFF",      -- byte3 = 0x80
            x"FFFFFF80"       -- signe étendu
        );

        ----------------------------------------------------------------
        -- 3) LBU, byte avec bit7=1 -> zero extend
        ----------------------------------------------------------------
        do_test(
            "LBU byte2",
            "100",            -- LBU
            "10",
            x"00AA8000",      -- byte2 = 0x80
            x"00000080"       -- zero extend
        );

        ----------------------------------------------------------------
        -- 4) LH, halfword bas positif
        ----------------------------------------------------------------
        do_test(
            "LH lower positif",
            "001",            -- LH
            "00",
            x"1234007F",
            x"0000007F"
        );

        ----------------------------------------------------------------
        -- 5) LH, halfword haut négatif
        ----------------------------------------------------------------
        do_test(
            "LH upper negatif",
            "001",
            "10",
            x"80001234",      -- halfword haut = 0x8000
            x"FFFF8000"
        );

        ----------------------------------------------------------------
        -- 6) LHU, halfword haut
        ----------------------------------------------------------------
        do_test(
            "LHU upper",
            "101",
            "10",
            x"ABCD8001",
            x"00008001"
        );

        ----------------------------------------------------------------
        -- 7) LW, mot complet
        ----------------------------------------------------------------
        do_test(
            "LW full word",
            "010",
            "00",             -- peu importe
            x"CAFEBABE",
            x"CAFEBABE"
        );

        ----------------------------------------------------------------
        -- 8) LB, byte1
        ----------------------------------------------------------------
        do_test(
            "LB byte1",
            "000",
            "01",
            x"0012FF34",      -- byte1 = 0xFF -> -1
            x"FFFFFFFF"
        );

        ----------------------------------------------------------------
        -- 9) LBU, byte3
        ----------------------------------------------------------------
        do_test(
            "LBU byte3",
            "100",
            "11",
            x"7F000000",
            x"0000007F"
        );

        ----------------------------------------------------------------
        -- 10) LH misaligne (addr_lsb=01) -> demi-mot bas
        ----------------------------------------------------------------
        do_test(
				"LH misaligned",
				"001",
				"01",
				x"89AB7654",
				x"00007654"   
		  );


        wait;
    end process;

end architecture behav;
