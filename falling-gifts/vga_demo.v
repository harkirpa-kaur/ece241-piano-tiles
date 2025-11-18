`default_nettype none

module vga_demo(CLOCK_50, SW, KEY, LEDR, VGA_X, VGA_Y, VGA_COLOR, plot);
     // default resolution. Specify a resolution in top.v
    parameter RESOLUTION = "640x480"; // "640x480" "320x240" "160x120"

    // default color depth. Specify a color in top.v
    parameter COLOR_DEPTH = 9; // 9 6 3

    // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
    // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);

    // state codes for FSM that choses which object to draw at a given time
    parameter A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;

	input wire CLOCK_50;	
	input wire [9:0] SW;
	input wire [3:0] KEY;
	output wire [9:0] LEDR;
	output wire [nX-1:0] VGA_X;       // for DESim VGA
	output wire [nY-1:0] VGA_Y;       // for DESim VGA
	output wire [23:0] VGA_COLOR;     // for DESim VGA
	output wire plot;                 // for DESim VGA

    wire VGA_SYNC;      // can be used to indicate when background drawing is done
    
    //reset from KEY0
	wire resetn;
    assign resetn = KEY[0];

    //wires between falling tile and vga demo
    wire [nX-1:0] tile_x1, tile_x2, tile_x3, tile_x4;
    wire [nY-1:0] tile_y1, tile_y2, tile_y3, tile_y4;
    wire [8:0] tile_color1, tile_color2, tile_color3, tile_color4;
    wire tile_write1, tile_write2, tile_write3, tile_write4;
    wire [2:0] state1, state2, state3, state4;

    wire active1, active2, active3, active4;
    wire enable1, enable2, enable3, enable4; 
    reg gnt1, gnt2, gnt3, gnt4; 

    //instantiate falling tile module
    falling_tile #(.TILE_X(10'd0)) gift_tile1 ( .clk(CLOCK_50), .resetn(resetn), .start_fall(SW[3]), .enable(enable1), .x_pixel_location(tile_x1), .y_pixel_location(tile_y1), .color(tile_color1), .write_to_VGA(tile_write1), .state(state1), .active(active1));
    falling_tile #(.TILE_X(10'd160)) gift_tile2 ( .clk(CLOCK_50), .resetn(resetn), .start_fall(SW[2]), .enable(enable2), .x_pixel_location(tile_x2), .y_pixel_location(tile_y2), .color(tile_color2), .write_to_VGA(tile_write2), .state(state2), .active(active2));
    falling_tile #(.TILE_X(10'd320)) gift_tile3 ( .clk(CLOCK_50), .resetn(resetn), .start_fall(SW[1]), .enable(enable3), .x_pixel_location(tile_x3), .y_pixel_location(tile_y3), .color(tile_color3), .write_to_VGA(tile_write3), .state(state3), .active(active3));
    falling_tile #(.TILE_X(10'd480)) gift_tile4 ( .clk(CLOCK_50), .resetn(resetn), .start_fall(SW[0]), .enable(enable4), .x_pixel_location(tile_x4), .y_pixel_location(tile_y4), .color(tile_color4), .write_to_VGA(tile_write4), .state(state4), .active(active4));
    
    reg [nX-1:0] x;
    reg [nY-1:0] y;
    reg [COLOR_DEPTH-1:0] color;
    reg write;

    reg [1:0] rr_idx;

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn)
            rr_idx <= 2'd0;
        else
            rr_idx <= rr_idx + 2'd1;
    end

    assign enable1 = (rr_idx == 2'd0);
    assign enable2 = (rr_idx == 2'd1);
    assign enable3 = (rr_idx == 2'd2);
    assign enable4 = (rr_idx == 2'd3);

    always @(*) 
    begin
        case (rr_idx)
            2'd0: begin
                x     = tile_x1;
                y     = tile_y1;
                color = tile_color1;
                write = tile_write1;
            end
            2'd1: begin
                x     = tile_x2;
                y     = tile_y2;
                color = tile_color2;
                write = tile_write2;
            end
            2'd2: begin
                x     = tile_x3;
                y     = tile_y3;
                color = tile_color3;
                write = tile_write3;
            end
            2'd3: begin
                x     = tile_x4;
                y     = tile_y4;
                color = tile_color4;
                write = tile_write4;
            end
    endcase
    end

    
    // instantiate the DESim VGA adapter
    `define VGA_MEMORY
    vga_adapter VGA (
        .resetn(resetn),
        .clock(CLOCK_50),
        .color(color),      // used to draw pixels on top of background
        .x(x),              // used to draw pixels on top of background
        .y(y),              // used to draw pixels on top of background
        .write(write),      // used to draw pixels on top of background
        .VGA_X(VGA_X),          // the output VGA x coordinate (column)
        .VGA_Y(VGA_Y),          // the output VGA y coordinate (row)
        .VGA_COLOR(VGA_COLOR),  // the output VGA color
        .VGA_SYNC(VGA_SYNC),    // indicates when background MIF has been drawn
        .plot(plot));           // set to 1 to write a pixel color onto the VGA output
		defparam VGA.RESOLUTION = RESOLUTION;
        // choose background image according to resolution and color depth
		defparam VGA.BACKGROUND_IMAGE = 
            (RESOLUTION == "640x480") ?
                ((COLOR_DEPTH == 9) ? "./MIF/checkers_640_9.mif" :
                ((COLOR_DEPTH == 6) ? "./MIF/checkers_640_6.mif" :
                "./MIF/checkers_640_3.mif")) : 
            ((RESOLUTION == "320x240") ?
                ((COLOR_DEPTH == 9) ? "./MIF/checkers_320_9.mif" :
                ((COLOR_DEPTH == 6) ? "./MIF/checkers_320_6.mif" :
                "./MIF/checkers_320_3.mif")) : 
                    // 160x120
                    ((COLOR_DEPTH == 9) ? "./MIF/checkers_160_9.mif" :
                    ((COLOR_DEPTH == 6) ? "./MIF/checkers_160_6.mif" :
                    "./MIF/checkers_160_3.mif")));
		defparam VGA.COLOR_DEPTH = COLOR_DEPTH;


    assign LEDR[9] = VGA_SYNC;
    assign LEDR[6] = active1;
    assign LEDR[5] = active2;
    assign LEDR[4] = active3;
    assign LEDR[3] = active4;
    assign LEDR[2:0] = state1;

