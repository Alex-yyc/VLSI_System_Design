module Forwarding_Unit (
    input [4:0] ID_rs1_addr , 
    input [4:0] ID_rs2_addr ,
    input EXE_RegWrite , 
    input [4:0] EXE_rd_addr ,
    input MEM_RegWrite ,
    input [4:0] MEM_rd_addr ,

    output reg [1:0] Forwarding_rs1_src ,
    output reg [1:0] Forwarding_rs2_src
);
    always_comb begin
        if (EXE_RegWrite && (ID_rs1_addr == EXE_rd_addr)) 
            Forwarding_rs1_src = 2'b01;
        else if (MEM_RegWrite && (ID_rs1_addr == MEM_rd_addr))
            Forwarding_rs1_src = 2'b10;
        else 
            Forwarding_rs1_src = 2'b00;
    end

    always_comb begin
        if (EXE_RegWrite && (ID_rs2_addr == EXE_rd_addr)) 
            Forwarding_rs2_src = 2'b01;
        else if (MEM_RegWrite && (ID_rs2_addr == MEM_rd_addr))
            Forwarding_rs2_src = 2'b10;
        else 
            Forwarding_rs2_src = 2'b00;
    end
endmodule