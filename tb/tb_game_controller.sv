module tb_game_controller();
    //inputs
    logic clk;
    logic resetn;
    logic start;
    logic spawn_done;
    logic shift1_done;
    logic shift2_done;
    logic shift3_done;

    //outputs
    logic [2:0] state;

    //error counter
    int errors = 0;

    int wait_cycles;
    
    //tile states
    parameter SPAWN = 3'b000, SHIFT1 = 3'b001, SHIFT2 = 3'b010, SHIFT3 = 3'b011, WAIT = 3'b100;

    game_controller dut (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .spawn_done(spawn_done),
        .shift1_done(shift1_done),
        .shift2_done(shift2_done),
        .shift3_done(shift3_done),
        .state(state)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    /* requires higher licence :(
    //covergroup for functional coverage
    covergroup controller_cg @(posedge clk);
        //state visit coverage
        state_cp: coverpoint state {
            bins wait_state   = {WAIT};
            bins spawn_state  = {SPAWN};
            bins shift1_state = {SHIFT1};
            bins shift2_state = {SHIFT2};
            bins shift3_state = {SHIFT3};
        }
        //state transition coverage
        state_transitions: coverpoint state {
            bins wait_to_spawn   = (WAIT   => SPAWN);
            bins spawn_to_shift1 = (SPAWN  => SHIFT1);
            bins shift1_to_shift2 = (SHIFT1 => SHIFT2);
            bins shift2_to_shift3 = (SHIFT2 => SHIFT3);
            bins shift3_to_spawn  = (SHIFT3 => SPAWN);
        }
    endgroup

    controller_cg cg = new();
    */

    //properties for temporal assertions
    property reset_state;
        @(posedge clk)
        (!resetn) |=> (state == WAIT);
    endproperty

    property wait_state;
        @(posedge clk)
        disable iff (!resetn)
        (state == WAIT && !start) |=> (state == WAIT);
    endproperty

    property spawn_state;
        @(posedge clk)
        disable iff (!resetn)
        (state == WAIT && start) |=> (state == SPAWN);
    endproperty

    property hold_spawn;
        @(posedge clk)
        disable iff (!resetn)
        (state == SPAWN && !spawn_done) |=> (state == SPAWN);
    endproperty

    property shift1_state;
        @(posedge clk)
        disable iff (!resetn)
        (state == SPAWN && spawn_done) |=> (state == SHIFT1);
    endproperty

    property hold_shift1;
        @(posedge clk)
        disable iff (!resetn)
        (state == SHIFT1 && !shift1_done) |=> (state == SHIFT1);
    endproperty

    property shift2_state;
        @(posedge clk)
        disable iff (!resetn)
        (state == SHIFT1 && shift1_done) |=> (state == SHIFT2);
    endproperty

    property hold_shift2;
        @(posedge clk)
        disable iff (!resetn)
        (state == SHIFT2 && !shift2_done) |=> (state == SHIFT2);
    endproperty

    property shift3_state;
        @(posedge clk)
        disable iff (!resetn)
        (state == SHIFT2 && shift2_done) |=> (state == SHIFT3);
    endproperty

    property hold_shift3;
        @(posedge clk)
        disable iff (!resetn)
        (state == SHIFT3 && !shift3_done) |=> (state == SHIFT3);
    endproperty

    property respawn;
        @(posedge clk)
        disable iff (!resetn)
        (state == SHIFT3 && shift3_done) |=> (state == SPAWN);
    endproperty

    //temporal assertions
    a_reset: assert property (reset_state)
        else begin
            $error("Reset did not force WAIT");
            errors++;
        end

    a_wait: assert property (wait_state)
        else begin
            $error("WAIT did not hold while start = 0");
            errors++;
        end

    a_spawn: assert property (spawn_state)
        else begin
            $error("WAIT did not transition to SPAWN");
            errors++;
        end

    a_hold_spawn: assert property (hold_spawn)
        else begin
            $error("SPAWN did not hold while spawn_done = 0");
            errors++;
        end

    a_shift1: assert property (shift1_state)
        else begin
            $error("SPAWN did not transition to SHIFT1");
            errors++;
        end

    a_hold_shift1: assert property (hold_shift1)
        else begin
            $error("SHIFT1 did not hold while shift1_done = 0");
            errors++;
        end

    a_shift2: assert property (shift2_state)
        else begin
            $error("SHIFT1 did not transition to SHIFT2");
            errors++;
        end

    a_hold_shift2: assert property (hold_shift2)
        else begin 
            $error("SHIFT2 did not hold while shift2_done = 0");
            errors++;
        end

    a_shift3: assert property (shift3_state)
        else begin 
            $error("SHIFT2 did not transition to SHIFT3");
            errors++;
        end

    a_hold_shift3: assert property (hold_shift3)
        else begin
            $error("SHIFT3 did not hold while shift3_done = 0");
            errors++;
        end

    a_respawn: assert property (respawn)
        else begin
            $error("SHIFT3 did not transition to SPAWN");
            errors++;
        end

    initial begin
        resetn = 0;
        start = 0;
        spawn_done = 0;
        shift1_done = 0;
        shift2_done = 0;
        shift3_done = 0;

        @(posedge clk);
        #1;
        @(negedge clk);
        resetn = 1;
        
        @(posedge clk);
        #1;
        @(negedge clk);
        start = 1;
       
        @(posedge clk);
        #1;
        @(negedge clk);
        start = 0;
        
        @(posedge clk);
        #1;
        @(negedge clk);
        spawn_done = 1;

        @(posedge clk);
        #1;
        @(negedge clk);
        spawn_done = 0;
        
        @(posedge clk);
        #1;
        @(negedge clk);
        shift1_done = 1;
        
        @(posedge clk);
        #1;
        @(negedge clk)
        shift1_done = 0;
        
        @(posedge clk);
        #1;
        @(negedge clk);
        shift2_done = 1;
       
        @(posedge clk);
        #1;
        @(negedge clk);
        shift2_done = 0;
        
        @(posedge clk);
        #1;
        @(negedge clk);
        shift3_done = 1;
        
        @(posedge clk);
        #1;
        @(negedge clk);
        shift3_done = 0;
        
        @(posedge clk);
        #1;
        
        @(posedge clk);
        #1;

        //randomized stimulus
        repeat(20) begin
            //spawn state
            wait_cycles = $urandom_range(0, 5);
            $display("SPAWN wait cycles: %0d", wait_cycles);
            repeat (wait_cycles) begin
                @(posedge clk);
            end

            @(negedge clk);
            spawn_done = 1;

            @(posedge clk);
            #1;

            @(negedge clk);
            spawn_done = 0;

            //shift1 state
            wait_cycles = $urandom_range(0, 5);

            repeat (wait_cycles) begin
                @(posedge clk);
            end

            @(negedge clk);
            shift1_done = 1;

            @(posedge clk);
            #1;

            @(negedge clk);
            shift1_done = 0;

            //shift2 state
            wait_cycles = $urandom_range(0, 5);

            repeat (wait_cycles) begin
                @(posedge clk);
            end

            @(negedge clk);
            shift2_done = 1;

            @(posedge clk);
            #1;

            @(negedge clk);
            shift2_done = 0;

            //shift3 state
            wait_cycles = $urandom_range(0, 5);
            
            repeat(wait_cycles) begin
                @(posedge clk);
            end

            @(negedge clk);
            shift3_done = 1;

            @(posedge clk);
            #1;

            @(negedge clk);
            shift3_done = 0;
        end

        @(posedge clk);
        #1;
        
        //result printing
        if (errors == 0) begin
            $display("tb_game_controller PASSED");
        end else begin
            $display("tb_game_controller FAILED with %0d errors", errors);
        end

        //$display("Controller coverage = %0.2f%%", cg.get_inst_coverage());

        $stop;
    end
endmodule