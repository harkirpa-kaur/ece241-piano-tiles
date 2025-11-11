module fsm (CLOCK_50, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, state, next_state);
    input CLOCK_50; 
    input [3:0] KEY; 
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6; 

    parameter IDLE = 2'd0, GAME = 2'd1, END = 2'd2; 
    output reg [1:0] state, next_state;

    wire reset = KEY[0]; 

    always @ (posedge CLOCK_50)
    begin
        case (state)
            IDLE:
            begin
                if(!reset)
                    next_state <= GAME;
                else
                    next_state <= IDLE; 
            end
            GAME:
            begin
                if(!w)
                    next_state <= GAME;
                else if(w)
                    next_state <= END;
            end
            END: 
            begin
                if(w)
                    next_state <= IDLE;
                else if(!w)
                    next_state <= END;
            end
        endcase

        state <= next_state; 

    end

endmodule