endmodule

module falling_tile (clk, resetn, start_fall, enable, x_pixel_location, y_pixel_location, color, write_to_VGA, state, active); 

    // input ports
    input wire clk;
    input wire resetn;
    input wire start_fall;
    input wire enable; 

    //output ports - 640x480 VGA with 9-bit colour depth
    output reg [9:0]  x_pixel_location;
    output reg [8:0]  y_pixel_location; 
    output reg [8:0]  color; 
    output reg        write_to_VGA;

    //parameters
    parameter TILE_WIDTH    = 160; 
    parameter TILE_HEIGHT   = 120; 
    parameter SCREEN_WIDTH  = 640; 
    parameter SCREEN_HEIGHT = 480; 
    parameter COLOR_DEPTH   = 9; 
    parameter MAX_Y         = SCREEN_HEIGHT - TILE_HEIGHT;  // 480 - 120 = 360
    parameter BG_COLOR      = 9'b001_011_010;
    parameter TILE_X   = 0; 

    //column 1 
    reg [9:0] tile_x  = TILE_X; // fixed column
    reg [8:0] tile_y  = 9'd0; // current row (top of tile)
    reg [8:0] erase_y = 9'd0; // previous row (to erase)

    //pixels within the tile
    reg [7:0] x_tile_px; //0-160
    reg [6:0] y_tile_px; //0-120

    // 160x120 = 19200 → 15 bits
    wire [14:0] sprite_address; 
    wire [8:0]  sprite_color; 
    assign sprite_address = y_tile_px * TILE_WIDTH + x_tile_px; 

    //instantiate the sprite ROM
    gift #(
        .COLOR_DEPTH(COLOR_DEPTH),
        .TILE_W     (TILE_WIDTH),
        .TILE_H     (TILE_HEIGHT)
    ) gift0 (
        .clock(clk),
        .addr (sprite_address),
        .q    (sprite_color)
    ); 
    
    // falling speed - increment tile y by using a counter
    reg [25:0] fall_counter; 
    parameter FALL_SPEED = 26'd50; // tweak for how long it sits in each row

    //fsm states for drawing the falling tile
    parameter TILE_SPAWN    = 3'd0; // first draw at top of the display
    parameter TILE_WAIT     = 3'd1; // tile sitting still
    parameter TILE_ERASE    = 3'd2; // erase old row
    parameter TILE_DRAW     = 3'd3; // draw tile at new row
    parameter TILE_DONE     = 3'd4; // not used

    output reg [2:0] state;
    reg row_done; // high when 160x120 scan completes
    reg erasing_bottom;
    output reg active; 
   
    always @(posedge clk or negedge resetn) 
        begin
            if(enable)
                begin
                    if (!resetn) 
                        begin 
                            //reset all values
                            tile_y              <= 9'd0;
                            erase_y             <= 9'd0;
                            fall_counter        <= 26'd0;
                            state               <= TILE_DONE;
                            x_tile_px           <= 8'd0;
                            y_tile_px           <= 7'd0;

                            x_pixel_location    <= 10'd0;
                            y_pixel_location    <= 9'd0;
                            color               <= 9'd0;
                            write_to_VGA        <= 1'b0;
                            row_done            <= 1'b0;
                            active              <= 1'b0;
                        end 
                    else 
                        begin
                            row_done        <= 1'b0;
                            write_to_VGA    <= 1'b0; // default

                            case (state)
                                
                                // First time: just draw the tile at y=0
                                TILE_SPAWN: 
                                begin

                                    active <= 1'b1;
                                    if (row_done) 
                                    begin
                                        state       <= TILE_WAIT;
                                        x_tile_px   <= 8'd0;
                                        y_tile_px   <= 7'd0;
                                    end

                                    // draw gift at current tile_y
                                    write_to_VGA        <= 1'b1;
                                    x_pixel_location    <= tile_x + x_tile_px;
                                    y_pixel_location    <= tile_y + y_tile_px;
                                    color               <= sprite_color;
                                end

                                // tile is waiting in one row
                                TILE_WAIT: 
                                begin
                                    if (fall_counter == FALL_SPEED) 
                                        begin
                                        fall_counter <= 26'd0;

                                        // remember old row to erase
                                        erase_y <= tile_y;

                                        // compute NEW row → stop-motion jump by TILE_HEIGHT
                                        if (tile_y + TILE_HEIGHT <= MAX_Y)
                                            tile_y <= tile_y + (TILE_HEIGHT);   // 0→120→240→360
                                        else
                                            tile_y <= MAX_Y;                     // reset to top
                                        
                                        erasing_bottom <= (tile_y == MAX_Y);

                                        // start erase pass for old row
                                        state     <= TILE_ERASE;
                                        x_tile_px <= 8'd0;
                                        y_tile_px <= 7'd0;
                                        end 
                                    else 
                                        begin
                                            fall_counter <= fall_counter + 1'b1;
                                            write_to_VGA <= 1'b0;
                                        end
                                end

                                // Erase old row (one 160x120 pass)
                                TILE_ERASE: 
                                begin
                                    // erase old row with background
                                    write_to_VGA     <= 1'b1;
                                    x_pixel_location <= tile_x + x_tile_px;
                                    y_pixel_location <= erase_y + y_tile_px;
                                    color            <= BG_COLOR; 

                                    if (row_done) 
                                        begin
                                            if(erasing_bottom)
                                                state <= TILE_DONE; // no movement, so no draw
                                            else
                                                begin
                                                state     <= TILE_DRAW; // now draw in new row
                                                x_tile_px <= 8'd0;
                                                y_tile_px <= 7'd0;
                                                end
                                        end

                                    
                                end

                                // Draw tile in new row (one 160x120 pass)
                                TILE_DRAW: begin
                                    if (row_done) begin
                                        state     <= TILE_WAIT; // then wait again
                                        x_tile_px <= 8'd0;
                                        y_tile_px <= 7'd0;
                                    end
                                    // draw gift at current tile_y
                                    write_to_VGA     <= 1'b1;
                                    x_pixel_location <= tile_x + x_tile_px;
                                    y_pixel_location <= tile_y + y_tile_px;
                                    color            <= sprite_color;
                                end

                                TILE_DONE: 
                                begin
                                    if(start_fall) 
                                        begin
                                            // start over at top
                                            tile_y      <= 9'd0;
                                            erase_y     <= 9'd0;
                                            fall_counter<= 26'd0;
                                            state       <= TILE_SPAWN;
                                            x_tile_px   <= 8'd0;
                                            y_tile_px   <= 7'd0;
                                        end
                                    else
                                        begin
                                            write_to_VGA <= 1'b0;
                                            state        <= TILE_DONE;
                                            active      <= 1'b0;
                                        end
                                end
                                default: state <= TILE_DONE;
                    endcase

                    // Only scan the 160x120 rect while drawing/erasing
                    if (state == TILE_ERASE || state == TILE_DRAW || state == TILE_SPAWN) 
                        begin
                            if (x_tile_px == TILE_WIDTH - 1) 
                                begin
                                    x_tile_px <= 8'd0;
                                    if (y_tile_px == TILE_HEIGHT - 1) 
                                        begin
                                            y_tile_px <= 7'd0;
                                            row_done <= 1'b1;  // finished full 160x120 pass
                                        end 
                                    else 
                                        y_tile_px <= y_tile_px + 1'b1;
                                end
                            else 
                                x_tile_px <= x_tile_px + 1'b1;
                        end
                end
                end
    end

endmodule

