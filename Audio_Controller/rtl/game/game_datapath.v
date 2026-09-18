module game_datapath (
    input wire clk,
    input wire resetn,
    input wire [1:0] spawn_count,
    input wire [1:0] shift_count1,
    input wire [1:0] shift_count2,
    input wire [1:0] shift_count3,
    output reg spawn_done,
    output reg shift1_done,
    output reg shift2_done,
    output reg shift3_done
);

    always @ (*) begin
        spawn_done = spawn_count >= 3'd4;
        shift1_done = shift_count1 >= 3'd4;
        shift2_done = shift_count2 >= 3'd4;
        shift3_done = shift_count3 >= 3'd4;
    end

endmodule