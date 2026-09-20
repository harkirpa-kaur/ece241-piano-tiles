// Copyright (c) 2020 FPGAcademy
// Please see license at https://github.com/fpgacademy/DESim
module top (CLOCK_50, SW, KEY, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, expected, timer, t, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK,  FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK, AUD_ADCDAT);

    input wire CLOCK_50;             // DE-series 50 MHz clock signal
    input wire [9:0] SW;        // DE-series switches
    input wire [3:0] KEY;       // DE-series pushbuttons
    inout wire PS2_CLK;
    inout wire PS2_DAT;

    output wire [6:0] HEX0;     // DE-series HEX displays
    output wire [6:0] HEX1;
    output wire [6:0] HEX2;
    output wire [6:0] HEX3;
    output wire [6:0] HEX4;
    output wire [6:0] HEX5;

	output wire [7:0] VGA_R;
	output wire [7:0] VGA_G;
	output wire [7:0] VGA_B;
	output wire VGA_HS;
	output wire VGA_VS;
	output wire VGA_BLANK_N;
	output wire VGA_SYNC_N;
	output wire VGA_CLK;

	output wire [9:0] LEDR;

	wire [7:0] start_x, game_x, win_x, lose_x;
	wire [6:0] start_y, game_y, win_y, lose_y;
	wire [8:0] start_color, game_color, win_color, lose_color;
    wire start_write, game_write, win_write, lose_write;
    wire resetn; 
	
    assign resetn = KEY[0];
    wire change_screen;

    reg ff1, ff2;
	 
    always @ (posedge CLOCK_50)
        begin
            if(!resetn)
                begin
                    ff1 <= 1'b1;
                    ff2 <= 1'b1; 
                end
            else
                begin
                    ff1 <= KEY[1];
                    ff2 <= ff1; 
                end
        end

    //change_screen is for start->game, lose->start, win->start
    assign change_screen = (ff2) && (!ff1);

    reg [1:0] screen_to_draw = 2'b00;
    reg [8:0] q1, q2, q3, q4; 

	 lose	lose_inst (
	.address ( screen_address ),
	.clock ( CLOCK_50 ),
	.q ( lose_color )
	);

    start	start_inst (
	.address ( screen_address ),
	.clock ( CLOCK_50 ),
	.q ( start_color )
	);

    win	win_inst (
	.address ( screen_address ),
	.clock ( CLOCK_50 ),
	.q ( win_color )
	);

    // state codes for FSM that choses which object to draw at a given time
    parameter START = 2'b00, GAME = 2'b01, LOSE = 2'b10, WIN = 2'b11;

    parameter SCREEN_HEIGHT = 120;
    parameter SCREEN_WIDTH = 160; 

    reg [7:0] draw_x, x;
    reg [6:0] draw_y, y; 
    reg drawing, write; 
	 reg [8:0] color; 

    wire [14:0] screen_address; 
    assign screen_address = draw_y * SCREEN_WIDTH + draw_x; 

    //parameters for the state of the game
    parameter PAUSE = 2'd0, SCORE = 2'd1, MISS = 2'd2;

    parameter WIN_SCORE = 100;

	 wire [6:0] score;

reg play_heehee = 1'b0;
reg prev_score_state = 1'b0;

always @ (posedge CLOCK_50)
begin
    if(!resetn)
    begin
        play_heehee <= 1'b0;
        prev_score_state <= 1'b0;
    end
    else
    begin
        prev_score_state <= (click_state == SCORE);
        
        // Trigger on rising edge of SCORE state or KEY[2]
        if ((click_state == SCORE && !prev_score_state) || ~KEY[2])
            play_heehee <= 1'b1;
        else
            play_heehee <= 1'b0;
    end
end

always @ (posedge CLOCK_50)
begin
    if(!resetn)
    begin
        screen_to_draw <= START;
        start_game <= 1'b0;  // Reset start_game
    end
    else  // Add this else!
    begin        
        case (screen_to_draw)
            START: 
            begin
                if (change_screen)
                begin
                    screen_to_draw <= GAME;
                    start_game <= 1'b1;  // Pulse start_game for one cycle
                end
                else
                    screen_to_draw <= START;
            end
            GAME: screen_to_draw <= click_state == MISS ? LOSE : score == WIN_SCORE ? WIN : GAME;
            WIN: screen_to_draw <= change_screen ? START : WIN;
            LOSE: screen_to_draw <= change_screen ? START : LOSE;
            default: screen_to_draw <= START;
        endcase
    end
