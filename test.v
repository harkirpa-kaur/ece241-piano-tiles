module test (CLOCK_50, KEY, fake_ledr, VGA_X, VGA_Y, VGA_COLOR, state, t, click_state, keyboard_enable);
	input wire CLOCK_50;
    input wire KEY;
	input wire [1:0] click_state;
	input wire keyboard_enable;
	wire reset = KEY;

	wire [3:0] sr, srd1, srd2, srd3;
	wire done_spawn;
	wire done_shift1, done_shift2, done_shift3;
	wire [7:0] spawn_VGA_X;
	wire [7:0] shift_VGA_X1, shift_VGA_X2, shift_VGA_X3;
	wire [6:0] spawn_VGA_Y;
	wire [6:0] shift_VGA_Y1, shift_VGA_Y2, shift_VGA_Y3;
	wire [8:0] spawn_VGA_COLOR, shift_VGA_COLOR1, shift_VGA_COLOR2, shift_VGA_COLOR3;
	output reg [7:0] VGA_X;
	output reg [6:0] VGA_Y;
	output reg [8:0] VGA_COLOR;
	output reg [3:0] fake_ledr;

	reg [2:0] spawn_count, shift_count1, shift_count2, shift_count3;

	output wire t;
	reg start;
	parameter SPAWN = 3'b000, SHIFT1 = 3'b001, SHIFT2 = 3'b010, SHIFT3 = 3'b011, WAIT = 3'b100;
	output reg [2:0] state = WAIT;
	parameter PAUSE = 2'd0, SCORE = 2'd1, MISS = 2'd2;
	reg [2:0] next_state;

	reg [1:0] spawn_tile_x = 2'd0, shift_tile_x1 = 2'd0, shift_tile_x2 = 2'd0, shift_tile_x3 = 2'd0;

	led ld (CLOCK_50, KEY, t, sr, srd1, srd2, srd3);

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			start <= 1'b0;
		else if (t)
			start <= 1'b1;
	end

