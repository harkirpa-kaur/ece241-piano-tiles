// Copyright (c) 2020 FPGAcademy
// Please see license at https://github.com/fpgacademy/DESim

module top (CLOCK_50, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

    input CLOCK_50;             // DE-series 50 MHz clock signal
    input wire [9:0] SW;        // DE-series switches
    input wire [3:0] KEY;       // DE-series pushbuttons

    output wire [6:0] HEX0;     // DE-series HEX displays
    output wire [6:0] HEX1;
    output wire [6:0] HEX2;
    output wire [6:0] HEX3;
    output wire [6:0] HEX4;
    output wire [6:0] HEX5;

    wire [9:0] VGA_X;
    wire [8:0] VGA_Y;
    wire [2:0] VGA_COLOR;


    output wire [9:0] LEDR;     // DE-series LEDs   
    wire t;
    wire [7:0] index;
    wire [3:0] sr, srd;

    led U1 (CLOCK_50, KEY[0], LEDR[3:0], t, index, sr, srd);
    test U2 (CLOCK_50, KEY[0], sr, srd, VGA_X, VGA_Y, VGA_COLOR);
    // vga_adapter VGA(
    //     .reset(KEY[0]),
    //     .clock(CLOCK_50),
    //     .colour(VGA_COLOR),
    //     .x(VGA_X),
    //     .y(VGA_Y),
    //     .write(t),
    //     .VGA_R(),
    //     .VGA_G(),
    //     .VGA_B(),
    //     .VGA_HS(),
    //     .VGA_VS(),
    //     .VGA_BLANK_N(),
    //     .VGA_SYNC_N(),
    //     .VGA_CLK()
    // );

    vga_adapter VGA_DESIM (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .color(VGA_COLOR),
        .x(VGA_X), 
        .y(VGA_Y), 
        .write(t),
        .VGA_X(), 
        .VGA_Y(), 
        .VGA_COLOR(), 
        .VGA_SYNC(),
        .plot()
    );

endmodule