end
    
    reg start_game = 1'b0; 

    //painter FSM
    always @ (posedge CLOCK_50)
    begin
        if(!resetn)
            begin
                //reset everything when KEY[0]
                drawing <= 1'b1;
                draw_x = 8'b0;
                draw_y = 7'b0; 
                x = 8'b0;
                y = 7'b0;
                color = 9'b0; 
                write <= 1'b0; 
            end
        else 
            begin
                write <= 1'b0; 
                //if(change_screen)
                    //begin
                        drawing <= 1'b1; 
                    //end
                
                if(drawing)
                    begin

                        case (screen_to_draw)
                            START: 
                                begin
                                    x <= draw_x;
                                    y <= draw_y; 
                                    color <= start_color;
                                end
                            GAME: 
                                begin 
                                    x <= game_x;
                                    y <= game_y;
                                    color <= game_color;
                                end
                            WIN: 
                                begin
                                    x <= draw_x;
                                    y <= draw_y; 
                                    color <= win_color;
                                end
                            LOSE: 
                                begin
                                    x <= draw_x;
                                    y <= draw_y; 
                                    color <= lose_color; 
                                end
                            default: color <= 9'h5a; 
                        endcase

                        write <= 1'b1; 

                        if(draw_x == SCREEN_WIDTH - 1)
                            begin
                                draw_x <= 8'd0;
                                if(draw_y == SCREEN_HEIGHT - 1)
                                    begin
                                        draw_y <= 7'd0; 
                                        drawing <= 1'b0; 
                                    end
                                else
                                    begin
                                        draw_y <= draw_y + 1'b1; 
                                    end
                            end
                        else
                            begin
                                draw_x <= draw_x + 1'b1; 
                            end
                    end
            end
    end
	


   wire [1:0] click_state;
   wire [7:0] scancode, expected_key; 
	output wire [7:0] expected;
   wire ps2_rec;
    wire [2:0] state;
    wire [1:0] fake_led;

    output wire t;
    output wire timer;
	 
	 wire[1:0] tilestate1, tilestate2, tilestate3; 

    //led U1 (CLOCK_50, KEY[0], LEDR[3:0], t, index, sr, srd);
    test U2 (CLOCK_50, KEY[0], fake_led, game_x, game_y, game_color, state, t, click_state, ps2_rec, scancode, expected_key, start_game);
     vga_adapter VGA(
         .resetn(KEY[0]),
         .clock(CLOCK_50),
         .color(color),
         .x(x),
         .y(y),
         .write(write),
         .VGA_R(VGA_R),
         .VGA_G(VGA_G),
         .VGA_B(VGA_B),
         .VGA_HS(VGA_HS),
         .VGA_VS(VGA_VS),
         .VGA_BLANK_N(VGA_BLANK_N),
         .VGA_SYNC_N(VGA_SYNC_N),
         .VGA_CLK(VGA_CLK)
     );

wire fake;
wire [6:0] fake_leds;

wire [6:0] fake_HEX0, fake_HEX1, fake_HEX2, fake_HEX3, fake_HEX4, fake_HEX5;

ps2_demo ps2 (CLOCK_50, KEY[0], PS2_CLK, PS2_DAT, fake_HEX0, fake_HEX1, fake_HEX2, fake_HEX3, fake_HEX4, fake_HEX5, scancode, ps2_rec, fake);

keyboard kbd (CLOCK_50, KEY[0], scancode, t, fake_leds, click_state, expected, HEX0, HEX1, HEX2, score, start_game);

inout wire AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK,  FPGA_I2C_SDAT;
input wire AUD_ADCDAT;
output wire AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK;

audio_demo A1 (CLOCK_50, KEY[0], play_heehee, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK);

assign LEDR[6:0] = score;
assign LEDR [9] = play_heehee;
assign HEX3 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;
endmodule