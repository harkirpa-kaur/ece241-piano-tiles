module audio_counter (CLOCK_50, resetn, count);
    input CLOCK_50;
    input resetn;
    reg [27:0] little = 28'd0;
    output reg count;

    always @ (posedge CLOCK_50)
    begin
        if (resetn == 1'b0)
        begin
            little <= 28'd0;
            count <= 1'b0;
        end
        else
        begin
            if (little == 28'd150_000_000) 
            begin
                little <= 28'd0;
                count <= 1'b1;
            end
            else
            begin
                little <= little + 1;
            end
        end
    end
endmodule