LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

ENTITY top_module IS
    PORT 
    (
        clk, btnC, btnU, btnL, btnR, btnD : IN STD_LOGIC;
        sw                                : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Hsync, Vsync                      : OUT STD_LOGIC;
        vgaRed, vgaGreen, vgaBlue         : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        an                                : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        seg                               : OUT STD_LOGIC_VECTOR (0 TO 6)
    );
END top_module;

ARCHITECTURE MAIN OF top_module IS

    COMPONENT clock_divider IS
        PORT 
        (
            CLK_IN  : IN STD_LOGIC;
            CLK_25M : OUT STD_LOGIC;
            clk_200 : OUT STD_LOGIC;
            CLK_10  : OUT STD_LOGIC;
            clk_1   : OUT STD_LOGIC
        );
    END COMPONENT clock_divider;

    COMPONENT vga_sync IS
        PORT 
        (
            Clk_25m, clk_10, clk_1        : IN STD_LOGIC;
            Left, Right, up, down, center : IN STD_LOGIC;
            switch                        : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            HSYNC, VSYNC                  : OUT STD_LOGIC;
            R, G, B                       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            game_score                    : OUT INTEGER RANGE 0 TO 300
        );
    END COMPONENT vga_sync;
 
    COMPONENT segment_driver
        PORT 
        (
            input_int      : IN INTEGER;
            clk_200        : IN STD_LOGIC;
            segment        : OUT STD_LOGIC_VECTOR (0 TO 6);
            select_display : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
        );
    END COMPONENT segment_driver;

    SIGNAL clk_25m : std_logic;
    SIGNAL clk_200 : std_logic;
    SIGNAL clk_10  : std_logic;
    SIGNAL clk_1   : std_logic;
 
    SIGNAL score   : INTEGER;

BEGIN
    C1 : clock_divider
    PORT MAP
    (
        CLK_IN  => clk, 
        CLK_25M => clk_25m, 
        clk_200 => clk_200, 
        clk_10  => clk_10, 
        clk_1   => clk_1
    );
    C2 : vga_sync
    PORT MAP
    (
        CLK_25m    => clk_25m, 
        clk_10     => clk_10, 
        clk_1      => clk_1, 
        LEFT       => btnL, 
        RIGHT      => btnR, 
        up         => btnU, 
        down       => btnD, 
        center     => btnC, 
        switch     => sw, 
        HSYNC      => Hsync, 
        VSYNC      => Vsync, 
        R          => vgaRed, 
        G          => vgaGreen, 
        B          => vgaBlue, 
        game_score => score
    );
 
    C3 : segment_driver
    PORT MAP
    (
        input_int      => score, 
        clk_200        => clk_200, 
        segment        => seg, 
        select_display => an
    );
 
END MAIN;