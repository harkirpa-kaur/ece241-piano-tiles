// Fixed version - key changes marked with comments

module test (CLOCK_50, KEY, LEDR, VGA_X, VGA_Y, VGA_COLOR, done_spawn, t, sr, srd1, srd2, srd3);
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
	wire [8:0] spawn_VGA_COLOR, shift_VGA_COLOR1, shift_VGA_COLOR2, shift_VGA_COLOR3;
	output reg [9:0] VGA_X;
	output reg [8:0] VGA_Y;
	output reg [8:0] VGA_COLOR;
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
  
	// FIX: Changed to synchronous reset for counters
	always @ (posedge CLOCK_50)
	begin
		if (state == SPAWN)
		begin
			if (!reset)
				spawn_count <= 3'd0;
			else if (done_spawn && spawn_count < 3'd4)
				spawn_count <= spawn_count + 1;
			else if (done_spawn)
				spawn_count <= 3'd0;
		end
	end

	always @ (posedge CLOCK_50)
	begin
		if (state == SHIFT1)
		begin
			if (!reset)
				shift_count1 <= 3'd0;
			else if (done_shift1 && shift_count1 < 3'd4)
				shift_count1 <= shift_count1 + 1;
			else if (done_shift1)
				shift_count1 <= 3'd0;
		end
	end

	always @ (posedge CLOCK_50)
	begin
		if (state == SHIFT2)
		begin
			if (!reset)
				shift_count2 <= 3'd0;
			else if (done_shift2 && shift_count2 < 3'd4)
				shift_count2 <= shift_count2 + 1;
			else if (done_shift2)
				shift_count2 <= 3'd0;
		end
	end

	always @ (posedge CLOCK_50)
	begin
		if (state == SHIFT3)
		begin
			if (!reset)
				shift_count3 <= 3'd0;
			else if (done_shift3 && shift_count3 < 3'd4)
				shift_count3 <= shift_count3 + 1;
			else if (done_shift3)
				shift_count3 <= 3'd0;
		end
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

    spawn_tile dt (sr, (state == SPAWN), spawn_tile_x, 2'd0, CLOCK_50, reset, done_spawn, spawn_VGA_X, spawn_VGA_Y, spawn_VGA_COLOR);
	shift_tile st1 (reset, CLOCK_50, (state == SHIFT1), shift_tile_x1, 2'd1, srd1, done_shift1, shift_VGA_X1, shift_VGA_Y1, shift_VGA_COLOR1);
	shift_tile st2 (reset, CLOCK_50, (state == SHIFT2), shift_tile_x2, 2'd2, srd2, done_shift2, shift_VGA_X2, shift_VGA_Y2, shift_VGA_COLOR2);
	shift_tile st3 (reset, CLOCK_50, (state == SHIFT3), shift_tile_x3, 2'd3, srd3, done_shift3, shift_VGA_X3, shift_VGA_Y3, shift_VGA_COLOR3);

	// FIX: Separated state transition and next state logic
	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			state <= WAIT;
		else
			state <= next_state;
	end

	// FIX: Combinational logic for next_state in separate block
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

module spawn_tile (shift_reg, enable_spawn, tile_x, tile_y, CLOCK_50, reset, done_spawn, VGA_X, VGA_Y, VGA_COLOR);
    input [3:0] shift_reg;
    input [1:0] tile_x;
    input [1:0] tile_y;
    input CLOCK_50;
    input reset;
	input enable_spawn;

    output reg done_spawn;
    output reg [9:0] VGA_X = 10'd0;
    output reg [8:0] VGA_Y = 9'd0;
    output reg [8:0] VGA_COLOR;

	// FIX: Latch the color at the start of each tile
	reg latched_color = 1'b0;
	reg [1:0] current_tile_x = 2'd0;
	reg [1:0] current_tile_y = 2'd0;
	reg [5:0] pixel_x = 6'd0;  // 0-39
	reg [4:0] pixel_y = 5'd0;  // 0-29
	
	wire sr = shift_reg[tile_x];

    always @ (posedge CLOCK_50)
    begin
		if (enable_spawn)
		begin
			if (!reset)
			begin
				current_tile_x <= 2'd0;
				current_tile_y <= 2'd0;
				pixel_x <= 6'd0;
				pixel_y <= 5'd0;
				VGA_X <= 10'd0;
				VGA_Y <= 9'd0;
				VGA_COLOR <= 9'h0a0;
				latched_color <= 1'b0;
				done_spawn <= 1'b0;
			end
			else
			begin
				done_spawn <= 1'b0;
				
				// Update tile position when tile_x changes or at start
				if (tile_x != current_tile_x || tile_y != current_tile_y)
				begin
					current_tile_x <= tile_x;
					current_tile_y <= tile_y;
					pixel_x <= 6'd0;
					pixel_y <= 5'd0;
					latched_color <= sr;  // Latch color for new tile
				end
				
				// Calculate actual VGA coordinates
				VGA_X <= (current_tile_x * 10'd40) + pixel_x;
				VGA_Y <= (current_tile_y * 9'd30) + pixel_y;
				
				// Use latched color for entire tile
				if (latched_color == 1'b1)
					VGA_COLOR <= 9'h1ff; //white
				else
					VGA_COLOR <= 9'h5a; //green

				// Increment pixel position
				if (pixel_x >= 6'd39)
				begin
					pixel_x <= 6'd0;
					if (pixel_y >= 5'd29)
					begin
						pixel_y <= 5'd0;
						done_spawn <= 1'b1;
					end
					else 
					begin
						pixel_y <= pixel_y + 1;
					end
				end
				else
				begin
					pixel_x <= pixel_x + 1;
				end
			end
		end
    end

endmodule

module shift_tile (reset, CLOCK_50, shift_enable, tile_x, tile_y, shift_reg_delay, done_shift, VGA_X, VGA_Y, VGA_COLOR);
	input CLOCK_50;
	input reset;
	input [1:0] tile_x;
	input [1:0] tile_y;
	input [3:0] shift_reg_delay;
	input shift_enable;

	wire srd = shift_reg_delay[tile_x];

	reg initialized = 1'b0;
	
	// FIX: Latch the color at the start of each tile
	reg latched_color;
	reg [9:0] start_x;
	reg [8:0] start_y;

	output reg done_shift;
	output reg [9:0] VGA_X;
	output reg [8:0] VGA_Y;
	output reg [8:0] VGA_COLOR;	

	always @ (posedge CLOCK_50)
    begin
		if (shift_enable)
		begin
			if (!reset)
			begin
				VGA_X <= tile_x * 10'd40;
				VGA_Y <= tile_y * 9'd30;
				start_x <= tile_x * 10'd40;
				start_y <= tile_y * 9'd30;
				VGA_COLOR <= 9'h5a;
				latched_color <= 1'b0;
				initialized <= 1'b0;
				done_shift <= 1'b0;
			end
			else
			begin
				done_shift <= 1'b0;

				if (!initialized)
				begin
					VGA_X <= start_x;
					VGA_Y <= start_y;
					initialized <= 1'b1;
					latched_color <= srd;  // FIX: Latch at initialization
				end
				else
				begin
					// FIX: Latch color only at the start of drawing a tile
					if (VGA_X == start_x && VGA_Y == start_y)
					begin
						latched_color <= srd;
					end
				end
				
				// Use latched color for entire tile
				if (latched_color == 1'b1)
					VGA_COLOR <= 9'h1ff; //white
				else
					VGA_COLOR <= 9'h5a; //green

				if (VGA_X >= start_x + 10'd39 && initialized)
				begin
					VGA_X <= start_x;
					if (VGA_Y >= start_y + 9'd29)
					begin
						VGA_Y <= start_y;
						done_shift <= 1'b1;
						initialized <= 1'b0;  // FIX: Reset for next tile
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
    end

endmodule