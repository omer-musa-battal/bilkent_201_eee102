LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY segment_driver IS
    PORT 
    (
        input_int      : IN INTEGER;
        clk_200        : IN STD_LOGIC;
        segment        : OUT STD_LOGIC_VECTOR (0 TO 6);
        select_display : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END segment_driver;

ARCHITECTURE Behavioral OF segment_driver IS

    COMPONENT segment_decoder
        PORT 
        (
            digit    : IN std_logic_vector(3 DOWNTO 0);
            segments : OUT std_logic_vector(0 TO 6)
        );
    END COMPONENT;

    SIGNAL temporary_data                 : std_logic_vector(3 DOWNTO 0);
 
    SIGNAL digit3, digit2, digit1, digit0 : std_logic_vector(3 DOWNTO 0);
 
BEGIN
    digit3 <= conv_std_logic_vector(input_int / 1000, 4);
    digit2 <= conv_std_logic_vector((input_int MOD 1000) / 100, 4);
    digit1 <= conv_std_logic_vector((input_int MOD 100) / 10, 4);
    digit0 <= conv_std_logic_vector((input_int MOD 10), 4);

    uut0_1 : segment_decoder
    PORT MAP
    (
        digit    => temporary_data, 
        segments => segment
    );
 
    PROCESS (clk_200)
    VARIABLE display_selection : std_logic_vector(1 DOWNTO 0);
    BEGIN
        IF rising_edge(clk_200) THEN
            CASE display_selection IS
                WHEN "00" => temporary_data <= digit0;
                select_display                   <= "1110";
 
                WHEN "01" => temporary_data <= digit1;
                select_display                   <= "1101";
 
                WHEN "10" => temporary_data <= digit2;
                select_display                   <= "1011";
 
                WHEN "11" => temporary_data <= digit3;
                select_display                   <= "0111";
 
                WHEN OTHERS => temporary_data    <= digit3;
                select_display                   <= "1111";
 
            END CASE;
 
            display_selection := display_selection + 1;
 
        END IF;
 
    END PROCESS;

END Behavioral;