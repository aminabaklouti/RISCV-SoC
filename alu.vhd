library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic(
        dataWidth  : integer := 32;
        aluOpWidth : integer := 4
    );
    port(
        opA   : in  std_logic_vector(dataWidth-1 downto 0);
        opB   : in  std_logic_vector(dataWidth-1 downto 0);
        aluOp : in  std_logic_vector(aluOpWidth-1 downto 0);
        res   : out std_logic_vector(dataWidth-1 downto 0)
    );
end entity alu;

architecture rtl of alu is
    signal res_v : std_logic_vector(dataWidth-1 downto 0);
begin
    process(opA, opB, aluOp)
        variable shamt : integer range 0 to dataWidth-1;
        variable sel   : integer range 0 to 2**aluOpWidth-1;
    begin
        res_v <= (others => '0');
        sel   := to_integer(unsigned(aluOp));
        shamt := to_integer(unsigned(opB(4 downto 0)));

        case sel is
            when 0 =>  -- ADD
                res_v <= std_logic_vector(signed(opA) + signed(opB));
            when 1 =>  -- SUB
                res_v <= std_logic_vector(signed(opA) - signed(opB));
            when 2 =>  -- AND
                res_v <= opA and opB;
            when 3 =>  -- OR
                res_v <= opA or opB;
            when 4 =>  -- XOR
                res_v <= opA xor opB;
            when 5 =>  -- SLL
                res_v <= std_logic_vector(shift_left(unsigned(opA), shamt));
            when 6 =>  -- SRL
                res_v <= std_logic_vector(shift_right(unsigned(opA), shamt));
            when 7 =>  -- SRA
                res_v <= std_logic_vector(shift_right(signed(opA), shamt));
            when 8 =>  -- SLT
                res_v <= (others => '0');
                if signed(opA) < signed(opB) then
                    res_v(0) <= '1';
                end if;
            when 9 =>  -- SLTU
                res_v <= (others => '0');
                if unsigned(opA) < unsigned(opB) then
                    res_v(0) <= '1';
                end if;
            when others =>
                res_v <= (others => '0');
        end case;
    end process;

    res <= res_v;
end architecture rtl;
