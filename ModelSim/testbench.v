`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    wire [3:0] LEDR;
	wire [3:0] KEY;
	reg CLOCK_50;
	wire t;
	wire [7:0] index;

	wire [9:0] VGA_X;
	wire [8:0] VGA_Y;
	wire [2:0] VGA_COLOR;
	wire done_shift, done_spawn;
	
	wire [1:0] spawn_tile_x, shift_tile_x, shift_tile_y;
	wire [9:0] spawn_VGA_X;
	wire [8:0] spawn_VGA_Y;

	wire [2:0] state;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end

	//led U1 (CLOCK_50, KEY[0], LEDR[3:0], t, index, sr, srd);
    test U2 (CLOCK_50, KEY[0], LEDR[3:0], x, y, color, state, t);
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

// vga_adapter_desim VGA_DESIM (
//        .resetn(KEY[0]),
//        .clock(CLOCK_50),
//        .color(color),
//        .x(x), 
//        .y(y), 
//        .write(KEY[0]),
//        .VGA_X(VGA_X), 
//        .VGA_Y(VGA_Y), 
//        .VGA_COLOR(VGA_COLOR), 
//        .VGA_SYNC(),
//        .plot(plot)
//    );

   wire [7:0] received_data;
   wire received_data_en;
   wire lose, break;
     wire PS2_CLK;
     wire PS2_DAT;

    ps2_demo ps2 (CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, scancode, ps2_rec);


endmodule
