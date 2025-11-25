module keyboard (CLOCK_50, reset, Serial, ps2_rec, LEDR, score_LEDR, click_state);
    input CLOCK_50;
    input reset;
    input [32:0] Serial;
    input ps2_rec;
	reg received_data_en;
    output reg [1:0] click_state;
    output [7:0] LEDR;
    output reg score_LEDR;
    reg lose;
    parameter WAIT = 2'd0, SCORE = 2'd1, MISS = 2'd2;

    wire [7:0] expected;
    reg [1:0] next_click_state;

    assign LEDR [1:0] = click_state;
	 assign LEDR [2] = received_data_en;
	 wire timer;

    expected_key ek (CLOCK_50, reset, expected);
	 timer tm (CLOCK_50, reset, timer);
	 
	 // Update `received_data_en` logic to be one clock cycle wide
		always @(posedge CLOCK_50) begin
			 if (!reset) begin
				  received_data_en <= 0;  // Reset on reset
			 end else if (ps2_rec) begin
				  received_data_en <= 1;  // Set when a valid scancode is received
			 end else begin
				  received_data_en <= 0;  // Reset after one cycle to avoid latching
			 end
		end
    
    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05, BREAK = 8'hf0;
    always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            lose <= 1'b0;
        end
		  if (received_data_en)
		  begin
            if (Serial[30:23] == expected && Serial[19:12] == BREAK && Serial[8:1] == expected && expected != EMPTY)
            begin
                lose <= 1'b0;
            end
            else
            begin
                lose <= 1'b1;
            end
			end
    end

	always @ (posedge CLOCK_50)
	begin
		if (!reset)
			click_state <= WAIT;
		else
			click_state <= next_click_state;
	end


	always @ (*) begin
		 if (!reset)
			  next_click_state = WAIT;
			case (click_state)
				WAIT:
				begin
					if (received_data_en && !lose)
						next_click_state = SCORE;
					else if (received_data_en && lose)
						next_click_state = MISS;
				end
				SCORE:
					next_click_state = WAIT;
				MISS:
					next_click_state = WAIT;
			endcase
	end
	
//	reg clicked = 1'b0;
//	
//	always @ (posedge CLOCK_50)
//	begin
//		if (!reset)
//			clicked <= 1'b0;
//		else if (clicked && timer)
//			clicked = 1'b0;
//		else if (received_data_en && timer)
//			clicked <= 1'b1;
//	end



endmodule

module timer (CLOCK_50, reset, timer);
    input CLOCK_50;
    input reset;
    reg [24:0] little = 25'd0;
    output reg timer = 1'b0;

    always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            little <= 25'd0;
            timer <= 1'b0;
        end
        else if (little == 25'd16_666_666)
        begin
            little <= 25'd0;
            timer <= 1'b1;
        end
        else
        begin
            little <= little + 1;
            timer <= 1'b0;
        end
    end
endmodule

module expected_key (CLOCK_50, reset, expected);
    input CLOCK_50;
    input reset;
    output reg [7:0] expected;

    wire enable;

    timer tm (CLOCK_50, reset, enable);

    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05;

    parameter [601:0] keys_o = {EMPTY, EMPTY, EMPTY, EMPTY, S, D, A, A, EMPTY, D, A, S, A, A, A, S, F, D, S, S, S, S, S, S, S, EMPTY, EMPTY, EMPTY, A, S, D, S, A, S, D, F, D, S, A, S, D, F, S, D, S, A, A, A, A, EMPTY, EMPTY, EMPTY, S, D, F, F, EMPTY, A, D, S, F, F, F, D, S, A, S, S, S, S, S, S, S, EMPTY, EMPTY};

    reg [601:0] keys = {EMPTY, EMPTY, EMPTY, EMPTY, S, D, A, A, EMPTY, D, A, S, A, A, A, S, F, D, S, S, S, S, S, S, S, EMPTY, EMPTY, EMPTY, A, S, D, S, A, S, D, F, D, S, A, S, D, F, S, D, S, A, A, A, A, EMPTY, EMPTY, EMPTY, S, D, F, F, EMPTY, A, D, S, F, F, F, D, S, A, S, S, S, S, S, S, S, EMPTY, EMPTY};
    
    always @(posedge CLOCK_50) begin
        if (!reset)
        begin
            keys <= keys_o;
            expected <= EMPTY;
        end
        else if (enable) begin
            expected <= keys [601:594];
            keys <= {keys[592:0], 8'd0};
        end
    end

endmodule