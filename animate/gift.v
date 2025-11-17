module gift #(
    parameter COLOR_DEPTH = 9,
    parameter TILE_W = 160,
    parameter TILE_H = 120
)(
    input  wire                            clock,
    input  wire [$clog2(TILE_W*TILE_H)-1:0] addr,
    output wire [COLOR_DEPTH-1:0]          q
);
    localparam NUM_WORDS = TILE_W * TILE_H;
    localparam ADDR_BITS = $clog2(NUM_WORDS);

    altsyncram GiftROM (
        .address_a      (addr),
        .clock0         (clock),
        .q_a            (q),
        .aclr0          (1'b0),
        .aclr1          (1'b0),
        .address_b      (1'b1),
        .addressstall_a (1'b0),
        .addressstall_b (1'b0),
        .byteena_a      (1'b1),
        .byteena_b      (1'b1),
        .clock1         (1'b1),
        .clocken0       (1'b1),
        .clocken1       (1'b1),
        .clocken2       (1'b1),
        .clocken3       (1'b1),
        .data_a         ({COLOR_DEPTH{1'b0}}),
        .data_b         (1'b0),
        .eccstatus      (),
        .q_b            (),
        .rden_a         (1'b1),
        .rden_b         (1'b1),
        .wren_a         (1'b0),
        .wren_b         (1'b0)
    );
    defparam
        GiftROM.address_aclr_a         = "NONE",
        GiftROM.clock_enable_input_a   = "BYPASS",
        GiftROM.clock_enable_output_a  = "BYPASS",
        GiftROM.init_file              = "./MIF/gift.mif", // your sprite file
        GiftROM.intended_device_family = "Cyclone V",
        GiftROM.lpm_hint               = "ENABLE_RUNTIME_MOD=NO",
        GiftROM.lpm_type               = "altsyncram",
        GiftROM.numwords_a             = NUM_WORDS,
        GiftROM.operation_mode         = "ROM",
        GiftROM.outdata_aclr_a         = "NONE",
        GiftROM.outdata_reg_a          = "UNREGISTERED",
        GiftROM.widthad_a              = ADDR_BITS,
        GiftROM.width_a                = COLOR_DEPTH,
        GiftROM.width_byteena_a        = 1,
        GiftROM.power_up_uninitialized = "FALSE";

endmodule
