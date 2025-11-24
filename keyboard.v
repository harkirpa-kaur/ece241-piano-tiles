module keyboard (CLOCK_50, reset, received_data, received_data_en, LEDR, score_LEDR, click_state);
    input CLOCK_50;
    input reset;
    input [32:0] received_data;
    input received_data_en;
    output reg [1:0] click_state;
    output [7:0] LEDR;
    output reg score_LEDR;
    reg lose;
    parameter WAIT = 2'd0, SCORE = 2'd1, MISS = 2'd2;

    wire [7:0] expected;
    reg [1:0] next_click_state = WAIT;

    assign LEDR = expected;

    expected_key ek (CLOCK_50, reset, expected);
    
    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05, BREAK = 8'hf0;
    always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            lose <= 1'b0;
            break <= 1'b0;
        end
    if (received_data_en)
        begin
            if (Serial[30:23] == BREAK && Serial[19:12] == expected && Serial[8:1] == BREAK && expected != EMPTY)
            begin
                lose <= 1'b0;
            end
            else
            begin
                lose <= 1'b1;
            end
        end
    end
endmodule

always @ (posedge CLOCK_50){
    click_state <= next_click_state;
}

always @ (*)
begin
    case (click_state):
        WAIT:
        begin
            if (received_data_en && !lose)
            begin
                next_click_state <= SCORE;
            end
            else if (received_data_en && lose)
            begin
                next_click_state <= MISS;
            end
            else
                next_click_state <= WAIT;
        end
        SCORE:
        begin
            if (!received_data_en)
                next_click_state <= WAIT;
            else
                next_click_state <= SCORE;
        end
        MISS:
        begin
            if (!received_data_en)
                next_click_state <= WAIT;
            else
                next_click_state <= MISS;
        end
        default: next_click_state <= WAIT;
    endcase
end

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

    parameter [599:0] keys_o = {EMPTY, EMPTY, EMPTY, EMPTY, S, D, A, A, EMPTY, D, A, S, A, A, A, S, F, D, S, S, S, S, S, S, S, EMPTY, EMPTY, EMPTY, A, S, D, S, A, S, D, F, D, S, A, S, D, F, S, D, S, A, A, A, A, EMPTY, EMPTY, EMPTY, S, D, F, F, EMPTY, A, D, S, F, F, F, D, S, A, S, S, S, S, S, S, S, EMPTY, EMPTY};

    reg [599:0] keys = {EMPTY, EMPTY, EMPTY, EMPTY, S, D, A, A, EMPTY, D, A, S, A, A, A, S, F, D, S, S, S, S, S, S, S, EMPTY, EMPTY, EMPTY, A, S, D, S, A, S, D, F, D, S, A, S, D, F, S, D, S, A, A, A, A, EMPTY, EMPTY, EMPTY, S, D, F, F, EMPTY, A, D, S, F, F, F, D, S, A, S, S, S, S, S, S, S, EMPTY, EMPTY};
    
    always @(posedge CLOCK_50) begin
        if (!reset)
        begin
            keys <= keys_o;
            expected <= EMPTY;
        end
        else if (enable) begin
            expected <= keys [599:592];
            keys <= {keys[593:0], 8'd0};
        end
    end

endmodule