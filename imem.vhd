library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use std.textio.all;

entity imem is
    generic (
        DATA_WIDTH  : natural := 32;
        ADDR_WIDTH  : natural := 8;         -- index de mot (pas d'octet)
        MEM_DEPTH   : natural := 200;       -- nb max de lignes à lire dans le fichier
        INIT_FILE   : string
    );
    port (
        address  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        Data_Out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity imem;

architecture behav of imem is

    --------------------------------------------------------------------
    -- Types
    --------------------------------------------------------------------
    subtype word_t   is std_logic_vector(DATA_WIDTH - 1 downto 0);
    type    memType  is array (0 to 2**ADDR_WIDTH - 1) of word_t;

    --------------------------------------------------------------------
    -- Conversion chaîne hex -> std_logic_vector
    --------------------------------------------------------------------
    function str_to_slv(str : string) return std_logic_vector is
        alias str_norm : string(1 to str'length) is str;
        variable char_v        : character;
        variable val_of_char_v : natural;
        variable res_v         : std_logic_vector(4 * str'length - 1 downto 0);
    begin
        for str_norm_idx in str_norm'range loop
            char_v := str_norm(str_norm_idx);
            case char_v is
                when '0' to '9' =>
                    val_of_char_v := character'pos(char_v) - character'pos('0');
                when 'A' to 'F' =>
                    val_of_char_v := character'pos(char_v) - character'pos('A') + 10;
                when 'a' to 'f' =>
                    val_of_char_v := character'pos(char_v) - character'pos('a') + 10;
                when others =>
                    report "str_to_slv: Invalid characters for convert"
                        severity ERROR;
            end case;

            res_v(res_v'left - 4 * str_norm_idx + 4 downto
                  res_v'left - 4 * str_norm_idx + 1)
                := std_logic_vector(to_unsigned(val_of_char_v, 4));
        end loop;
        return res_v;
    end function;

    --------------------------------------------------------------------
    -- Initialisation de la mémoire depuis un fichier texte hexa
    -- On remplit au plus :
    --   - MEM_DEPTH lignes
    --   - et la taille réelle de la RAM (0 .. mem_tmp'high)
    --------------------------------------------------------------------
    function memInit(fileName : string) return memType is
        variable mem_tmp     : memType := (others => (others => '0'));
        file     filePtr     : text;
        variable line_instr  : line;
        variable instr_str   : string(1 to 8);
        variable inst_num    : integer := 0;
        variable instr_init  : std_logic_vector(31 downto 0);
    begin
      report "IMEM: ouverture fichier = " & fileName;

		file_open(filePtr, fileName, READ_MODE);

        -- On s'arrête si :
        --  - on a lu MEM_DEPTH lignes
        --  - ou on a atteint mem_tmp'high
        --  - ou on est à la fin du fichier
        while (inst_num < MEM_DEPTH and
               inst_num <= mem_tmp'high and
               not endfile(filePtr)) loop

            readline(filePtr, line_instr);
            read(line_instr, instr_str);
            instr_init        := str_to_slv(instr_str);
            mem_tmp(inst_num) := instr_init;
            inst_num          := inst_num + 1;
        end loop;

        file_close(filePtr);
        return mem_tmp;
    end function;

    --------------------------------------------------------------------
    -- Mémoire d'instructions
    --------------------------------------------------------------------
    signal mem : memType := memInit(INIT_FILE);

begin

    ----------------------------------------------------------------
    -- Lecture asynchrone
    ----------------------------------------------------------------
    Data_Out <= mem(to_integer(unsigned(address)));

end architecture behav;
