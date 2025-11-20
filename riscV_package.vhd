library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package riscV_package is

    ----------------------------------------------------------------
    -- Banc de registres
    ----------------------------------------------------------------
    component reg 
        generic (
            dataWidth  : natural := 32;
            ADDR_WIDTH : natural := 5
        );
        port (
            clk, reset : in  std_logic;
            RA, RB, RW : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            BusW       : in  std_logic_vector(dataWidth-1 downto 0);
            WE         : in  std_logic := '1';   -- ⚠ majuscules
            BusA, BusB : out std_logic_vector(dataWidth-1 downto 0)
        );
    end component;

    ----------------------------------------------------------------
    -- Mémoire d'instructions
    ----------------------------------------------------------------
    component imem 
        generic (
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 8; 
            MEM_DEPTH  : natural := 100;
            INIT_FILE  : string
        );
        port (
            address  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
            Data_Out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    ----------------------------------------------------------------
    -- Compteur (PC)
    ----------------------------------------------------------------
    component pc 
    generic (
        ADDR_WIDTH : integer := 32
    );
    port (
        din   : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        clk   : in  std_logic;
        load  : in  std_logic;
        reset : in  std_logic;
        dout  : out std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
	end component;


    ----------------------------------------------------------------
    -- ALU
    ----------------------------------------------------------------
    component alu 
        generic (
            dataWidth  : integer := 32;
            aluOpWidth : integer := 4    -- ⚠ 4 bits partout
        );
        port (
            opA   : in  std_logic_vector(dataWidth-1 downto 0);
            opB   : in  std_logic_vector(dataWidth-1 downto 0);
            aluOp : in  std_logic_vector(aluOpWidth-1 downto 0);
            res   : out std_logic_vector(dataWidth-1 downto 0)
        );
    end component;

    ----------------------------------------------------------------
    -- Décodeur R-type
    ----------------------------------------------------------------
    component ir_dec_r 
        generic (
            dataWidth  : integer := 32;
            aluOpWidth : integer := 4
        );
        port ( 
            instr : in  std_logic_vector(dataWidth-1 downto 0);
            aluOp : out std_logic_vector(aluOpWidth-1 downto 0);
            clk   : in  std_logic;
            reset : in  std_logic
        );
    end component;

end riscV_package;
