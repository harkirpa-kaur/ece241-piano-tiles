module keyboard (CLOCK_50, reset, scancode, t, LEDR, click_state, expected);
    input CLOCK_50;
    input reset;
    input [7:0] scancode;
    output reg [1:0] click_state = 2'd0;
    output reg [1:0] LEDR;
    
    parameter WAIT = 2'd0, SCORE = 2'd1, MISS = 2'd2;

    output wire [7:0] expected;
    input wire t;
    
    reg [7:0] prev_scancode;
    reg key_processed;
    reg timer_delay;  // Delay 1 cycle for expected to update

    expected_key ek (CLOCK_50, reset, t, expected);
    //timer tm (CLOCK_50, reset, timer);
    
    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05, BREAK = 8'hf0;
    
    always @(posedge CLOCK_50) begin
        LEDR <= click_state;
        
        if (!reset) begin
            click_state <= WAIT;
            prev_scancode <= 8'h00;
            key_processed <= 1'b0;
        end
        else if (!t) begin
           if (scancode != prev_scancode && !key_processed)
            begin
                prev_scancode <= scancode;
                key_processed <= 1'b1;
                if (scancode == expected)
                    click_state <= SCORE;
                else
                    click_state <= MISS;
            end
//            else if (key_processed)
//                click_state <= WAIT;
        end
        else if (t)
        begin
            key_processed <= 1'b0;
            click_state <= WAIT;
        end
    end

endmodule

module expected_key (CLOCK_50, reset, t, expected);
    input CLOCK_50;
    input reset;
    output reg [7:0] expected;
    input t;

    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05;

    parameter [599:0] keys_o = {EMPTY, EMPTY, EMPTY, EMPTY, D, S, F, F, EMPTY, S, F, D, F, F, F, D, A, S, D, D, D, D, D, D, D, EMPTY, EMPTY, EMPTY, F, D, S, D, F, D, S, A, S, D, F, D, S, A, D, S, D, F, F, F, F, EMPTY, EMPTY, EMPTY, D, S, A, A, EMPTY, F, S, D, A, A, A, S, D, F, D, D, D, D, D, D, D, EMPTY, EMPTY};

    reg [599:0] keys = {EMPTY, EMPTY, EMPTY, EMPTY, D, S, F, F, EMPTY, S, F, D, F, F, F, D, A, S, D, D, D, D, D, D, D, EMPTY, EMPTY, EMPTY, F, D, S, D, F, D, S, A, S, D, F, D, S, A, D, S, D, F, F, F, F, EMPTY, EMPTY, EMPTY, D, S, A, A, EMPTY, F, S, D, A, A, A, S, D, F, D, D, D, D, D, D, D, EMPTY, EMPTY};
    
    always @(posedge CLOCK_50) begin
        if (!reset)
        begin
            keys <= keys_o;
            expected <= EMPTY;
        end
        else if (t) begin
            expected <= keys[599:592];
            keys <= {keys[591:0], 8'd0};
				$monitor("Updated expected: %h, Shifted keys: %h", expected, keys); // Debugging print

        end
    end

endmodule