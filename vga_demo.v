`default_nettype none

/*  This code animates two colored objects that move up/down on the display. The objects 
 *  "bounce" off the top and bottom of the display and reverse directions. To run the demo
 *  first press/release KEY[0] to reset the circuit. Select one object by making SW[9] = 0.
 *  Then, press/release KEY[1] to set the object's color according to switches SW[8:0] 
 *  (9-bit color), or SW[5:0] (6-bit color), or SW[2:0] (3-bit color). Press KEY[2] to increase
 *  the speed of the selected object, or press KEY[3] to decrease the speed. Set SW[9] = 1
 *  to select the other object, then use KEY[1] to KEY[3] to set its color and/or speed.
 *
 *  The code supports three VGA resolutions and three different color depths. 
 *
 *  A background image (MIF) is displayed on the VGA display.
*/

module vga_demo(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
				VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	
    parameter RESOLUTION = "160x120"; // "640x480" "320x240" "160x120"

    // specify the color depth. This design supports depths of 9, 6, and 3
    parameter COLOR_DEPTH = 3; // 9 6 3

    // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
    // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);

    // state codes for FSM that choses which object to draw at a given time
    //parameter A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;

    parameter IDLE = 3'd0, COLUMN1=3'd1, COLUMN2=3'd2, COLUMN3=3'd3, COLUMN4 = 3'd4; 

	input wire CLOCK_50;	
	input wire [9:0] SW;
	input wire [3:0] KEY;
	output wire [9:0] LEDR;
	output wire [7:0] VGA_R;
	output wire [7:0] VGA_G;
	output wire [7:0] VGA_B;
	output wire VGA_HS;
	output wire VGA_VS;
	output wire VGA_BLANK_N;
	output wire VGA_SYNC_N;
	output wire VGA_CLK;	

	wire [nX-1:0] Ox [0:3];
	wire [nY-1:0] Oy [0:3];
	wire [COLOR_DEPTH-1:0] Ocolor [0:3];
    wire [3:0] Owrite;
	reg [nX-1:0] MUX_x;
	reg [nY-1:0] MUX_y;
	reg [COLOR_DEPTH-1:0] MUX_color;
    reg MUX_write;
    wire [3:0] req;
    reg [3:0] gnt;
    reg [2:0] y_Q, Y_D; 

    wire        t;
    wire [3:0]  b;

    third_counter  tc (.CLOCK_50(CLOCK_50), .t(t));
    shift_register sr (.CLOCK_50(CLOCK_50), .enable(t), .b(b));

    localparam integer XW = (RESOLUTION == "320x240") ? 320 : 
                            (RESOLUTION == "640x480") ? 640 : 160;
    localparam integer LANE_W = XW/4;
    localparam [nX-1:0] L0_X = {nX{1'b0}};               // 0
    localparam [nX-1:0] L1_X = LANE_W[nX-1:0];
    localparam [nX-1:0] L2_X = (2 * LANE_W) & {nX{1'b1}};
    localparam [nX-1:0] L3_X = (3 * LANE_W) & {nX{1'b1}};

	
    wire Resetn, faster, slower, set_color;

    assign Resetn = KEY[0];
    sync S1 (~KEY[1], Resetn, CLOCK_50, set_color);
    sync S2 (~KEY[2], Resetn, CLOCK_50, faster);
    sync S3 (~KEY[3], Resetn, CLOCK_50, slower);

    // Agorithm: the FSM below uses an arbitration scheme to draw one object at a time, either
    // object 1 or object 2. Each object makes a request when it wants to be drawn, and then 
    // receives a grant when it is selected for display. The object releases its request when 
    // its drawing cycle is complete. A drawing cycle means that the object is erased from where
    // it was drawn "last time" and has moved to its new location and been drawn again.
    always @ (*)
        case (y_Q)
            IDLE:  
            begin
                if (req[0]) Y_D = COLUMN1;          // see if tile 1 wants to be drawn
                else if (req[1]) Y_D = COLUMN2;          // see if tile 2 wants to be drawn
                else if (req[2]) Y_D = COLUMN3;          // see if tile 3 wants to be drawn
                else if (req[3]) Y_D = COLUMN4;          // see if tile 4 wants to be drawn
                else Y_D = IDLE;
            end
            COLUMN1:
             if (!req[0]) Y_D = IDLE;
            COLUMN2:
             if (!req[1]) Y_D = IDLE;
            COLUMN3:
             if (!req[2]) Y_D = IDLE;
            COLUMN4:
             if (!req[3]) Y_D = IDLE;
            default:  Y_D = IDLE;
        endcase

    // FSM outputs to drive the VGA display from either object 1 or object 2
    always @ (*)
    begin
        // default assignments
        gnt[0] = 1'b0; gnt[1] = 1'b0; gnt[2] = 1'b0; gnt[3] = 1'b0; MUX_write = 1'b0;
        MUX_x = Ox[0]; MUX_y = Oy[0]; MUX_color = Ocolor[0];
        case (y_Q)
            IDLE:  ;
            COLUMN1:  begin gnt[0] = 1'b1; MUX_write = Owrite[0]; 
                      MUX_x = Ox[0]; MUX_y = Oy[0]; MUX_color = Ocolor[0]; end
            COLUMN2:  begin gnt[1] = 1'b1; MUX_write = Owrite[1];
                      MUX_x = Ox[1]; MUX_y = Oy[1]; MUX_color = Ocolor[1]; end
            COLUMN3:  begin gnt[2] = 1'b1; MUX_write = Owrite[2]; 
                      MUX_x = Ox[2]; MUX_y = Oy[2]; MUX_color = Ocolor[2]; end
            COLUMN4:  begin gnt[3] = 1'b1; MUX_write = Owrite[3]; 
                      MUX_x = Ox[3]; MUX_y = Oy[3]; MUX_color = Ocolor[3]; end
        endcase
    end

    // FSM state flip-flops
    always @(posedge CLOCK_50)
        if (Resetn == 0)   // wait until ready
            y_Q <= IDLE;
        else
            y_Q <= Y_D;

    wire [3:0] lane_spawn = b & {4{t}};
    wire [3:0] busy;

    // instantiate object 0
    object O0 (Resetn, CLOCK_50, gnt[0], !SW[9], set_color, SW[8:0], faster, slower, L0_X, lane_spawn[0], busy[0], req[0], 
               Ox[0], Oy[0], Ocolor[0], Owrite[0]);
        defparam O0.RESOLUTION = RESOLUTION;
        defparam O0.nX = nX;
        defparam O0.nY = nY;
        defparam O0.COLOR_DEPTH = COLOR_DEPTH;
        defparam O0.X_INIT = L0_X;

        // instantiate object 1
    object O1 (Resetn, CLOCK_50, gnt[1], !SW[9], set_color, SW[8:0], faster, slower, L1_X, lane_spawn[1], busy[1], req[1], 
               Ox[1], Oy[1], Ocolor[1], Owrite[1]);
        defparam O1.RESOLUTION = RESOLUTION;
        defparam O1.nX = nX;
        defparam O1.nY = nY;
        defparam O1.COLOR_DEPTH = COLOR_DEPTH;
        defparam O1.X_INIT = L1_X;

        // instantiate object 2
    object O2 (Resetn, CLOCK_50, gnt[2], !SW[9], set_color, SW[8:0], faster, slower, L2_X, lane_spawn[2], busy[2], req[2], 
               Ox[2], Oy[2], Ocolor[2], Owrite[2]);
        defparam O2.RESOLUTION = RESOLUTION;
        defparam O2.nX = nX;
        defparam O2.nY = nY;
        defparam O2.COLOR_DEPTH = COLOR_DEPTH;
        defparam O2.X_INIT = L2_X;
    
        // instantiate object 3
    object O3 (Resetn, CLOCK_50, gnt[3], !SW[9], set_color, SW[8:0], faster, slower, L3_X, lane_spawn[3], busy[3], req[3], 
               Ox[3], Oy[3], Ocolor[3], Owrite[3]);
        defparam O3.RESOLUTION = RESOLUTION;
        defparam O3.nX = nX;
        defparam O3.nY = nY;
        defparam O3.COLOR_DEPTH = COLOR_DEPTH;
        defparam O3.X_INIT = L3_X;

    // connect to VGA controller
    vga_adapter VGA (
		.resetn(KEY[0]),
		.clock(CLOCK_50),
		.color(MUX_color),
		.x(MUX_x),
		.y(MUX_y),
		.write(MUX_write),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
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

    assign LEDR[9] = 1'b0;
    assign LEDR[8:0] = (COLOR_DEPTH == 9) ? SW[8:0] : ((COLOR_DEPTH == 6) ? {3'b0,SW[5:0]} :
                       {6'b0,SW[2:0]});

endmodule

// syncronizer, implemented as two FFs in series
module sync(D, Resetn, Clock, Q);
    input wire D;
    input wire Resetn, Clock;
    output reg Q;

    reg Qi; // internal node

    always @(posedge Clock)
        if (Resetn == 0) begin
            Qi <= 1'b0;
            Q <= 1'b0;
        end
        else begin
            Qi <= D;
            Q <= Qi;
        end
endmodule

// n-bit register with sync reset and enable
module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (Resetn == 0)
            Q <= 'b0;
        else if (E)
            Q <= R;
endmodule

// toggle flip-flop with reset
module ToggleFF(T, Resetn, Clock, Q);
    input wire T, Resetn, Clock;
    output reg Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 1'b0;
        else if (T)
            Q <= ~Q;
endmodule

// up/down counter with reset, enable, and load controls
module UpDn_count (R, Clock, Resetn, E, L, UpDn, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L, UpDn;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (L == 1)
            Q <= R;
        else if (E)
            if (UpDn == 1)
                Q <= Q + 1'b1;
            else
                Q <= Q - 1'b1;
endmodule

// counter
module Up_count (Clock, Resetn, Q);
    parameter n = 8;
    input wire Clock, Resetn;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 'b0;
        else 
            Q <= Q + 1'b1;
endmodule

// implements a moving colored object
module object (Resetn, Clock, gnt, sel, set_color, new_color, faster, slower, LX, spawn, busy, req,  
               VGA_x, VGA_y, VGA_color, VGA_write);

    parameter RESOLUTION = "160x120"; // default to low resolution
    // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
    // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);
    parameter COLOR_DEPTH = 3;        // default to low color depth

    parameter XSCREEN = (RESOLUTION == "640x480") ? 640 : ((RESOLUTION == "320x240") ? 320 : 160);
    parameter YSCREEN = (RESOLUTION == "640x480") ? 480 : ((RESOLUTION == "320x240") ? 240 : 120);

    parameter XDIM = XSCREEN/4, YDIM = 12; // object's width and height

    // default initial location of the object 
    parameter X_INIT = (RESOLUTION == "640x480") ? 10'd439 : ((RESOLUTION == "320x240") ?  9'd219 : 8'd109);
    //parameter Y_INIT = (RESOLUTION == "640x480") ? 9'd239 : ((RESOLUTION == "320x240") ?  8'd119 : 7'd59);
    parameter [nY-1:0] Y_INIT = 'd0;

    parameter ALT = {COLOR_DEPTH{1'b0}}; // erasure color

    parameter KK = 24; // controls animation speed (use 16 for DESim, 5 for ModelSim)
    parameter MM = 8;  // animation speed up/down mask (use 6 for DESim, 2 for ModelSim)

    // state codes
    parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011,
              E = 4'b0100, F = 4'b0101, G = 4'b0110, H = 4'b0111,
              I = 4'b1000, J = 4'b1001, K = 4'b1010, L = 4'b1011;

    input wire Resetn, Clock;
    input wire gnt;  // set to 1 when this object is selected for VGA display
    input wire sel;  // when 1, this object's color and speed can be changed
    input wire set_color;        // new color
    input wire faster, slower;   // used to increase/decrease the object's speed
    input wire [COLOR_DEPTH-1:0] new_color; // used when setting the color
    input wire [nX-1:0] LX;
    input wire spawn;
    output reg busy;
    output reg req; // object sets this request to 1 when it wants to be displayed
	output wire [nX-1:0] VGA_x;                 // pixel x coordinate output
	output wire [nY-1:0] VGA_y;                 // pixel y coordinate ouput
	output wire [COLOR_DEPTH-1:0] VGA_color;    // pixel color output
    output wire VGA_write;                      // control output to write a pixel

	wire [nX-1:0] X, XC, X0;    // used to traverse the object's width
	wire [nY-1:0] Y, YC, Y0;    // used to traverse the object's height
	wire [COLOR_DEPTH-1:0] the_color, color;    // used when setting the color
    wire [KK-1:0] slow;     // used to synchronize the object's speed using a counter
    reg Lx, Ly, Ey, Lxc, Lyc, Exc, Eyc; // load and enable signals for the object's 
                                        // location (x,y) and the counters that traverse 
                                        // the object's pixels (XC, YC)
    wire sync;    // sync is for the slow counter, Ydir is the direction of moving
    reg erase;    // erase is used to erase the object. 
    reg [3:0] y_Q, Y_D; // FSM for controlling drawing/erasing of the object
    reg write;          // used to write to a pixel

    // mask logic (speed control)
    reg [2:0] ys_Q, Ys_D;   // FSM to control the object's speed
    reg sll, srl;           // shift the mask left or right
    reg [MM-1:0] mask;      // the mask (see FSM description below)

    assign X0 = LX;
    assign Y0 = Y_INIT;

    wire Ydir = 1'b1; 
    
    UpDn_count U2 (X0, Clock, Resetn, 1'b0, Lx, 1'b0, X);    // object's column location
        defparam U2.n = nX;

    UpDn_count U1 (Y0, Clock, Resetn, Ey, Ly, Ydir, Y);      // object's row location
        defparam U1.n = nY;

    // set default color to white (1...11)
    assign the_color = color == {COLOR_DEPTH{1'b0}} ? {COLOR_DEPTH{1'b1}} : new_color;
    regn UC (the_color, Resetn, (sel && set_color) | (color == {COLOR_DEPTH{1'b0}}), Clock, color); 
        defparam UC.n = COLOR_DEPTH;

    UpDn_count U3 ({nX{1'd0}}, Clock, Resetn, Exc, Lxc, 1'b1, XC); // object column counter
        defparam U3.n = nX;
    UpDn_count U4 ({nY{1'd0}}, Clock, Resetn, Eyc, Lyc, 1'b1, YC); // object row counter
        defparam U4.n = nY;

    Up_count U6 (Clock, Resetn, slow);  // counter to control the speed of moving
        defparam U6.n = KK;

    // wait for the slow counter to contain all 1's. But use the mask bits to avoid waiting
    // for the most-significant counter bits when desired. This mask mechanism has the effect
    // of increasing/descreasing the speed at which the object moves
    assign sync = ((slow | (mask << KK-MM)) == {KK{1'b1}});

    assign VGA_x = X + XC;                          // pixel x coordinate
    assign VGA_y = Y + YC;                          // pixel y coordinate
    assign VGA_color = erase == 0 ? color : ALT;    // pixel color to draw/erase
    assign VGA_write = write;                       // pixel write control

    // track whether a tile is active
    always @(posedge Clock) begin
    if (!Resetn) busy <= 1'b0;
    else if (!busy && spawn) busy <= 1'b1;               // arm on spawn
    else if (busy && (Y == YSCREEN - YDIM) && (y_Q == L)) // after finishing bottom draw
        busy <= 1'b0;                                      // disarm at bottom
    end

    reg busy_q;
    always @(posedge Clock) begin
    if (!Resetn) busy_q <= 1'b0;
    else          busy_q <= busy;
    end
    wire busy_rise = busy & ~busy_q;


    // FSM Algorithm:
    // 1. draw object
    // 2. wait for object's delay time
    // 3. request to draw, wait for grant
    // 4. erase object (maintain request)
    // 5. move object, check for boundary conditions (maintain request)
    // 6. draw object (maintain request)
    // 7. release request, goto 2.

    always @ (*)
        case (y_Q)
            A:  Y_D = B;                        // initialize counters, registers

            B:  if (XC != XDIM-1) Y_D = B;      // initial draw, done once
                else Y_D = C;
            C:  if (YC != YDIM-1) Y_D = B;
                else Y_D = D;

            D:  if (!sync) Y_D = D;             // wait for object's delay time
                else Y_D = E;
            E:  if (!gnt) Y_D = E;              // wait for VGA grant
                else Y_D = F;

            F:  if (XC != XDIM-1) Y_D = F;      // erase object
                else Y_D = G;
            G:  if (YC != YDIM-1) Y_D = F;
                else Y_D = H;

            H:  Y_D = I;                        // move the object
            I:  Y_D = J;

            J:  if (XC != XDIM-1) Y_D = J;      // draw the object
                else Y_D = K;
            K:  if (YC != YDIM-1) Y_D = J;
                else Y_D = L;
            L:  Y_D = D;
            default: Y_D = A;
        endcase

    always @ (*)
    begin
        // default assignments
        Lx = 1'b0; Ly = 1'b0; Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; 
        erase = 1'b0; write = 1'b0; Ey = 1'b0; req = 1'b0;

        if (!busy) begin
            // idle: do nothing, no request
        end else begin
            // one-time init when tile starts
            if (busy_rise) begin
                Ly  = 1'b1;   // Y <= Y0 (top)
                Lxc = 1'b1;   // XC <= 0
                Lyc = 1'b1;   // YC <= 0
            end
        end

        case (y_Q)
            A:  begin Lx = 1'b1; Ly = 1'b1; Lxc = 1'b1; Lyc = 1'b1; end // initialization

            B:  begin Exc = 1'b1; write = 1'b1; end   // color a pixel, incr XC
            C:  begin Lxc = 1'b1; Eyc = 1'b1; end     // reload XC, incr YC

            D:  Lyc = 1'b1; // reload YC
            E:  req = 1'b1; // request a drawing cycle

            // erase the object
            F:  begin req = 1'b1; Exc = 1'b1; erase = 1'b1; write = 1'b1; end
            G:  begin req = 1'b1; Lxc = 1'b1; Eyc = 1'b1; end

            //H:  begin req = 1'b1; Lyc = 1'b1; end

            H: begin
            req = 1'b1;
            Lyc = 1'b1;        // reload YC each cycle
            end


            // move the object
            I:  begin req = 1'b1; Ey = 1'b1; end

            // draw the object
            J:  begin req = 1'b1; Exc = 1'b1; write = 1'b1; end
            K:  begin req = 1'b1; Lxc = 1'b1; Eyc = 1'b1; end
            L:  Lyc = 1'b1; // reload YC, and release the request
        endcase
    end

    // FSM FFs 
    always @(posedge Clock)
    begin
        if (Resetn == 0 || busy_rise)
            y_Q <= A;
        else
            y_Q <= Y_D;
    end

    // specify the mask shift register. Shift in 1's from the MSB to speed up an object's
    // movement, and shift in 0's from the LSB to slow down an object's movement
    always @(posedge Clock) begin
        if (Resetn == 0)
            mask <= 'b0;
        else if (srl) begin
            mask[MM-2:0] <= mask[MM-1:1];
            mask[MM-1] <= 1'b1;
        end
        else if (sll) begin
            mask[MM-1:1] <= mask[MM-2:0];
            mask[0] <= 1'b0;
        end
    end

    // state codes for controlling the mask shift register
    parameter As = 3'b000, Bs = 3'b001, Cs = 3'b010, Ds = 3'b011, Es = 3'b100;

    // FSM for controlling speed of movement
    always @ (*)
        case (ys_Q)
            As: if (sel & faster) Ys_D = Bs;
                else if (sel & slower) Ys_D = Ds;
                else Ys_D = As;
            Bs: Ys_D = Cs;    // one cycle to shift
            Cs: if (sel & faster) Ys_D = Cs; // wait for KEY release
                else Ys_D = As;
            Ds: Ys_D = Es;    // one cycle to shift
            Es: if (sel & slower) Ys_D = Es; // wait for KEY release
                else Ys_D = As;
            default: Ys_D = As;
        endcase
    // FSM outputs
    always @ (*)
    begin
        // default assignments
        sll = 1'b0; srl = 1'b0;
        case (ys_Q)
            As:  ;
            Bs:  srl = 1'b1;    // shift in a 1 from the MSB
            Cs:  ;
            Ds:  sll = 1'b1;    // shift in a 0 from the LSB
            Es:  ;
        endcase
    end

    always @(posedge Clock)
        if (Resetn == 0)
            ys_Q <= As;
        else
            ys_Q <= Ys_D;

endmodule

module third_counter (CLOCK_50, t);
    input CLOCK_50;
    reg [24:0] little = 25'd0;
    output reg t = 1'b0;
    
    always @ (posedge CLOCK_50)
    begin
        if (little == 24'd16666666)
            begin
                little <=24'd0;
                t <= 1'b1;
            end
        else
            begin
                t <= 1'b0;
                little <= little + 1;
            end
    end
    
endmodule

module shift_register (CLOCK_50, enable, b);
    input CLOCK_50, enable;
    output reg [3:0] b;

    reg [71:0] col1 = {1'b0,1'b0,1'b0,1'b1,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
    reg [71:0] col2 = {1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0};
    reg [71:0] col3 = {1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
    reg [71:0] col4 = {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
    
    reg [39:0] test = {4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9};

    always @(posedge CLOCK_50) begin
        if (enable) begin
            b    <= {col1[71], col2[71], col3[71], col4[71]};
            col1 <= {col1[70:0], 1'b0};
            col2 <= {col2[70:0], 1'b0};
            col3 <= {col3[70:0], 1'b0};
            col4 <= {col4[70:0], 1'b0};
        end
    end

endmodule
