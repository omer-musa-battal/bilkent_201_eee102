LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY segment_decoder IS
    PORT 
    (
        digit    : IN std_logic_vector(3 DOWNTO 0);
        segments : OUT std_logic_vector(0 TO 6)
    );
END segment_decoder;

ARCHITECTURE Behavioral OF segment_decoder IS

BEGIN
    PROCESS (digit)
 
    BEGIN
        CASE digit IS
            WHEN "0000" => segments <= "0000001"; -- "0"
            WHEN "0001" => segments <= "1001111"; -- "1"
            WHEN "0010" => segments <= "0010010"; -- "2"
            WHEN "0011" => segments <= "0000110"; -- "3"
            WHEN "0100" => segments <= "1001100"; -- "4"
            WHEN "0101" => segments <= "0100100"; -- "5"
            WHEN "0110" => segments <= "0100000"; -- "6"
            WHEN "0111" => segments <= "0001111"; -- "7"
            WHEN "1000" => segments <= "0000000"; -- "8"
            WHEN "1001" => segments <= "0000100"; -- "9"
            WHEN "1010" => segments <= "0001000"; -- "A"
            WHEN "1011" => segments <= "1100000"; -- "b"
            WHEN "1100" => segments <= "0110001"; -- "C"
            WHEN "1101" => segments <= "1000010"; -- "d"
            WHEN "1110" => segments <= "0110000"; -- "E"
            WHEN "1111" => segments <= "0111000"; -- "F"
            WHEN OTHERS => segments <= "1111111"; -- null
        END CASE;
 
    END PROCESS;

END Behavioral;