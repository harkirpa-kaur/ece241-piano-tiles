// Copyright (c) 2020 FPGAcademy
// Please see license at https://github.com/fpgacademy/DESim
`include "vga_adapter_desim.v"

module top (CLOCK_50, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, VGA_X, VGA_Y, VGA_COLOR, plot, state, t, x, y);

    input CLOCK_50;             // DE-series 50 MHz clock signal
    input wire [9:0] SW;        // DE-series switches
    input wire [3:0] KEY;       // DE-series pushbuttons

    output wire [6:0] HEX0;     // DE-series HEX displays
    output wire [6:0] HEX1;
    output wire [6:0] HEX2;
    output wire [6:0] HEX3;
    output wire [6:0] HEX4;
    output wire [6:0] HEX5;

    output wire [9:0] x;
    output wire [8:0] y;
    wire [8:0] color;
    wire done_spawn, done_shift;
    wire [1:0] spawn_tile_x, shift_tile_x, shift_tile_y;
    wire [9:0] spawn_VGA_x;
    wire [8:0] spawn_VGA_Y;

   output wire [9:0] VGA_X;
   output wire [8:0] VGA_Y;
   output wire [23:0] VGA_COLOR;
   output wire plot;
	 
	// output wire [7:0] VGA_R;
	// output wire [7:0] VGA_G;
	// output wire [7:0] VGA_B;
	// output wire VGA_HS;
	// output wire VGA_VS;
	// output wire VGA_BLANK_N;
	// output wire VGA_SYNC_N;
	// output wire VGA_CLK;	


    output wire [9:0] LEDR;     // DE-series LEDs   
    output wire [2:0] state;
    output wire t;

    //led U1 (CLOCK_50, KEY[0], LEDR[3:0], t, index, sr, srd);
    test U2 (CLOCK_50, KEY[0], LEDR[3:0], x, y, color, state);
    //  vga_adapter VGA(
    //      .resetn(KEY[0]),
    //      .clock(CLOCK_50),
    //      .color(color),
    //      .x(x),
    //      .y(y),
    //      .write(KEY[0]),
    //      .VGA_R(VGA_R),
    //      .VGA_G(VGA_G),
    //      .VGA_B(VGA_B),
    //      .VGA_HS(VGA_HS),
    //      .VGA_VS(VGA_VS),
    //      .VGA_BLANK_N(VGA_BLANK_N),
    //      .VGA_SYNC_N(VGA_SYNC_N),
    //      .VGA_CLK(VGA_CLK)
    //  );

   vga_adapter_desim VGA_DESIM (
       .resetn(KEY[0]),
       .clock(CLOCK_50),
       .color(color),
       .x(x), 
       .y(y), 
       .write(KEY[0]),
       .VGA_X(VGA_X), 
       .VGA_Y(VGA_Y), 
       .VGA_COLOR(VGA_COLOR), 
       .VGA_SYNC(),
       .plot(plot)
   );
    
endmodule