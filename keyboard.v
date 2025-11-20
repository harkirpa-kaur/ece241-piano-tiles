module keyboard (CLOCK_50, reset, received_data, received_data_en, lose, break, LEDR);
    input CLOCK_50;
    input reset;
    input [7:0] received_data;
    input received_data_en;
    output reg lose;
    output reg break;

    output reg [7:0] LEDR;

    wire [7:0] expected;

    expected_key ek (CLOCK_50, reset, expected);
    
    parameter SPACE = 8'h29, A = 8'h1c, S = 8'h1b, D = 8'h23, F = 8'h2b, EMPTY = 8'h05, BREAK = 8'hf0;

    always @ (posedge CLOCK_50)
    begin
    if (received_data_en)
        begin
            LEDR <= received_data;
            if (received_data == BREAK)
            begin
                break <= 1'b1;
            end
            else if (break)
            begin
                break <= 1'b0;
            end
            else if (received_data == expected && expected != EMPTY)
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

module timer (CLOCK_50, reset, timer);
    input CLOCK_50;
    input reset;

    reg [24:0] little = 25'd0;
    output reg timer;

    always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            little <= 25'd0;
            timer <= 1'b0;
        end
        else if (little <= 25'd22_222_222)
        begin
            little <= little + 1;
        end
        else
        begin
            little <= 25'd0;
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

    parameter [74*8:0] keys_o = {EMPTY, EMPTY, EMPTY, EMPTY, S, D, A, A, EMPTY, D, A, S, A, A, A, S, F, D, S, S, S, S, S, S, S, EMPTY, EMPTY, EMPTY, A, S, D, S, A, S, D, F, D, S, A, S, D, F, S, D, S, A, A, A, A, EMPTY, EMPTY, EMPTY, S, D, F, F, EMPTY, A, D, S, F, F, F, D, S, A, S, S, S, S, S, S, S, EMPTY, EMPTY};

    reg [74*8:0] keys = {EMPTY, EMPTY, EMPTY, EMPTY, S, D, A, A, EMPTY, D, A, S, A, A, A, S, F, D, S, S, S, S, S, S, S, EMPTY, EMPTY, EMPTY, A, S, D, S, A, S, D, F, D, S, A, S, D, F, S, D, S, A, A, A, A, EMPTY, EMPTY, EMPTY, S, D, F, F, EMPTY, A, D, S, F, F, F, D, S, A, S, S, S, S, S, S, S, EMPTY, EMPTY};
    
    always @(posedge CLOCK_50) begin
        if (!reset)
        begin
            keys <= keys_o;
            expected <= EMPTY;
        end
        else if (enable) begin
            expected <= keys [592:585];
            keys <= {keys[584:0], 8'd0};
        end
    end

endmodule