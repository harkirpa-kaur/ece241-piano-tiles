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
    wire [nX-1:0] tile_x;
    wire [nY-1:0] tile_y;
    wire [8:0] tile_color;
    wire tile_write;

    //instantiate falling tile module
    falling_tile gift_tile ( .clk(CLOCK_50), .resetn(resetn), .x_pixel_location(tile_x), .y_pixel_location(tile_y), .color(tile_color), .write_to_VGA(tile_write) );

    // instantiate the DESim VGA adapter
    `define VGA_MEMORY
    vga_adapter VGA (
        .resetn(resetn),
        .clock(CLOCK_50),
        .color(tile_color),      // used to draw pixels on top of background
        .x(tile_x),              // used to draw pixels on top of background
        .y(tile_y),              // used to draw pixels on top of background
        .write(tile_write),      // used to draw pixels on top of background
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
    assign LEDR[8:0] = (COLOR_DEPTH == 9) ? SW[8:0] : ((COLOR_DEPTH == 6) ? {3'b0,SW[5:0]} :
                       {6'b0,SW[2:0]});


endmodule


module falling_tile (clk, resetn, x_pixel_location, y_pixel_location, color, write_to_VGA); 
    //input ports 
    input wire clk; 
    input wire resetn; 

    //output ports - 640x480 VGA with 9-bit colour depth 
    output reg [9:0] x_pixel_location;
    output reg [8:0] y_pixel_location; 
    output reg [8:0] color; 
    output reg       write_to_VGA; 

    //parameters 
    parameter TILE_WIDTH    = 160; 
    parameter TILE_HEIGHT   = 120; 
    parameter SCREEN_WIDTH  = 640; 
    parameter SCREEN_HEIGHT = 480; 
    parameter COLOR_DEPTH   = 9; 
    parameter MAX_Y         = 360;   // 480 - 120

    // background colour (e.g. your green #266644 -> 9'b001_011_010)
    parameter BG_COLOR      = 9'b001_011_010;

    // tile position
    reg [9:0] tile_x  = 10'd240;  // center horizontally
    reg [8:0] tile_y  = 9'd0;     // current top of tile
    reg [8:0] erase_y = 9'd0;     // previous top (where we erase)

    // pixel coordinates within the tile 
    reg [7:0] x_tile_px; 
    reg [6:0] y_tile_px; 

    // 160x120 = 19200 pixels -> 15 bits to address each pixel 
    wire [14:0] sprite_address; 
    wire [8:0]  sprite_color; 
    assign sprite_address = y_tile_px * TILE_WIDTH + x_tile_px; 

    // instantiate the sprite ROM 
    gift #(
        .COLOR_DEPTH(COLOR_DEPTH),
        .TILE_W     (TILE_WIDTH),
        .TILE_H     (TILE_HEIGHT)
    ) gift0 (
        .clock(clk),
        .addr (sprite_address),
        .q    (sprite_color)
    ); 
    
    // falling speed
    reg [25:0] fall_counter; 
    parameter FALL_SPEED = 26'd5; // tweak for speed

    // simple FSM for erase/draw/hold
    localparam STATE_HOLD  = 2'd0;
    localparam STATE_ERASE = 2'd1;
    localparam STATE_DRAW  = 2'd2;

    reg [1:0] state;
    reg       rect_done; // 1 when we've scanned the whole 160x120

    // ------------------------------------------------------------
    // Movement + state transitions
    // ------------------------------------------------------------
    always @ (posedge clk or negedge resetn) begin 
        if (!resetn) begin 
            tile_y       <= 9'd0; 
            erase_y      <= 9'd0;
            fall_counter <= 26'd0; 
            state        <= STATE_HOLD;
            x_tile_px    <= 8'd0;
            y_tile_px    <= 7'd0;
        end 
        else begin
            case (state)
                STATE_HOLD: begin
                    // tile is just sitting there; wait until it's time to move
                    if (fall_counter == FALL_SPEED) begin
                        fall_counter <= 26'd0;

                        // remember where tile is now, to erase there
                        erase_y <= tile_y;

                        // compute new tile_y right away
                        if (tile_y < MAX_Y)
                            tile_y <= tile_y + 1'd4;
                        else
                            tile_y <= 9'd0;

                        // start erase pass
                        state     <= STATE_ERASE;
                        x_tile_px <= 8'd0;
                        y_tile_px <= 7'd0;
                    end
                    else begin
                        fall_counter <= fall_counter + 1'b1;
                    end
                end

                STATE_ERASE: begin
                    // we are scanning and erasing; wait until full rect is done
                    if (rect_done) begin
                        // now draw the tile in its new position
                        state     <= STATE_DRAW;
                        x_tile_px <= 8'd0;
                        y_tile_px <= 7'd0;
                    end
                end

                STATE_DRAW: begin
                    // we are scanning and drawing; wait until full rect is done
                    if (rect_done) begin
                        // done drawing at new position; hold until next move
                        state     <= STATE_HOLD;
                        x_tile_px <= 8'd0;
                        y_tile_px <= 7'd0;
                    end
                end

                default: state <= STATE_HOLD;
            endcase
        end
    end

    // ------------------------------------------------------------
    // Pixel generation + tile scanning
    // ------------------------------------------------------------
    always @ (posedge clk or negedge resetn) begin 
        if (!resetn) begin 
            x_pixel_location <= 10'd0; 
            y_pixel_location <= 9'd0; 
            color            <= 9'd0; 
            write_to_VGA     <= 1'b0; 
            rect_done        <= 1'b0;
            x_tile_px        <= 8'd0;
            y_tile_px        <= 7'd0;
        end 
        else begin 
            rect_done    <= 1'b0;
            write_to_VGA <= 1'b0; // default: don't draw unless in ERASE/DRAW

            if (state == STATE_ERASE) begin
                // erase old tile with background colour
                write_to_VGA     <= 1'b1;
                x_pixel_location <= tile_x + x_tile_px; 
                y_pixel_location <= erase_y + y_tile_px; 
                color            <= BG_COLOR;
            end
            else if (state == STATE_DRAW) begin
                // draw gift at new position
                write_to_VGA     <= 1'b1;
                x_pixel_location <= tile_x + x_tile_px; 
                y_pixel_location <= tile_y + y_tile_px; 
                color            <= sprite_color;
            end
            else begin
                // STATE_HOLD: don't touch VGA; the already-drawn tile stays on screen
                write_to_VGA <= 1'b0;
            end

            // only scan when we are actively erasing or drawing
            if (state == STATE_ERASE || state == STATE_DRAW) begin
                if (x_tile_px == TILE_WIDTH - 1) begin 
                    x_tile_px <= 8'd0; 
                    if (y_tile_px == TILE_HEIGHT - 1) begin
                        y_tile_px <= 7'd0; 
                        rect_done <= 1'b1;  // finished full 160x120 scan
                    end
                    else begin
                        y_tile_px <= y_tile_px + 1'b1; 
                    end
                end 
                else begin
                    x_tile_px <= x_tile_px + 1'b1; 
                end
            end
        end 
    end
endmodule
