module game_controller(
    input wire clk,
    input wire resetn,
    input wire start,
    input wire spawn_done,
    input wire shift1_done,
    input wire shift2_done,
    input wire shift3_done,
    output reg [1:0] state
);

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

        always @ (posedge CLOCK_50)
        begin
            if (!reset)
                state <= WAIT;
            else
                state <= next_state;
        end

endmodule