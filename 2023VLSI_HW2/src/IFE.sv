`include "program_counter.sv"
module IFE (
    input clk , 
    input rst ,
    input [1:0] BranchCtrl , 
    input [31:0] PC_imm , 
    input [31:0] PC_immrs1 ,

    input Instraction_flush ,
    input IFID_Regwrite ,

    input PC_write ,

    input [31:0] Instraction_out ,

    output reg [31:0] IF_PC_out ,
    output reg [31:0] IF_Instraction_out ,

    output [31:0] PC_out
);

localparam [1:0] PC4 = 2'b00 , PCIMM = 2'b01 , IMMRS1 = 2'b10 ;

reg [31:0] PC_in;
reg [31:0] Wire_PC_out;
wire [31:0] PC_4;

assign PC_4 = Wire_PC_out + 32'd4;
assign PC_out = Wire_PC_out;

always_comb begin
    case (BranchCtrl)
        PCIMM  : PC_in = PC_imm;
        IMMRS1 : PC_in = PC_immrs1;
        default: PC_in = PC_4;
    endcase   
end

program_counter program_counter(
    .clk(clk) , 
    .rst(rst) , 
    .PC_in(PC_in) , 
    .PC_write(PC_write) , 
    .PC_out(Wire_PC_out)
);


always_ff @( posedge clk or posedge rst ) begin
    if (rst) begin
        IF_PC_out <= 32'b0;
        IF_Instraction_out <= 32'b0;
    end else begin
        if(IFID_Regwrite)begin
            IF_PC_out <= Wire_PC_out;

            if(Instraction_flush) IF_Instraction_out <= 32'b0;
            else IF_Instraction_out <= Instraction_out;

        end
    end
end


endmodule
