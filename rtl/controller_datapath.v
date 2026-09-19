module controller_datapath (
    input wire [2:0] spawn_count,
    input wire [2:0] shift_count1,
    input wire [2:0] shift_count2,
    input wire [2:0] shift_count3,
    output wire spawn_done,
    output wire shift1_done,
    output wire shift2_done,
    output wire shift3_done
);

    assign spawn_done = (spawn_count >= 3'd4);
    assign shift1_done = (shift_count1 >= 3'd4);
    assign shift2_done = (shift_count2 >= 3'd4);
    assign shift3_done = (shift_count3 >= 3'd4);

endmodule