LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.elements.ALL;

ENTITY vga_sync IS
    PORT 
    (
        clk_25m, clk_10, clk_1        : IN STD_LOGIC;
        left, right, up, down, center : IN STD_LOGIC;
        switch                        : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        game_score                    : OUT INTEGER RANGE 0 TO 300;
        HSYNC, VSYNC                  : OUT STD_LOGIC;
        R, G, B                       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END vga_sync;

ARCHITECTURE MAIN OF vga_sync IS

    --synchronization signals
    SIGNAL HPOS_cur  : INTEGER RANGE 1 TO TOT_H := 1;
    SIGNAL VPOS_cur  : INTEGER RANGE 1 TO TOT_V := 1;
    SIGNAL HPOS_next : INTEGER RANGE 1 TO TOT_H;
    SIGNAL VPOS_next : INTEGER RANGE 1 TO TOT_V;
    SIGNAL rgb_cur   : std_logic_vector (11 DOWNTO 0);
    SIGNAL rgb_next  : std_logic_vector (11 DOWNTO 0);
 
    --game status signals
    SIGNAL reset    : std_logic := '0';
    SIGNAL in_game  : std_logic := '1';
    SIGNAL game_won : std_logic := '0';
    SIGNAL score    : INTEGER := 500;
 
    --color scheme signals
    SIGNAL color_scheme_select : INTEGER;
    SIGNAL color_scheme        : COLOR_SCHEMES (0 TO 3);
 
    --signal to determine if a color layer is to be displayed
    SIGNAL show_color : std_logic_vector (1 TO 15);
 
    --cell colors stored as integers
    --color codes for color cells are shifted by COLOR_INDEX_SHIFT and key cells are shifted by KEYPIN_INDEX_SHIFT
    --this was done to keep all game colors in one array
    SIGNAL guess_cell_colors  : INT_ARRAY_2D (0 TO 12, 0 TO 3) := (OTHERS => (OTHERS => 4));
    SIGNAL key_cell_colors    : INT_ARRAY_2D (0 TO 12, 0 TO 3) := (12 => (OTHERS => 0), OTHERS => (OTHERS => 11));
    SIGNAL color_panel_colors : INT_ARRAY_2D (0 TO 5, 0 TO 0) := (OTHERS => (OTHERS => 0));
 
    --the game code to be solved
    SIGNAL game_code : INT_ARRAY_2D (0 TO 0, 0 TO 3) := (0 => (5, 6, 7, 8));
 
    --definition of the game board cell
    SIGNAL game_board : CELL := (8, 
        NULL_H + SCREEN_BORDER, NULL_V + SCREEN_BORDER, 
                BOARD_H, BOARD_V
    );
 
    --definition of the pin selection cell
    SIGNAL pin_selection : SELECTION_CELL := (3, 
        NULL_H + SCREEN_BORDER + BOARD_BORDER, NULL_V + SCREEN_BORDER + BOARD_BORDER + COLOR_PANEL_V + BOARD_BORDER + 4 * CELL_SIDE, 
                CELL_SIDE, CELL_SIDE, 0, 4
    );
 
    --definition of the color selection cell
    SIGNAL color_selection : SELECTION_CELL := (3, 
        NULL_H + SCREEN_BORDER + 2 * BOARD_BORDER - COLOR_SELECTION_BORDER, NULL_V + SCREEN_BORDER + 2 * BOARD_BORDER - COLOR_SELECTION_BORDER, 
                COLOR_SELECTION_SIDE, COLOR_SELECTION_SIDE, 0, 0
    );
 
    --definition of the score bar cell
    SIGNAL score_bar : CELL := (14, 
                NULL_H + SCREEN_BORDER + 30, TOT_V - SCREEN_BORDER, 
                score, KEYPIN_SIDE
    );
 
BEGIN
    --a process for initializing the color selection panel and color schemes
    --could have been done manually
    initialization : PROCESS IS
    BEGIN
        FOR i IN 0 TO 5 LOOP
            color_panel_colors(i, 0) <= i + 5;
        END LOOP;
        --assign some color schemes that can be used
        color_scheme(0) <= color_set_0;
        color_scheme(1) <= color_set_1;
        color_scheme(2) <= color_set_2;
        --other color sets
        FOR j IN 0 TO 15 LOOP
            color_scheme(3)(j) <= NOT color_set_0(j);
        END LOOP;
        WAIT;
    END PROCESS;
 
    --process to update the game on clock signals
    update : PROCESS (clk_25m, clk_10, clk_1, reset) IS
        --variables to be used in the game logic
        VARIABLE num_of_red_key_pins    : INTEGER RANGE 0 TO 4;
        VARIABLE num_of_white_key_pins  : INTEGER RANGE 0 TO 4;
        VARIABLE counted_guess_elements : std_logic_vector(0 TO 3);
        VARIABLE counted_code_elements  : std_logic_vector(0 TO 3);
        
        VARIABLE clk_count_10 : INTEGER := 0;
    BEGIN
        IF rising_edge(clk_10) THEN
            --score control
            IF reset = '0' AND in_game = '1' AND score > 0 THEN
                clk_count_10 := clk_count_10 + 1;
                
                --decrement score by guess submission
                IF center = '1' AND pin_selection(6) = 0 THEN
                    IF score > 10 THEN
                        score <= score - 10;
                    ELSE
                        score <= 0;
                    END IF;
                --decrement score by time
                ELSIF clk_count_10 >= 10 THEN
                    clk_count_10 := 0;
                    score <= score - 2;
                END IF;
                
            --if game lost, reset score to 0
            ELSIF in_game = '0' AND game_won = '0' THEN
                score <= 0;
            --if game reset, reset score to 500
            ELSIF reset = '1' THEN
                clk_count_10 := 0;
                score <= 500;
            END IF;
            
            --reset control
            IF reset = '1' THEN
                --generate a random code
                game_code <= (0 => ((HPOS_cur MOD 6) + 5, (VPOS_cur MOD 6) + 5, ((HPOS_cur * VPOS_cur) MOD 6) + 5, ((HPOS_cur/VPOS_cur) MOD 6) + 5));
                --reset cell colors, selections and game status
                guess_cell_colors <= (OTHERS => (OTHERS => 4));
                key_cell_colors   <= (12 => (OTHERS => 0), OTHERS => (OTHERS => 11));
                pin_selection     <= (3, 
                    NULL_H + SCREEN_BORDER + BOARD_BORDER, 
                    NULL_V + SCREEN_BORDER + BOARD_BORDER + COLOR_PANEL_V + BOARD_BORDER + 4 * CELL_SIDE, 
                    CELL_SIDE, CELL_SIDE, 0, 4);
                color_selection <= (3, 
                    NULL_H + SCREEN_BORDER + 2 * BOARD_BORDER - COLOR_SELECTION_BORDER, 
                    NULL_V + SCREEN_BORDER + 2 * BOARD_BORDER - COLOR_SELECTION_BORDER, 
                    COLOR_SELECTION_SIDE, COLOR_SELECTION_SIDE, 0, 0);
                in_game <= '1';

            ELSIF in_game = '1' THEN
                --control left and right
                IF left = '1' AND right = '0' AND color_selection(5) > 0 THEN
                    color_selection(1) <= color_selection(1) - 2 * CELL_SIDE;
                    color_selection(5) <= color_selection(5) - 1;
                ELSIF left = '0' AND right = '1' AND color_selection(5) < 5 THEN
                    color_selection(1) <= color_selection(1) + 2 * CELL_SIDE;
                    color_selection(5) <= color_selection(5) + 1;
                    
                --control up and down
                ELSIF up = '1' AND down = '0' AND pin_selection(6) > 0 THEN
                    pin_selection(2) <= pin_selection(2) - CELL_SIDE;
                    pin_selection(6) <= pin_selection(6) - 1;
                ELSIF up = '0' AND down = '1' AND pin_selection(6) < 4 THEN
                    pin_selection(2) <= pin_selection(2) + CELL_SIDE;
                    pin_selection(6) <= pin_selection(6) + 1;
                    
                --control center button
                ELSIF center = '1' THEN
                    --submit guess
                    IF pin_selection(6) = 0 AND pin_selection(5) < TOT_GUESS_NUMBER THEN
                        num_of_white_key_pins  := 0;
                        num_of_red_key_pins    := 0;
                        counted_guess_elements := "0000";
                        counted_code_elements  := "0000";
                        --determine number of key pins
                        FOR i IN 0 TO 3 LOOP
                            IF guess_cell_colors(pin_selection(5), i) = game_code(0, i) THEN
                                num_of_red_key_pins       := num_of_red_key_pins + 1;
                                counted_guess_elements(i) := '1';
                                counted_code_elements(i)  := '1';
                            END IF;
                        END LOOP;
                        
                        FOR i IN 0 TO 3 LOOP
                            FOR j IN 0 TO 3 LOOP
                                IF counted_guess_elements(i) = '0' AND counted_code_elements(j) = '0' AND
                                 guess_cell_colors(pin_selection(5), i) = game_code(0, j) THEN
 
                                    num_of_white_key_pins     := num_of_white_key_pins + 1;
 
                                    counted_guess_elements(i) := '1';
                                    counted_code_elements(j)  := '1';
 
                                    EXIT;
                                END IF;
                            END LOOP;
                        END LOOP;
                        
                        --update key pin colors
                        FOR j IN 0 TO 3 LOOP
                            IF j < num_of_red_key_pins THEN
                                key_cell_colors(pin_selection(5), j) <= 13;
                            ELSIF j < num_of_red_key_pins + num_of_white_key_pins THEN
                                key_cell_colors(pin_selection(5), j) <= 12;
                            END IF;
                        END LOOP;
                            
                        --determine if game is over or continuing
                        --game won
                        IF num_of_red_key_pins = 4 THEN
                            FOR j IN 0 TO 3 LOOP
                                guess_cell_colors(TOT_GUESS_NUMBER, j) <= game_code(0, j);
                                key_cell_colors(TOT_GUESS_NUMBER, j)   <= 13;
                            END LOOP;
                            
                            game_won <= '1';
                            in_game  <= '0';
                            
                        --game lost
                        ELSIF pin_selection(5) = TOT_GUESS_NUMBER - 1 AND num_of_red_key_pins /= 4 THEN
                            FOR j IN 0 TO 3 LOOP

                                -- for j in 0 to 3 loop

                                guess_cell_colors(TOT_GUESS_NUMBER, j) <= game_code(0, j);

                                key_cell_colors(TOT_GUESS_NUMBER, j)   <= 11;

                                -- end loop;

                            END LOOP;

                            game_won <= '0';
                            in_game  <= '0';

                            --game ongoing
                        ELSIF pin_selection(5) < TOT_GUESS_NUMBER - 1 THEN
                            pin_selection(1) <= pin_selection(1) + CELL_SIDE;
                            pin_selection(2) <= pin_selection(2) + 4 * CELL_SIDE;
                            pin_selection(5) <= pin_selection(5) + 1;
                            pin_selection(6) <= 4;

                        END IF;

                    --change the currently selected element color
                    ELSE
                        guess_cell_colors (pin_selection(5), pin_selection(6) - 1) <= color_selection(5) + 5;
                    END IF;
                END IF;
            END IF;
        END IF;

        --
        IF rising_edge(clk_25m) THEN

            --determine if inside a color cell
            loop1 : FOR i IN 0 TO 12 LOOP
                FOR j IN 0 TO 3 LOOP
                    IF (HPOS_cur > NULL_H + SCREEN_BORDER + BOARD_BORDER + i * CELL_SIDE + CELL_BORDER AND
                     HPOS_cur < NULL_H + SCREEN_BORDER + BOARD_BORDER + i * CELL_SIDE + CELL_BORDER + ELEMENT_SIDE) AND
                     (VPOS_cur > NULL_V + SCREEN_BORDER + BOARD_BORDER + COLOR_PANEL_V + BOARD_BORDER + CELL_SIDE + j * CELL_SIDE + CELL_BORDER AND
                     VPOS_cur < NULL_V + SCREEN_BORDER + BOARD_BORDER + COLOR_PANEL_V + BOARD_BORDER + CELL_SIDE + j * CELL_SIDE + CELL_BORDER + ELEMENT_SIDE) THEN

                        FOR k IN 4 TO 10 LOOP
                            IF guess_cell_colors(i, j) = k THEN
                                show_color(k) <= '1';
                            ELSE
                                show_color(k) <= '0';
                            END IF;
                        END LOOP;

                        EXIT loop1; --exit if inside a cell already

                    ELSIF (HPOS_cur > NULL_H + SCREEN_BORDER + BOARD_BORDER + i * CELL_SIDE + CELL_BORDER + (j MOD 2) * (KEYPIN_SIDE + KEYPIN_BORDER) AND
                        HPOS_cur < NULL_H + SCREEN_BORDER + BOARD_BORDER + i * CELL_SIDE + CELL_BORDER + (j MOD 2) * (KEYPIN_SIDE + KEYPIN_BORDER) + KEYPIN_SIDE) AND
                        (VPOS_cur > NULL_V + SCREEN_BORDER + BOARD_BORDER + COLOR_PANEL_V + BOARD_BORDER + CELL_BORDER + (j / 2) * (KEYPIN_SIDE + KEYPIN_BORDER) AND
                        VPOS_cur < NULL_V + SCREEN_BORDER + BOARD_BORDER + COLOR_PANEL_V + BOARD_BORDER + CELL_BORDER + (j / 2) * (KEYPIN_SIDE + KEYPIN_BORDER) + KEYPIN_SIDE) THEN

                        FOR k IN 11 TO 13 LOOP
                            IF key_cell_colors(i, j) = k THEN
                                show_color(k) <= '1';
                            ELSE
                                show_color(k) <= '0';
                            END IF;
                        END LOOP;

                        EXIT loop1; --exit if inside a cell already

                    ELSE
                        show_color(4 TO 13) <= (OTHERS => '0');
                    END IF;
                END LOOP;

                IF (i < 6) THEN
                    IF (HPOS_cur > NULL_H + SCREEN_BORDER + 2 * BOARD_BORDER + i * (CELL_SIDE + 2 * BOARD_BORDER) AND
                     HPOS_cur < NULL_H + SCREEN_BORDER + 2 * BOARD_BORDER + i * (CELL_SIDE + 2 * BOARD_BORDER) + CELL_SIDE) AND
                     (VPOS_cur > NULL_V + SCREEN_BORDER + 2 * BOARD_BORDER AND
                     VPOS_cur < NULL_V + SCREEN_BORDER + 2 * BOARD_BORDER + CELL_SIDE) THEN

                        FOR k IN 5 TO 10 LOOP
                            IF color_panel_colors(i, 0) = k THEN
                                show_color(k) <= '1';
                            ELSE
                                show_color(k) <= '0';
                            END IF;
                        END LOOP;

                        EXIT loop1; --exit if inside a cell already

                    ELSE
                        show_color(5 TO 10) <= (OTHERS => '0');
                    END IF;
                END IF;
            END LOOP;

            HPOS_cur <= HPOS_next;
            VPOS_cur <= VPOS_next;
            rgb_cur  <= rgb_next;
        END IF;
    END PROCESS;
    
    reset               <= switch(0);

    color_scheme_select <= conv_integer(switch(2 DOWNTO 1));

    --background
    show_color(1) <= '1' WHEN (HPOS_cur > NULL_H + 1 AND HPOS_cur < TOT_H - 1) AND
                     (VPOS_cur > NULL_V + 1 AND VPOS_cur < TOT_V) ELSE
                     '0';
    --board 
    show_color(2) <= '1' WHEN (HPOS_cur > game_board(1) AND HPOS_cur < game_board(1) + game_board(3)) AND
                     (VPOS_cur > game_board(2) AND VPOS_cur < game_board(2) + game_board(4)) ELSE
                     '0';

    --selection
    show_color(3) <= '1' WHEN ((HPOS_cur > pin_selection(1) AND HPOS_cur < pin_selection(1) + pin_selection(3)) AND
                     (VPOS_cur > pin_selection(2) AND VPOS_cur < pin_selection(2) + pin_selection(4)))
                     OR
                     ((HPOS_cur > color_selection(1) AND HPOS_cur < color_selection(1) + color_selection(3)) AND
                     (VPOS_cur > color_selection(2) AND VPOS_cur < color_selection(2) + color_selection(4))) ELSE
                     '0';

    --score bar
    show_color(14) <= '1' WHEN (HPOS_cur > score_bar(1) AND HPOS_cur < score_bar(1) + score) AND
                      (VPOS_cur > score_bar(2) AND VPOS_cur < score_bar(2) + score_bar(4)) ELSE
                      '0';

    --frame
    show_color(15) <= '1' WHEN (((VPOS_cur = NULL_V + 1) OR (VPOS_cur = TOT_V)) AND (HPOS_cur > NULL_H AND HPOS_cur <= TOT_H)) OR
                      (((HPOS_cur = NULL_H + 1) OR (HPOS_cur = TOT_H - 1)) AND (VPOS_cur > NULL_V AND VPOS_cur <= TOT_V)) ELSE
                      '0';
    
    --scanning through pixels
    HPOS_next <= HPOS_cur + 1 WHEN HPOS_cur < TOT_H ELSE
                 1;
    VPOS_next <= VPOS_cur + 1 WHEN HPOS_cur = TOT_H AND VPOS_cur < TOT_V ELSE
                 1 WHEN HPOS_cur = TOT_H AND VPOS_cur = TOT_V ELSE
                 VPOS_cur;

    --rgb setting
    --colors are arranged as layers
    --layers of colors are in a way put on top of each other to produce the rgb signal
    rgb_next <= color_scheme(color_scheme_select)(15) WHEN show_color(15) = '1' ELSE
                color_scheme(color_scheme_select)(14) WHEN show_color(14) = '1' ELSE
                color_scheme(color_scheme_select)(13) WHEN show_color(13) = '1' ELSE
                color_scheme(color_scheme_select)(12) WHEN show_color(12) = '1' ELSE
                color_scheme(color_scheme_select)(11) WHEN show_color(11) = '1' ELSE
                color_scheme(color_scheme_select)(10) WHEN show_color(10) = '1' ELSE
                color_scheme(color_scheme_select)(9) WHEN show_color(9) = '1' ELSE
                color_scheme(color_scheme_select)(8) WHEN show_color(8) = '1' ELSE
                color_scheme(color_scheme_select)(7) WHEN show_color(7) = '1' ELSE
                color_scheme(color_scheme_select)(6) WHEN show_color(6) = '1' ELSE
                color_scheme(color_scheme_select)(5) WHEN show_color(5) = '1' ELSE
                color_scheme(color_scheme_select)(4) WHEN show_color(4) = '1' ELSE
                color_scheme(color_scheme_select)(3) WHEN show_color(3) = '1' ELSE
                color_scheme(color_scheme_select)(2) WHEN show_color(2) = '1' ELSE
                color_scheme(color_scheme_select)(1) WHEN show_color(1) = '1' ELSE
                COLOR_BLACK;

    --syncronization signals
    HSYNC      <= '0' WHEN (HPOS_cur > FP_H) AND (HPOS_cur < FP_H + SP_H + 1) ELSE '1';
    VSYNC      <= '0' WHEN (VPOS_cur > FP_V) AND (VPOS_cur < FP_V + SP_V + 1) ELSE '1';
    R          <= rgb_cur(11 DOWNTO 8);
    G          <= rgb_cur(7 DOWNTO 4);
    B          <= rgb_cur(3 DOWNTO 0);

    game_score <= score;

END MAIN;