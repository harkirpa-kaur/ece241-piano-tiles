module test (KEY);
    input KEY[1:1];
endmodule

module fsm(CLOCK_50, state, start);
    input CLOCK_50;
    output state;

    parameter IDLE = 7'd0, 
    DRAW = 7'd1, 
    UPDATE = 7'd2,
    SPAWN00 = 7'd3,
    SPAWN_PAUSE00 = 7'd4,
    SPAWN01 = 7'd5,
    SPAWN_PAUSE01 = 7'd6,
    SPAWN02 = 7'd7,
    SPAWN_PAUSE02 = 7'd8,
    SPAWN03 = 7'd9, 
    SPAWN_PAUSE03 = 7'd10,
    SPAWN10 = 7'd11,
    SPAWN_PAUSE10 = 7'd12,
    SPAWN11 = 7'd13,
    SPAWN_PAUSE11 = 7'd14,
    SPAWN12 = 7'd15,
    SPAWN_PAUSE12 = 7'd16,
    SPAWN13 = 7'd17,
    SPAWN_PAUSE13 = 7'd18,
    SPAWN20 = 7'd19,
    SPAWN_PAUSE20 = 7'd20,
    SPAWN21 = 7'd21,
    SPAWN_PAUSE21 = 7'd22,
    SPAWN22 = 7'd23,
    SPAWN_PAUSE22 = 7'd24,
    SPAWN23 = 7'd25,
    SPAWN_PAUSE23 = 7'd26,
    SPAWN30 = 7'd27,
    SPAWN_PAUSE30 = 7'd28,
    SPAWN31 = 7'd29,
    SPAWN_PAUSE31 = 7'd30,
    SPAWN232 = 7'd31,
    SPAWN_PAUSE32 = 7'd32,
    SPAWN33 = 7'd33,
    SPAWN_PAUSE33 = 7'd34;
    ERASE00 = 7'd35,
    ERASE_PAUSE00 = 7'd36,
    ERASE01 = 7'd37,
    ERASE_PAUSE01 = 7'd38,
    ERASE02 = 7'd39,
    ERASE_PAUSE02 = 7'd40,
    ERASE03 = 7'd41,
    ERASE_PAUSE03 = 7'd42,
    ERASE10 = 7'd43,
    ERASE_PAUSE10 = 7'd44,
    ERASE11 = 7'd45,
    ERASE_PAUSE11 = 7'd46,
    ERASE12 = 7'd47,
    ERASE_PAUSE12 = 7'd48,
    ERASE13 = 7'd49,
    ERASE_PAUSE13 = 7'd50,
    ERASE20 = 7'd51,
    ERASE_PAUSE20 = 7'd52,
    ERASE21 = 7'd53,
    ERASE_PAUSE21 = 7'd54,
    ERASE22 = 7'd55,
    ERASE_PAUSE22 = 7'd56,
    ERASE23 = 7'd57,
    ERASE_PAUSE23 = 7'd58,
    ERASE30 = 7'd59,
    ERASE_PAUSE30 = 7'd60,
    ERASE31 = 7'd61,
    ERASE_PAUSE31 = 7'd62,
    ERASE32 = 7'd63,
    ERASE_PAUSE32 = 7'd64,
    ERASE33 = 7'd65;

    always @ (*)
    begin
        case (state)
            IDLE: next_state <= start ? DRAW : IDLE;
            DRAW: next_state <= SPAWN_PAUSE00;
            SPAWN00: next_state <= done_spawn ? SPAWN_PAUSE01 : SPAWN00;
            SPAWN_PAUSE00: next_state <= start ? SPAWN00 : SPAWN_PAUSE01;
            SPAWN01: next_state <= done_spawn ? SPAWN_PAUSE02 : SPAWN01;
            SPAWN_PAUSE01: next_state <= start ? SPAWN01 : SPAWN_PAUSE02;
            SPAWN02: next_state <= done_spawn ? SPAWN_PAUSE03 : SPAWN02;
            SPAWN_PAUSE02: next_state <= start ? SPAWN02 : SPAWN_PAUSE03;
            SPAWN03: next_state <= done_spawn ? SPAWN_PAUSE10 : SPAWN03;
            SPAWN_PAUSE03: next_state <= start ? SPAWN03 : SPAWN_PAUSE10;
            SPAWN10: next_state <= done_spawn ? SPAWN_PAUSE11 : SPAWN10;
            SPAWN_PAUSE10: next_state <= start ? SPAWN10 : SPAWN_PAUSE11;
            SPAWN11: next_state <= done_spawn ? SPAWN_PAUSE12 : SPAWN11;
            SPAWN_PAUSE11: next_state <= start ? SPAWN11 : SPAWN_PAUSE12;
            SPAWN12: next_state <= done_spawn ? SPAWN_PAUSE13 : SPAWN12;
            SPAWN_PAUSE12: next_state <= start ? SPAWN12 : SPAWN_PAUSE13;
            SPAWN13: next_state <= done_spawn ? SPAWN_PAUSE20 : SPAWN13;
            SPAWN_PAUSE13: next_state <= start ? SPAWN13 : SPAWN_PAUSE20;
            SPAWN20: next_state <= done_spawn ? SPAWN_PAUSE21 : SPAWN20;
            SPAWN_PAUSE20: next_state <= start ? SPAWN20 : SPAWN_PAUSE21;
            SPAWN21: next_state <= done_spawn ? SPAWN_PAUSE22 : SPAWN21;
            SPAWN_PAUSE21: next_state <= start ? SPAWN21 : SPAWN_PAUSE22;
            SPAWN22: next_state <= done_spawn ? SPAWN_PAUSE23 : SPAWN22;
            SPAWN_PAUSE22: next_state <= start ? SPAWN22 : SPAWN_PAUSE23;
            SPAWN23: next_state <= done_spawn ? SPAWN_PAUSE30 : SPAWN23;
            SPAWN_PAUSE23: next_state <= start ? SPAWN23 : SPAWN_PAUSE30;
            SPAWN30: next_state <= done_spawn ? SPAWN_PAUSE31 : SPAWN30;
            SPAWN_PAUSE30: next_state <= start ? SPAWN30 : SPAWN_PAUSE31;
            SPAWN31: next_state <= done_spawn ? SPAWN_PAUSE32 : SPAWN31;
            SPAWN_PAUSE31: next_state <= start ? SPAWN31 : SPAWN_PAUSE32;
            SPAWN32: next_state <= done_spawn ? SPAWN_PAUSE33 : SPAWN32;
            SPAWN_PAUSE32: next_state <= start ? SPAWN32 : SPAWN_PAUSE33;
            SPAWN33: next_state <= done_spawn ? WAIT : SPAWN33;
            SPAWN_PAUSE33: next_state <= start ? SPAWN33 : WAIT;
            default : next_state <= IDLE;
        endcase
    end

endmodule

module draw_tile (sr, res, tile_x, tile_y, CLOCK_50, reset, done_spawn);
    input sr;
    input res;
    input reset;
    input [1:0] tile_x;
    input [1:0] tile_y;
    input CLOCK_50;
    output reg done_spawn;

    reg [7:0] x_pixel = 8'd0;
    reg [6:0] y_pixel = 7'd0;

    always @ (posedge CLOCK_50)
    begin
        if (!reset)
        begin
            
        end
        else if (sr)
        begin
            if (x_pixel < 8'd160)
            begin
                VGA_COLOUR <= 3'b111;
                x_pixel <= x_pixel + 1'b1;
            end
=            else
                x_pixel <= 8'd0;
            if (y_pixel < 7'd120)
=                y_pixel <= y_pixel + 1'b1;
            else
                y_pixel <= 7'd0;
            
        end
    end

endmodule