library ieee;
use ieee.std_logic_1164.all;

entity mux21 is
    generic (
        dataWidth : integer := 32
    );
    port (
        d0  : in  std_logic_vector(dataWidth-1 downto 0);
        d1  : in  std_logic_vector(dataWidth-1 downto 0);
        sel : in  std_logic;
        y   : out std_logic_vector(dataWidth-1 downto 0)
    );
end entity;

architecture comb of mux21 is
begin
    y <= d1 when sel = '1' else d0;
end architecture;
