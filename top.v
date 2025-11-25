// Copyright (c) 2020 FPGAcademy
// Please see license at https://github.com/fpgacademy/DESim
`include "vga_adapter_desim.v"
module top (CLOCK_50, SW, KEY, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

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

    wire [7:0] x;
    wire [6:0] y;
    wire [8:0] color;
//     wire done_spawn, done_shift;
//     wire [1:0] spawn_tile_x, shift_tile_x, shift_tile_y;
//     wire [9:0] spawn_VGA_x;
//     wire [8:0] spawn_VGA_Y;

//    output wire [7:0] VGA_X;
//    output wire [6:0] VGA_Y;
//    output wire [23:0] VGA_COLOR;
//    output wire plot;
//     output wire VGA_SYNC;
	output wire [7:0] VGA_R;
	output wire [7:0] VGA_G;
	output wire [7:0] VGA_B;
	output wire VGA_HS;
	output wire VGA_VS;
	output wire VGA_BLANK_N;
	output wire VGA_SYNC_N;
	output wire VGA_CLK;	


   wire [1:0] click_state;
   wire [32:0] Serial;
   wire ps2_rec;
    output wire [9:0] LEDR;     // DE-series LEDs   
    wire [2:0] state;
    wire t;
    wire [3:0] fake_ledr;

    //led U1 (CLOCK_50, KEY[0], LEDR[3:0], t, index, sr, srd);
    test U2 (CLOCK_50, KEY[0], fake_ledr, x, y, color, state, t, click_state, ps2_rec);
     vga_adapter VGA(
         .resetn(KEY[0]),
         .clock(CLOCK_50),
         .color(color),
         .x(x),
         .y(y),
         .write(KEY[0]),
         .VGA_R(VGA_R),
         .VGA_G(VGA_G),
         .VGA_B(VGA_B),
         .VGA_HS(VGA_HS),
         .VGA_VS(VGA_VS),
         .VGA_BLANK_N(VGA_BLANK_N),
         .VGA_SYNC_N(VGA_SYNC_N),
         .VGA_CLK(VGA_CLK)
     );

//    vga_adapter_desim VGA_DESIM (
//        .resetn(KEY[0]),
//        .clock(CLOCK_50),
//        .color(color),
//        .x(x), 
//        .y(y), 
//        .write(KEY[0]),
//        .VGA_X(VGA_X), 
//        .VGA_Y(VGA_Y), 
//        .VGA_COLOR(VGA_COLOR), 
//        .VGA_SYNC(VGA_SYNC),
//        .plot(plot)
//    );



ps2_demo ps2 (CLOCK_50, KEY[0], PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, Serial, ps2_rec, LEDR[9]);


keyboard kbd (CLOCK_50, KEY[0], Serial, ps2_rec, LEDR[7:0], LEDR[8], click_state);




    
endmodule