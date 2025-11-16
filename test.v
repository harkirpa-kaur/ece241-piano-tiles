module test (CLOCK_50, KEY, sr, srd, VGA_X, VGA_Y, VGA_COLOR);
	input CLOCK_50;
    input KEY;
	input [3:0] sr, srd;
	wire reset = KEY;

	wire [3:0] sr, srd;
	reg mode_shift = 1'b0;
	wire done_spawn, done_shift;
	wire [9:0] spawn_VGA_X, shift_VGA_X;
	wire [8:0] spawn_VGA_Y, shift_VGA_Y;
	wire [2:0] spawn_VGA_COLOR, shift_VGA_COLOR;
	output reg [9:0] VGA_X;
	output reg [8:0] VGA_Y;
	output reg [2:0] VGA_COLOR;

	reg in_sr, in_srd;
	reg [1:0] spawn_tile_x = 2'd0, shift_tile_y = 2'd0;

	//counter for spawning tiles
	always @ (posedge CLOCK_50)
	begin
		if (!reset)
		begin
			spawn_tile_x <= 2'b00;
			shift_tile_y <= 2'b00;
			in_sr <= sr[0];
			in_srd <= srd[0];
		end
		else if (spawn_tile_x != 2'd3)
			begin
				spawn_tile_x <= spawn_tile_x + 1;
			end
		else
			begin
				spawn_tile_x <= 2'b00;
				if (shift_tile_y != 2'd3)
					shift_tile_y <= shift_tile_y + 1;
				else
					shift_tile_y <= 2'b00;
			end
		in_sr <= sr[spawn_tile_x];
		in_srd <= srd[spawn_tile_x];
	end
	//logic to switch between spawning and shifting

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			mode_shift <= 1'b0;
		else if (done_spawn == 1'b1)
			mode_shift <= 1'b1;
		else if (done_shift == 1'b1)
			mode_shift <= 1'b0;
	end

	always @ (posedge CLOCK_50)
	begin
		if (mode_shift)
		begin
			VGA_X <= shift_VGA_X;
			VGA_Y <= shift_VGA_Y;
			VGA_COLOR <= shift_VGA_COLOR;
		end
		else
		begin
			VGA_X <= spawn_VGA_X;
			VGA_Y <= spawn_VGA_Y;
			VGA_COLOR <= spawn_VGA_COLOR;
		end
	end

    spawn_tile dt (in_sr, spawn_tile_x, 2'd0, CLOCK_50, reset, done_spawn, spawn_VGA_X, spawn_VGA_Y, spawn_VGA_COLOR);
	shift_tile st (reset, CLOCK_50, spawn_tile_x, shift_tile_y, sr_delay, done_shift, shift_VGA_X, shift_VGA_Y, shift_VGA_COLOR);
endmodule

module spawn_tile (sr, tile_x, tile_y, CLOCK_50, reset, done_spawn, VGA_X, VGA_Y, VGA_COLOR);
    input sr;
    //gives index of tile (4x4)
    input [1:0] tile_x;
    input [1:0] tile_y;
    input CLOCK_50;
    input reset;

    output reg done_spawn;
    output reg [9:0] VGA_X = 10'd0;
    output reg [8:0] VGA_Y = 9'd0;
    output reg [2:0] VGA_COLOR;

    //cycles through pixels of a 160x120 tile
    always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            VGA_X <= tile_x * 10'd160;
            VGA_Y <= tile_y * 9'd120;
			VGA_COLOR <= 3'b010;
            done_spawn <= 1'b0;
        end
        else
        begin
			if (sr == 1'b1)
				VGA_COLOR <= 3'b111; //white
			else
				VGA_COLOR <= 3'b010; //green

            done_spawn <= 1'b0;

            if (VGA_X == (tile_x * 10'd160) + 10'd159)
            begin
                VGA_X <= tile_x * 10'd160;
                if (VGA_Y == (tile_y * 9'd120) + 9'd119)
                begin
                    VGA_Y <= tile_y * 9'd120;
                    done_spawn <= 1'b1;
                end
                else 
                begin
                    VGA_Y <= VGA_Y + 1;
                end
            end
            else
            begin
                VGA_X <= VGA_X + 1;
            end
        end
    end

endmodule

module shift_tile (reset, CLOCK_50, tile_x, tile_y, srd, done_shift, VGA_X, VGA_Y, VGA_COLOR);
	input CLOCK_50;
	input reset;
	input [1:0] tile_x;
	input [1:0] tile_y;
	input srd;
	output reg done_shift;
	output reg [9:0] VGA_X;
	output reg [8:0] VGA_Y;
	output reg [2:0] VGA_COLOR;	

	always @ (posedge CLOCK_50)
    begin
        if (reset)
        begin
            VGA_X <= tile_x * 10'd160;
            VGA_Y <= tile_y * 9'd120;
			VGA_COLOR <= 3'b111;
            done_shift <= 1'b0;
        end
        else
        begin
			if (srd == 1'b1)
				VGA_COLOR <= 3'b111; //white
			else
				VGA_COLOR <= 3'b010; //green

            done_shift <= 1'b0;

            if (VGA_X == (tile_x * 10'd160) + 10'd159)
            begin
                VGA_X <= tile_x * 10'd160;
                if (VGA_Y == (tile_y * 9'd120) + 9'd119)
                begin
                    VGA_Y <= tile_y * 9'd120;
                    done_shift <= 1'b1;
                end
                else 
                begin
                    VGA_Y <= VGA_Y + 1;
                end
            end
            else
            begin
                VGA_X <= VGA_X + 1;
            end
        end
    end

endmodule