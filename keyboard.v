module keyboard (CLOCK_50, reset, scancode, t, LEDR, click_state, expected, HEX0, HEX1, HEX2, score, start_game);
    input CLOCK_50;
    input reset;
    input [7:0] scancode;
    output reg [1:0] click_state = 2'd0;
    output reg [6:0] LEDR;
	 output wire [6:0] HEX0, HEX1, HEX2;
    
    parameter WAIT = 2'd0, SCORE = 2'd1, MISS = 2'd2;

    output wire [7:0] expected;
    input wire t, start_game;
    
    reg [7:0] prev_scancode;
    reg key_processed;
	 reg first_tile = 1'b1;
	 output reg [6:0] score = 7'd0;
    expected_key ek (CLOCK_50, reset, t, start_game, expected);
    //timer tm (CLOCK_50, reset, timer);
	 score_display sd (CLOCK_50, reset, score, start_game, HEX0, HEX1, HEX2);
    
    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05, BREAK = 8'hf0;
    
    always @(posedge CLOCK_50) begin
        LEDR <= score;
        
        if (!reset) begin
            click_state <= WAIT;
            prev_scancode <= 8'h00;
            key_processed <= 1'b0;
            score <= 7'd0;
				first_tile <= 1'b1;
        end
        else if (!t && start_game) begin
           if (scancode != prev_scancode && !key_processed)
            begin
                prev_scancode <= scancode;
                key_processed <= 1'b1;
                if (scancode == expected)
						begin
                    click_state <= SCORE;
						  score <= score + 7'd2;
						end
                else if (expected != EMPTY)
                    click_state <= MISS;
            end
        end
        else if (t && !first_tile && start_game)
        begin
            if (!key_processed && expected != EMPTY)
                click_state <= MISS;
            else
            begin
                key_processed <= 1'b0;
                click_state <= WAIT;
            end
        end
		  else if (t && first_tile && start_game)
		  begin
				first_tile <= 1'b0;
				key_processed <= 1'b1;
			end
    end

endmodule

module expected_key (CLOCK_50, reset, t, start_game, expected);
    input CLOCK_50;
    input reset;
    output reg [7:0] expected;
    input t, start_game;

    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05;

    parameter [423:0] keys_o = {EMPTY, EMPTY, EMPTY, S, D, S, F, S, F, S, F, D, F, A, F, D, A, S, D, F, D, A, D, S, D, A, F, D, F, D, S, D, F, D, S, A, S, D, F, D, S, A, D, S, D, F, S, A, F, A, D, S, D};

    reg [423:0] keys = {EMPTY, EMPTY, EMPTY, S, D, S, F, S, F, S, F, D, F, A, F, D, A, S, D, F, D, A, D, S, D, A, F, D, F, D, S, D, F, D, S, A, S, D, F, D, S, A, D, S, D, F, S, A, F, A, D, S, D};
    
    always @(posedge CLOCK_50) begin
        if (!reset)
        begin
            keys <= keys_o;
            expected <= EMPTY;
        end
        else if (t && start_game) begin
            expected <= keys[423:416];
            keys <= {keys[415:0], 8'd0};
				$monitor("Updated expected: %h, Shifted keys: %h", expected, keys); // Debugging print

        end
    end

endmodule

module score_display (CLOCK_50, reset, score, game_start, HEX0, HEX1, HEX2);
	input CLOCK_50, reset;
	input [6:0] score;
	input game_start;
	output reg [6:0] HEX0, HEX1, HEX2;

    reg [3:0] ones = 4'd0, tens = 4'd0;
	
	parameter ZERO = 7'b1000000, ONE = 7'b1111001, TWO = 7'b0100100, THREE = 7'b0110000, FOUR = 7'b0011001, FIVE = 7'b0010010, SIX = 7'b0000010, SEVEN = 7'b1111000, EIGHT = 7'b0000000, NINE = 7'b0010000;

   always @ (posedge CLOCK_50)
    begin
      if (!reset)
        begin
            ones <= 4'd0;
            tens <= 4'd0;
            HEX0 <= ZERO;
            HEX1 <= ZERO;
            HEX2 <= ZERO;
        end
        else if (game_start)
        begin
            ones <= score % 10;
            tens <= score / 10;
            case (ones)
                4'd0: HEX0 <= ZERO;
                4'd1: HEX0 <= ONE;
                4'd2: HEX0 <= TWO;
                4'd3: HEX0 <= THREE;
                4'd4: HEX0 <= FOUR;
                4'd5: HEX0 <= FIVE;
                4'd6: HEX0 <= SIX;
                4'd7: HEX0 <= SEVEN;
                4'd8: HEX0 <= EIGHT;
                4'd9: HEX0 <= NINE;
            endcase
            
            case (tens)
                4'd0: HEX1 <= ZERO;
                4'd1: HEX1 <= ONE;
                4'd2: HEX1 <= TWO;
                4'd3: HEX1 <= THREE;
                4'd4: HEX1 <= FOUR;
                4'd5: HEX1 <= FIVE;
                4'd6: HEX1 <= SIX;
                4'd7: HEX1 <= SEVEN;
                4'd8: HEX1 <= EIGHT;
                4'd9: HEX1 <= NINE;
					 4'd10: HEX1 <= ZERO;
            endcase

            if (score == 7'd100)
                HEX2 <= ONE;
            else 
                HEX2 <= ZERO;
        end
    end
	
endmodule