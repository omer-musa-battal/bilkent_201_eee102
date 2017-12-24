LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE elements IS

    --selection cell
    --selection_cell(0) - color code
    --selection_cell(1) - display x coordinate
    --selection_cell(2) - display y coordinate
    --selection_cell(3) - x width
    --selection_cell(4) - y height
    --selection_cell(5) - selection x coordinate
    --selection_cell(6) - selection y coordinate
    TYPE SELECTION_CELL IS ARRAY (0 TO 6) OF INTEGER RANGE 0 TO 800;
 
    --cell array
    --cell(0) - color code
    --cell(1) - display x coordinate
    --cell(2) - display y coordinate
    --cell(3) - x width
    --cell(4) - y height
    TYPE CELL IS ARRAY (0 TO 4) OF INTEGER RANGE 0 TO 800;

    --int array for holding the color information of cells
    TYPE INT_ARRAY_2D IS ARRAY (INTEGER RANGE <>, INTEGER RANGE <>) OF INTEGER RANGE 0 TO 15;

    --an array of colors to be used as a color scheme
    TYPE COLORS IS ARRAY (0 TO 15) OF std_logic_vector (11 DOWNTO 0);

    --an array of color schemes that can be used in the game
    TYPE COLOR_SCHEMES IS ARRAY (INTEGER RANGE <>) OF COLORS;

    --some basic colors
    CONSTANT COLOR_NULL       : std_logic_vector (11 DOWNTO 0) := "000000000000";
    CONSTANT COLOR_BLACK      : std_logic_vector (11 DOWNTO 0) := "000000000000";
    CONSTANT COLOR_RED        : std_logic_vector (11 DOWNTO 0) := "111100000000";
    CONSTANT COLOR_GREEN      : std_logic_vector (11 DOWNTO 0) := "000011110000";
    CONSTANT COLOR_BLUE       : std_logic_vector (11 DOWNTO 0) := "000000001111";
    CONSTANT COLOR_YELLOW     : std_logic_vector (11 DOWNTO 0) := "111111110000";
    CONSTANT COLOR_CYAN       : std_logic_vector (11 DOWNTO 0) := "000011111111";
    CONSTANT COLOR_MAGENTA    : std_logic_vector (11 DOWNTO 0) := "111100001111";
    CONSTANT COLOR_WHITE      : std_logic_vector (11 DOWNTO 0) := "111111111111";
    CONSTANT COLOR_GRAY       : std_logic_vector (11 DOWNTO 0) := "011101110111";
 
    CONSTANT COLOR_DARK_GREEN : std_logic_vector (11 DOWNTO 0) := "000001110000";
    CONSTANT COLOR_OLIVE      : std_logic_vector (11 DOWNTO 0) := "100010000000";
 
    CONSTANT COLOR_MAROON     : std_logic_vector (11 DOWNTO 0) := "100000000000";
    CONSTANT COLOR_DARK_GRAY  : std_logic_vector (11 DOWNTO 0) := "001000100010";
 
    --a color set that can be used to determine the game colors
    --other color sets were determined based on this one in particular
    --###
    --color_set legend
    --color_set(0) : null (nonexistent element) - will not be referenced as rgb signal, insignificant
    --color_set(1) : background color
    --color_set(2) : board color
    --color_set(3) : selection color
    --color_set(4) : cell color 0
    --color_set(5) : cell color 1
    --color_set(6) : cell color 2
    --color_set(7) : cell color 3
    --color_set(8) : cell color 4
    --color_set(9) : cell color 5
    --color_set(10) : cell color 6
    --color_set(11) : key cell color, empty
    --color_set(12) : key cell color, half true
    --color_set(13) : key cell color, full true
    --color_set(14) : TBD
    --color_set(15) : border color
    CONSTANT color_set_0 : COLORS := (
        COLOR_NULL, --0
        COLOR_BLACK, --1
        COLOR_GRAY, --2
        COLOR_DARK_GREEN, --3
        COLOR_BLACK, --4
        COLOR_RED, --5
        COLOR_GREEN, --6
        COLOR_BLUE, --7
        COLOR_YELLOW, --8
        COLOR_CYAN, --9
        COLOR_MAGENTA, --10
        COLOR_BLACK, --11
        COLOR_WHITE, --12
        COLOR_RED, --13
        COLOR_RED, --14
        COLOR_RED --15
    );
 
    CONSTANT color_set_1 : COLORS := (
        COLOR_NULL, --0
        COLOR_BLACK, --1
        COLOR_MAROON, --2
        COLOR_OLIVE, --3
        COLOR_BLACK, --4
        COLOR_RED, --5
        COLOR_GREEN, --6
        COLOR_BLUE, --7
        COLOR_YELLOW, --8
        COLOR_CYAN, --9
        COLOR_MAGENTA, --10
        COLOR_BLACK, --11
        COLOR_WHITE, --12
        COLOR_RED, --13
        COLOR_RED, --14
        COLOR_RED --15
    );
 
    --color blind color set
    CONSTANT color_set_2 : COLORS := (
        COLOR_NULL, --0
        COLOR_BLACK, --1
        COLOR_WHITE, --2
        COLOR_DARK_GREEN, --3
        "000000000000", --4
        "001000100010", --5
        "010001000100", --6
        "011001100110", --7
        "100010001000", --8
        "101010101010", --9
        "110011001100", --10
        COLOR_BLACK, --11
        COLOR_WHITE, --12
        COLOR_GRAY, --13
        COLOR_RED, --14
        COLOR_RED --15
    );
 
    SIGNAL color_set_3 : COLORS;
    --constants for horizontal synchronization
    CONSTANT VIS_H  : INTEGER := 640;
    CONSTANT FP_H   : INTEGER := 16;
    CONSTANT SP_H   : INTEGER := 96;
    CONSTANT BP_H   : INTEGER := 48;
    CONSTANT TOT_H  : INTEGER := VIS_H + FP_H + SP_H + BP_H; --800
    CONSTANT NULL_H : INTEGER := FP_H + SP_H + BP_H; --horizontal black rgb area

    --constants for vertical synchronization
    CONSTANT VIS_V  : INTEGER := 480;
    CONSTANT FP_V   : INTEGER := 10;
    CONSTANT SP_V   : INTEGER := 2;
    CONSTANT BP_V   : INTEGER := 33;
    CONSTANT TOT_V  : INTEGER := VIS_V + FP_V + SP_V + BP_V; --525
    CONSTANT NULL_V : INTEGER := FP_V + SP_V + BP_V; --vertical black rgb area

    --game mechanics constants
    CONSTANT TOT_GUESS_NUMBER   : INTEGER := 12;
    CONSTANT TOT_COLOR_NUMBER   : INTEGER := 6;
 
    CONSTANT COLOR_INDEX_SHIFT  : INTEGER := 4;
    CONSTANT KEYPIN_INDEX_SHIFT : INTEGER := COLOR_INDEX_SHIFT + TOT_COLOR_NUMBER + 1;
 
    --game visuals constants
    CONSTANT SCREEN_BORDER          : INTEGER := 40;
 
    CONSTANT BOARD_V                : INTEGER := 340;
    CONSTANT BOARD_H                : INTEGER := 560;
    CONSTANT BOARD_BORDER           : INTEGER := 20;
 
    CONSTANT COLOR_PANEL_H          : INTEGER := 520;
    CONSTANT COLOR_PANEL_V          : INTEGER := 80;
 
    CONSTANT COLOR_SELECTION_SIDE   : INTEGER := 60;
    CONSTANT COLOR_SELECTION_BORDER : INTEGER := 10;
 
    CONSTANT GUESS_PANEL_H          : INTEGER := 520;
    CONSTANT GUESS_PANEL_V          : INTEGER := 200;
 
    CONSTANT CELL_SIDE              : INTEGER := 40;
    CONSTANT CELL_BORDER            : INTEGER := 5;
 
    CONSTANT ELEMENT_SIDE           : INTEGER := 30;
    CONSTANT KEYPIN_SIDE            : INTEGER := 10;
 
    CONSTANT KEYPIN_BORDER          : INTEGER := 10;
 
    CONSTANT SELECTION_H            : INTEGER := 40;
    CONSTANT SELECTION_V            : INTEGER := 200;

END elements;

PACKAGE BODY elements IS
END PACKAGE BODY;