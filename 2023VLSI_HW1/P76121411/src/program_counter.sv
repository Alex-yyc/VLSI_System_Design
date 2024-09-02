module program_counter (
    input  clk , 
    input rst , 
    input [31:0] PC_in , 
    input PC_write , 
    output reg  [31:0]PC_out
);


    always_ff @(posedge clk or posedge rst) begin
        if(rst)begin
            PC_out <= 32'b0;
        end
        else  begin
            if(PC_write)
                PC_out <= PC_in;
        end
    end

endmodule