LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY clock_divider IS
    PORT 
    (
        CLK_IN  : IN STD_LOGIC;
        CLK_25M : OUT STD_LOGIC;
        CLK_200 : OUT STD_LOGIC;
        CLK_10  : OUT STD_LOGIC;
        CLK_1   : OUT STD_LOGIC
    );
END clock_divider;

ARCHITECTURE MAIN OF clock_divider IS
    SIGNAL clk_25MHz     : std_logic := '0';
    SIGNAL clk_200Hz     : std_logic := '0';
    SIGNAL clk_10Hz      : std_logic := '0';
    SIGNAL clk_1Hz       : std_logic := '0';
    SIGNAL clk_25MHz_int : INTEGER;
    SIGNAL clk_200Hz_int : INTEGER;
    SIGNAL clk_10Hz_int  : INTEGER;
    SIGNAL clk_1Hz_int   : INTEGER;
 
BEGIN
    PROCESS (CLK_IN)
    BEGIN
        IF rising_edge(CLK_IN) THEN
 
            clk_25MHz_int <= clk_25MHz_int + 1;
            clk_200Hz_int <= clk_200Hz_int + 1;
            clk_10Hz_int  <= clk_10Hz_int + 1;
            clk_1Hz_int   <= clk_1Hz_int + 1;
 
            IF clk_25MHz_int = 4/2 - 1 THEN
                clk_25MHz     <= NOT clk_25MHz;
                clk_25MHz_int <= 0;
            END IF;
 
            IF clk_200Hz_int = 500000/2 - 1 THEN
                clk_200Hz     <= NOT clk_200Hz;
                clk_200Hz_int <= 0;
            END IF;
 
            IF clk_10Hz_int = 10000000/2 - 1 THEN
                clk_10Hz     <= NOT clk_10Hz;
                clk_10Hz_int <= 0;
            END IF;
 
            IF clk_1Hz_int = 100000000/2 - 1 THEN
                clk_1Hz     <= NOT clk_1Hz;
                clk_1Hz_int <= 0;
            END IF;
 
        END IF;
 
    END PROCESS;

    CLK_25M <= clk_25MHz;
    CLK_200 <= clk_200Hz;
    CLK_10  <= clk_10Hz;
    CLK_1   <= clk_1Hz;

END MAIN;