//	always @ (posedge keyboard_enable)
//	begin
//		if (!reset)
//			fake_ledr <= 4'd0;
//		else if (!lose)
//			fake_ledr <= fake_ledr + 1;
//	end
  
	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			spawn_count <= 3'd0;
		else if (state == SPAWN && done_spawn && spawn_count < 3'd4)
			spawn_count <= spawn_count + 1;
		else if (state == SPAWN && done_spawn)
			spawn_count <= 3'd0;
	end

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			shift_count1 <= 3'd0;
		else if (state == SHIFT1 && done_shift1 && shift_count1 < 3'd4)
			shift_count1 <= shift_count1 + 1;
		else if (state == SHIFT1 && done_shift1)
			shift_count1 <= 3'd0;
	end

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			shift_count2 <= 3'd0;
		else if (state == SHIFT2 && done_shift2 && shift_count2 < 3'd4)
			shift_count2 <= shift_count2 + 1;
		else if (state == SHIFT2 && done_shift2)
			shift_count2 <= 3'd0;
	end

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			shift_count3 <= 3'd0;
		else if (state == SHIFT3 && done_shift3 && shift_count3 < 3'd4)
			shift_count3 <= shift_count3 + 1;
		else if (state == SHIFT3 && done_shift3)
			shift_count3 <= 3'd0;
	end

	//counter for spawning tiles over the columns
	always @ (posedge CLOCK_50)
	begin
		if (state == SPAWN)
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
	end

	// counter for shifting tiles over the columns
	always @ (posedge CLOCK_50)
	begin
		if (!reset && state != SPAWN && state != WAIT)
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
	shift_tile st1 (reset, CLOCK_50, shift_tile_x1, 2'd1, srd1, click_state, done_shift1, shift_VGA_X1, shift_VGA_Y1, shift_VGA_COLOR1);
	shift_tile st2 (reset, CLOCK_50, shift_tile_x2, 2'd2, srd2, click_state, done_shift2, shift_VGA_X2, shift_VGA_Y2, shift_VGA_COLOR2);
	shift_tile st3 (reset, CLOCK_50, shift_tile_x3, 2'd3, srd3, click_state, done_shift3, shift_VGA_X3, shift_VGA_Y3, shift_VGA_COLOR3);

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			state <= WAIT;
		else
			state <= next_state;
	end

	always @ (*)
	begin
		case (state)
			WAIT: begin
				if (start)
					next_state = SPAWN;
				else
					next_state = WAIT;
			end
			SPAWN: begin
				if (spawn_count >= 3'd4)
					next_state = SHIFT1;
				else
					next_state = SPAWN;
			end
			SHIFT1: begin
				if (shift_count1 >= 3'd4)
					next_state = SHIFT2;
				else
					next_state = SHIFT1;
			end
			SHIFT2: begin
				if (shift_count2 >= 3'd4)
					next_state = SHIFT3;
				else
					next_state = SHIFT2;
			end
			SHIFT3: begin
				if (shift_count3 >= 3'd4)
					next_state = SPAWN;
				else
					next_state = SHIFT3;
			end
			default: next_state = WAIT;
		endcase
	end
endmodule

module spawn_tile (shift_reg, tile_x, tile_y, CLOCK_50, reset, done_spawn, VGA_X, VGA_Y, VGA_COLOR);
    input wire [3:0] shift_reg;
    input wire [1:0] tile_x;
    input wire [1:0] tile_y;
    input wire CLOCK_50;
    input wire reset;

    output reg done_spawn;
    output reg [7:0] VGA_X = 8'd0;
    output reg [6:0] VGA_Y = 7'd0;
    output reg [8:0] VGA_COLOR;

	reg initialized = 1'b0;
	reg [8:0] latched_color;
	reg [1:0] prev_tile_x = 2'b0;

	reg [7:0] start_x;
	reg [6:0] start_y;
	
	wire sr = shift_reg[tile_x];

    always @ (posedge CLOCK_50)
    begin
			if (prev_tile_x != tile_x)
				begin
					prev_tile_x <= tile_x;
					initialized <= 1'b0;
				end
			if (!reset)
				begin
					VGA_X <= tile_x * 8'd40;
					VGA_Y <= tile_y * 7'd30;
					start_x <= tile_x * 8'd40;
					start_y <= tile_y * 7'd30;
					done_spawn <= 1'b0;
					initialized <= 1'b0;
					VGA_COLOR <= 9'h5a;
					prev_tile_x <= 2'd0;
				end
			else if (!initialized)
				begin
					start_x <= tile_x * 8'd40;
					start_y <= tile_y * 7'd30;
					VGA_X <= tile_x * 8'd40;
					VGA_Y <= tile_y * 8'd30;
					initialized <= 1'b1;
					VGA_COLOR <= sr ? 9'h1ff : 9'h5a;
				end
			else
			begin
				done_spawn <= 1'b0;								
				// Increment pixel position
				if (VGA_X >= start_x + 8'd39)
				begin
					VGA_X <= start_x;
					if (VGA_Y >= 7'd29)
					begin
						VGA_Y <= start_y;
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

module shift_tile (reset, CLOCK_50, tile_x, tile_y, shift_reg_delay, click_state, done_shift, VGA_X, VGA_Y, VGA_COLOR);
	input wire CLOCK_50;
	input wire reset;
	input wire [1:0] tile_x;
	input wire [1:0] tile_y;
	input wire [3:0] shift_reg_delay;
	input wire [1:0] click_state;

	reg [1:0] prev_tile_x = 2'b0;

	wire srd = shift_reg_delay[tile_x];

	reg initialized = 1'b0;
	
	reg latched_color;
	reg [7:0] start_x;
	reg [6:0] start_y;

	output reg done_shift;
	output reg [7:0] VGA_X;
	output reg [6:0] VGA_Y;
	output reg [8:0] VGA_COLOR;	
	
	parameter PAUSE = 2'd0, SCORE = 2'd1, MISS = 2'd2;


	always @ (posedge CLOCK_50)
    begin
			if (prev_tile_x != tile_x)
			begin
				prev_tile_x <= tile_x;
				initialized <= 1'b0;
			end
			if (!reset)
			begin
				VGA_X <= tile_x * 8'd40;
				VGA_Y <= tile_y * 7'd30;
				start_x <= tile_x * 8'd40;
				start_y <= tile_y * 7'd30;
				VGA_COLOR <= 9'h5a;
				initialized <= 1'b0;
				done_shift <= 1'b0;
				prev_tile_x <= 2'd0;
			end
			else
			begin
				done_shift <= 1'b0;

				if (!initialized)
				begin
					start_x <= tile_x * 8'd40;
					start_y <= tile_y * 8'd30;
					VGA_X <= tile_x * 8'd40;
					VGA_Y <= tile_y * 8'd30;
					initialized <= 1'b1;
					VGA_COLOR <= (click_state == MISS && tile_y == 2'd3 && srd) ? 9'h3a1 : (click_state == SCORE && tile_y == 2'd3 && srd) ? 9'h3f2 : (srd) ? 9'h1ff : 9'h5a;
				end

				if (VGA_X >= start_x + 8'd39 && initialized)
				begin
					VGA_X <= start_x;
					if (VGA_Y >= start_y + 7'd29)
					begin
						VGA_Y <= start_y;
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