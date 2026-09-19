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

    parameter SPAWN = 3'b000, SHIFT1 = 3'b001, SHIFT2 = 3'b010, SHIFT3 = 3'b011, WAIT = 3'b100;
    reg [1:0] next_state;

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
                    if (spawn_done)
                        next_state = SHIFT1;
                    else
                        next_state = SPAWN;
                end
                SHIFT1: begin
                    if (shift1_done)
                        next_state = SHIFT2;
                    else
                        next_state = SHIFT1;
                end
                SHIFT2: begin
                    if (shift2_done)
                        next_state = SHIFT3;
                    else
                        next_state = SHIFT2;
                end
                SHIFT3: begin
                    if (shift3_done)
                        next_state = SPAWN;
                    else
                        next_state = SHIFT3;
                end
                default: next_state = WAIT;
            endcase
        end

        always @ (posedge clk)
        begin
            if (!resetn)
                state <= WAIT;
            else
                state <= next_state;
        end

endmodule