`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    wire [9:0] LEDR;
	reg CLOCK_50;
	wire t;
	wire [7:0] index;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end

	led U1 (CLOCK_50, LEDR, t, index);

endmodule
