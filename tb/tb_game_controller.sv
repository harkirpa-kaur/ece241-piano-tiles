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

    initial begin
        resetn = 0;
        start = 0;
        spawn_done = 0;
        shift1_done = 0;
        shift2_done = 0;
        shift3_done = 0;

        //state = WAIT
        //resetn = 0
        @(posedge clk);
        #1;
        assert (state == WAIT)
            else begin
                $error("state should be WAIT when resetn = 0");
                errors++;
            end

        //resetn = 1, start = 0
        @(negedge clk);
        resetn = 1;
        @(posedge clk);
        #1;
        //verify state
        assert (state == WAIT)
            else begin
                $error("state should be WAIT when resetn = 1 and start = 0");
                errors++;
            end
        
        //SPAWN state
        //start = 1, spawn_done = 0
        @(negedge clk);
        start = 1;
        @(posedge clk);
        #1;
        assert (state == SPAWN)
            else begin
                $error("state should be SPAWN when start = 1 and spawn_done = 0");
                errors++;
            end
        //ensure state remains SPAWN while spawn_done = 0
        @(negedge clk);
        start = 0;
        @(posedge clk);
        #1;
        assert (state == SPAWN)
            else begin
                $error("state should remain SPAWN while start = 0 and current state is SPAWN");
                errors++;
            end

        //SHIFT1 state
        //spawn_done = 1, shift1_done = 0
        @(negedge clk);
        spawn_done = 1;
        @(posedge clk);
        #1;
        assert (state == SHIFT1)
            else begin
                $error("state should be SHIFT1 when spawn_done = 1 and shift1_done = 0");
                errors++;
            end
        //ensure state remains SHIFT1 while shift1_done = 0
        @(negedge clk);
        spawn_done = 0;
        @(posedge clk);
        #1;
        assert (state == SHIFT1)
            else begin
                $error("state should remain SHIFT1 while shift1_done = 0 and current state is SHIFT1");
                errors++;
            end

        //SHIFT2 state
        //shift1_done = 1, shift2_done = 0
        @(negedge clk);
        shift1_done = 1;
        @(posedge clk);
        #1;
        assert (state == SHIFT2)
            else begin
                $error("state should be SHIFT2 when shift1_done = 1 and shift2_done = 0");
                errors++;
            end
        //ensure state remains SHIFT2 while shift2_done = 0
        @(negedge clk);
        shift1_done = 0;
        @(posedge clk);
        #1;
        assert (state == SHIFT2)
            else begin
                $error("state should remain SHIFT2 while shift2_done = 0 and current state is SHIFT2");
                errors++;
            end

        //SHIFT3 state
        //shift2_done = 1, shift3_done = 0
        @(negedge clk);
        shift2_done = 1;
        @(posedge clk);
        #1;
        assert (state == SHIFT3)
            else begin
                $error("state should be SHIFT3 when shift2_done = 1 and shift3_done = 0");
                errors++;
            end
        //ensure state remains SHIFT3 while shift3_done = 0
        @(negedge clk);
        shift2_done = 0;
        @(posedge clk);
        #1;
        assert (state == SHIFT3)
            else begin
                $error("state should remain SHIFT3 while shift3_done = 0 and current state is SHIFT3");
                errors++;
            end

        //return to SPAWN state
        //shift3_done = 1
        @(negedge clk);
        shift3_done = 1;
        @(posedge clk);
        #1;
        assert (state == SPAWN)
            else begin
                $error("state should be SPAWN when shift3_done = 1");
                errors++;
            end
        //ensure state remains SPAWN while shift3_done = 0
        @(negedge clk);
        shift3_done = 0;
        @(posedge clk);
        #1;
        assert (state == SPAWN)
            else begin
                $error("state should remain SPAWN while shift3_done = 0 and current state is SPAWN");
                errors++;
            end

        if (errors == 0) begin
            $display("tb_game_controller PASSED");
        end else begin
            $display("tb_game_controller FAILED with %0d errors", errors);
        end

        $stop;
    end
endmodule