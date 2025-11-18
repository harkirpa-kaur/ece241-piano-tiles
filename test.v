`include "led.v"

module test (CLOCK_50, KEY, LEDR, VGA_X, VGA_Y, VGA_COLOR, done_spawn, t, sr, srd1, srd2, srd3);
	input wire CLOCK_50;
	input wire KEY;
	input CLOCK_50;
    input KEY;
	wire reset = KEY;

	output [3:0] sr, srd1, srd2, srd3;
	output wire done_spawn;
	wire done_shift1, done_shift2, done_shift3;
	wire [9:0] spawn_VGA_X;
	wire [9:0] shift_VGA_X1, shift_VGA_X2, shift_VGA_X3;
	wire [8:0] spawn_VGA_Y;
	wire [8:0] shift_VGA_Y1, shift_VGA_Y2, shift_VGA_Y3;
	wire [2:0] spawn_VGA_COLOR, shift_VGA_COLOR1, shift_VGA_COLOR2, shift_VGA_COLOR3;
	output reg [9:0] VGA_X;
	output reg [8:0] VGA_Y;
	output reg [2:0] VGA_COLOR;
	output [3:0] LEDR;

	reg [2:0] spawn_count, shift_count1, shift_count2, shift_count3;

	output t;
	reg start;
	parameter SPAWN = 3'b000, SHIFT1 = 3'b001, SHIFT2 = 3'b010, SHIFT3 = 3'b011, WAIT = 3'b100;
	reg [2:0] state = WAIT, next_state;

	reg [1:0] spawn_tile_x = 2'd0, shift_tile_x1 = 2'd0, shift_tile_x2 = 2'd0, shift_tile_x3 = 2'd0;

	led ld (CLOCK_50, KEY, LEDR, t, sr, srd1, srd2, srd3);

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			start <= 1'b0;
		else if (t)
			start <= 1'b1;
	end
  
	// counters for number of spawn and shift operations

	always @ (posedge done_spawn)
	begin
		if (!reset)
			spawn_count <= 3'd0;
		else if (spawn_count < 3'd4)
			spawn_count <= spawn_count + 1;
		else
			spawn_count <= 3'd0;
	end

	always @ (posedge done_shift1)
	begin
		if (!reset)
			shift_count1 <= 3'd0;
		else if (shift_count1 < 3'd4)
			shift_count1 <= shift_count1 + 1;
		else
			shift_count1 <= 3'd0;
	end

	always @ (posedge done_shift2)
	begin
		if (!reset)
			shift_count2 <= 3'd0;
		else if (shift_count2 < 3'd4)
			shift_count2 <= shift_count2 + 1;
		else
			shift_count2 <= 3'd0;
	end

	always @ (posedge done_shift3)
	begin
		if (!reset)
			shift_count3 <= 3'd0;
		else if (shift_count3 < 3'd4)
			shift_count3 <= shift_count3 + 1;
		else
			shift_count3 <= 3'd0;
	end

	//counter for spawning tiles over the columns
	always @ (posedge CLOCK_50)
	begin
		if (!reset)
		begin
			spawn_tile_x <= 2'b00;
		end
		else if (spawn_tile_x < 2'd3 && done_spawn)
			begin
				spawn_tile_x <= spawn_tile_x + 1;
			end
		else if (done_spawn)
			begin
				spawn_tile_x <= 2'b00;
			end
	end

	// counter for shifting tiles over the columns
	always @ (posedge CLOCK_50)
	begin
		if (!reset)
		begin
			shift_tile_x1 <= 2'b00;
			shift_tile_x2 <= 2'b00;
			shift_tile_x3 <= 2'b00;
		end
		else if (done_shift1 && state == SHIFT1)
		begin
			if (shift_tile_x1 < 2'd3)
			begin
				shift_tile_x1 <= shift_tile_x1 + 1;
			end
			else 
			begin
				shift_tile_x1 <= 2'b00;
			end
		end
		else if (done_shift2 && state == SHIFT2)
		begin
			if (shift_tile_x2 < 2'd3)
			begin
				shift_tile_x2 <= shift_tile_x2 + 1;
			end
			else 
			begin
				shift_tile_x2 <= 2'b00;
			end
		end
		else if (done_shift3 && state == SHIFT3)
		begin
			if (shift_tile_x3 < 2'd3)
			begin
				shift_tile_x3 <= shift_tile_x3 + 1;
			end
			else 
			begin
				shift_tile_x3 <= 2'b00;
			end
		end
	end


	// logic to set VGA outputs based on state
	always @ (posedge CLOCK_50)
	begin
		if (state == SPAWN)
		begin
			VGA_X <= spawn_VGA_X;
			VGA_Y <= spawn_VGA_Y;
			VGA_COLOR <= spawn_VGA_COLOR;
		end
		else if (state == SHIFT1)
		begin
			VGA_X <= shift_VGA_X1;
			VGA_Y <= shift_VGA_Y1;
			VGA_COLOR <= shift_VGA_COLOR1;
		end
		else if (state == SHIFT2)
		begin
			VGA_X <= shift_VGA_X2;
			VGA_Y <= shift_VGA_Y2;
			VGA_COLOR <= shift_VGA_COLOR2;
		end
		else if (state == SHIFT3)
		begin
			VGA_X <= shift_VGA_X3;
			VGA_Y <= shift_VGA_Y3;
			VGA_COLOR <= shift_VGA_COLOR3;
		end
	end

    spawn_tile dt (sr, spawn_tile_x, 2'd0, CLOCK_50, reset, done_spawn, spawn_VGA_X, spawn_VGA_Y, spawn_VGA_COLOR);
	shift_tile st1 (reset, CLOCK_50, shift_tile_x1, 2'd1, srd1, done_shift1, shift_VGA_X1, shift_VGA_Y1, shift_VGA_COLOR1);
	shift_tile st2 (reset, CLOCK_50, shift_tile_x2, 2'd2, srd2, done_shift2, shift_VGA_X2, shift_VGA_Y2, shift_VGA_COLOR2);
	shift_tile st3 (reset, CLOCK_50, shift_tile_x3, 2'd3, srd3, done_shift3, shift_VGA_X3, shift_VGA_Y3, shift_VGA_COLOR3);

	// state machine to control spawning and shifting


	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			state <= WAIT;
		else
			state <= next_state;
			
		case (state)
			WAIT: begin
				if (start)
					next_state <= SPAWN;
				else
					next_state <= WAIT;
			end
			SPAWN: begin
				if (spawn_count >= 3'd4)
				begin
					next_state <= SHIFT1;
					//done_spawn <= 1'b0;
				end
				else
					next_state <= SPAWN;
			end
			SHIFT1: begin
				if (shift_count1 >= 3'd4)
				begin
					next_state <= SHIFT2;
					//done_shift1 <= 1'b0;
				end
				else
					next_state <= SHIFT1;
			end
			SHIFT2: begin
				if (shift_count2 >= 3'd4)
				begin
					next_state <= SHIFT3;
					//done_shift2 <= 1'b0;
				end
				else
					next_state <= SHIFT2;
			end
			SHIFT3: begin
				if (shift_count3 >= 3'd4)
				begin
					next_state <= SPAWN;
					//done_shift3 <= 1'b0;
				end
				else
					next_state <= SHIFT3;
			end
			default: next_state <= WAIT;
		endcase
	end

endmodule

module spawn_tile (shift_reg, tile_x, tile_y, CLOCK_50, reset, done_spawn, VGA_X, VGA_Y, VGA_COLOR);
    input [3:0] shift_reg;
    //gives index of tile (4x4)
    input [1:0] tile_x;
    input [1:0] tile_y;
    input CLOCK_50;
    input reset;

    output reg done_spawn;
    output reg [9:0] VGA_X = 10'd0;
    output reg [8:0] VGA_Y = 9'd0;
    output reg [2:0] VGA_COLOR;

	//wire [3:0] test = 4'b1010;
	wire sr = shift_reg[tile_x];

    //cycles through pixels of a 160x120 tile
    always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            VGA_X <= tile_x * 10'd160;
            VGA_Y <= tile_y * 9'd120;
			VGA_COLOR <= 3'b010;
            done_spawn <= 2'b0;
        end
        else
        begin
			done_spawn <= 1'b0;
			if (sr == 1'b1)
				VGA_COLOR <= 3'b111; //white
			else if (sr == 1'b0)
				VGA_COLOR <= 3'b010; //green

            if (VGA_X >= (tile_x * 10'd160) + 10'd160)
				begin
					VGA_X <= tile_x * 10'd160;
					if (VGA_Y == 9'd120)
					begin
						VGA_Y <= 9'd0;
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

module shift_tile (reset, CLOCK_50, tile_x, tile_y, shift_reg_delay, done_shift, VGA_X, VGA_Y, VGA_COLOR);
	input CLOCK_50;
	input reset;
	input [1:0] tile_x;
	input [1:0] tile_y;
	input [3:0] shift_reg_delay;

	wire srd = shift_reg_delay[tile_x];

	reg initialized = 1'b0;

	output reg done_shift;
	output reg [9:0] VGA_X;
	output reg [8:0] VGA_Y;
	output reg [2:0] VGA_COLOR;	

	always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            VGA_X <= tile_x * 10'd160;
            VGA_Y <= tile_y * 9'd120;
			VGA_COLOR <= 3'b010;
            done_shift <= 1'b0;
        end
        else
        begin
			done_shift <= 1'b0;
			if (srd == 1'b1)
				VGA_COLOR <= 3'b111; //white
			else if (srd == 1'b0)
				VGA_COLOR <= 3'b010; //green

			if (!initialized)
			begin
				VGA_X <= tile_x * 10'd160;
				VGA_Y <= tile_y * 9'd120;
				initialized <= 1'b1;
			end

            if (VGA_X >= (tile_x * 10'd160) + 10'd160 && initialized)
            begin
                VGA_X <= tile_x * 10'd160;
                if (VGA_Y == (tile_y * 9'd120) + 9'd120)
                begin
                    VGA_Y <= tile_y * 9'd120;
                    done_shift <= 1'b1;
                end
                else 
                begin
                    VGA_Y <= VGA_Y + 1;
                end
            end
            else if (initialized)
            begin
                VGA_X <= VGA_X + 1;
            end
        end
    end

endmodule