module tb_controller_datapath();
    //inputs
    logic [2:0] spawn_count;
    logic [2:0] shift_count1;
    logic [2:0] shift_count2;
    logic [2:0] shift_count3;

    //outputs
    logic spawn_done;
    logic shift1_done;
    logic shift2_done;
    logic shift3_done;

    //error counter
    int errors = 0;

    controller_datapath dut (
        .spawn_count(spawn_count),
        .shift_count1(shift_count1),
        .shift_count2(shift_count2),
        .shift_count3(shift_count3),
        .spawn_done(spawn_done),
        .shift1_done(shift1_done),
        .shift2_done(shift2_done),
        .shift3_done(shift3_done)
    );

    initial begin
        spawn_count = 0;
        shift_count1 = 0;
        shift_count2 = 0;
        shift_count3 = 0;

        //spawn_done
        #1;
        assert (spawn_done == 0)
            else begin
                $error("spawn_done should be 0 when spawn_count = 0");
                errors++;
            end

        #10;
        spawn_count = 3;
        #1;
        assert (spawn_done == 0)
            else begin
                $error("spawn_done should be 0 when spawn_count = 3");
                errors++;
            end

        #10;
        spawn_count = 4;
        #1;
        assert (spawn_done == 1)
            else begin
                $error("spawn_done should be 1 when spawn_count = 4");
                errors++;
            end

        #10;
        spawn_count = 5;
        #1;
        assert (spawn_done == 1)
            else begin
                $error("spawn_done should be 1 when spawn_count = 5");
                errors++;
            end

        //shift1_done
        #1;
        assert (shift1_done == 0)
            else begin
                $error("shift1_done should be 0 when shift_count1 = 0");
                errors++;
            end

        #10;
        shift_count1 = 3;
        #1;
        assert (shift1_done == 0)
            else begin
                $error("shift1_done should be 0 when shift_count1 = 3");
                errors++;
            end

        #10;
        shift_count1 = 4;
        #1;
        assert (shift1_done == 1) 
        else begin
            $error("shift1_done should be 1 when shift_count1 = 4");
            errors++;
        end
        
        //shift2_done
        #1;
        assert (shift2_done == 0)
            else begin 
                $error("shift2_done should be 0 when shift_count2 = 0");
                errors++;
            end

        #10;
        shift_count2 = 3;
        #1;
        assert (shift2_done == 0)
            else begin 
                $error("shift2_done should be 0 when shift_count2 = 3");
                errors++;
            end

        #10;
        shift_count2 = 4;
        #1;
        assert (shift2_done == 1)
            else begin
                $error("shift2_done should be 1 when shift_count2 = 4");
                errors++;
            end

        //shift3_done
        #1;
        assert (shift3_done == 0)
            else begin
                $error("shift3_done should be 0 when shift_count3 = 0");
                errors++;
            end
        
        #10;
        shift_count3 = 3;
        #1;
        assert (shift3_done == 0)
            else begin
                $error("shift3_done should be 0 when shift_count3 = 3");
                errors++;
            end
        
        #10;
        shift_count3 = 4;
        #1;
        assert (shift3_done == 1)
            else begin
                $error("shift3_done should be 1 when shift_count3 = 4");
                errors++;
            end

        #10;

        if (errors == 0) begin
            $display("tb_controller_datapath PASSED");
        end
        else begin
            $display("tb_controller_datapath FAILED with %0d errors", errors);
        end

        $stop;
    end
endmodule