`include "ALUCtrl.sv"
`include "ALU.sv"
module EXE (
    input clk,  
    input rst,

    // ID/EX_Reg
    input [31:0] ID_PC_out,
    input [31:0] ID_rs1_data,
    input [31:0] ID_rs2_data,
    input [31:0] ID_imm,
    input [2:0] ID_funct3,
    input [6:0] ID_funct7,
    input [4:0] ID_rd_addr,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input [2:0] ID_ALUOP,
    input ID_PCtoRegSrc,
    input ID_ALUSrc,
    input ID_RDSrc,
    input ID_MemRead,
    input ID_MemWrite,
    input ID_MemtoReg,
    input ID_RegWrite,

    input [31:0] wire_MEM_rd_data,
    input [31:0] WB_rd_data,

    input [1:0] Forwarding_rs1_src,
    input [1:0] Forwarding_rs2_src,

    input [1:0] CSR_branch_type,

    output reg EXE_RDsrc,
    output reg EXE_MemRead,
    output reg EXE_MemWrite,
    output reg EXE_MemtoReg,
    output reg EXE_RegWrite,
    output reg [31:0] EXE_PC_to_reg,
    output reg [31:0] EXE_ALU_out,
    output reg [31:0] EXE_rs2_data,
    output reg [4:0] EXE_rd_addr,
    output reg [2:0] EXE_funct3,
    
    output Zeroflag,

    output [31:0] PC_imm,
    output [31:0] PC_immrs1

);
    wire [31:0] wire_PC_imm ;
    wire [31:0] wire_PC_4 ;
    wire [31:0] wire_ALU_out ;

    assign wire_PC_imm = ID_PC_out + ID_imm ;
    assign wire_PC_4 = ID_PC_out + 4 ;

    assign PC_imm = ID_PC_out + ID_imm ;
    assign PC_immrs1 = wire_ALU_out ;

    reg [31:0] ALU_rs1;
    reg [31:0] ALU_rs2_1;
    reg [31:0] ALU_rs2_2;

    reg [63:0] cycle;
    reg [63:0] instr_counter;
    localparam [1:0]    BR_type = 2'b00,
                        LU_type = 2'b01,
                        NORMAL_type = 2'b10;

    always_comb begin //here
        case (Forwarding_rs1_src)
            2'b00 : ALU_rs1 = ID_rs1_data;
            2'b01 : ALU_rs1 = wire_MEM_rd_data;
            default: ALU_rs1 = WB_rd_data;
        endcase
    end
    
    always_comb begin //here
        case (Forwarding_rs2_src)
            2'b00 : ALU_rs2_1 = ID_rs2_data;
            2'b01 : ALU_rs2_1 = wire_MEM_rd_data;
            default:ALU_rs2_1 = WB_rd_data; //2'b10
        endcase
    end

    always_comb begin 
        if (ID_ALUSrc) 
            ALU_rs2_2 = ALU_rs2_1 ;
        else 
            ALU_rs2_2 = ID_imm ;
    end

    wire [4:0] wire_ALUCtrl;

    ALUCtrl ALUCtrl(
        .ALUOP(ID_ALUOP) , 
        .funct3(ID_funct3) , 
        .funct7(ID_funct7) ,
        .CSRimm({ID_funct7,ID_rs2_addr}) ,
        .ALUCtrl(wire_ALUCtrl)
    );

    ALU ALU(
        .rs1(ALU_rs1) , 
        .rs2(ALU_rs2_2) ,
        .ALUCtrl(wire_ALUCtrl) ,
        
        .cycle(cycle),
        .instr(instr_counter),

        .ALU_out(wire_ALU_out) , 
        .Zeroflag(Zeroflag) 
    );

    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            EXE_RDsrc    <= 1'b0;
            EXE_MemRead  <= 1'b0;
            EXE_MemWrite <= 1'b0;
            EXE_MemtoReg <= 1'b0;
            EXE_RegWrite <= 1'b0;

            EXE_PC_to_reg<= 32'b0;
            EXE_ALU_out  <= 32'b0;
            EXE_rs2_data <= 32'b0;

            EXE_rd_addr  <= 5'b0;
            EXE_funct3   <= 3'b0;

            cycle <= 64'b0;
            instr_counter <= 64'b0;
        end
        else begin
            EXE_RDsrc    <= ID_RDSrc;
            EXE_MemRead  <= ID_MemRead;
            EXE_MemWrite <= ID_MemWrite;
            EXE_MemtoReg <= ID_MemtoReg;
            EXE_RegWrite <= ID_RegWrite;

            if(ID_PCtoRegSrc)
                EXE_PC_to_reg<= wire_PC_imm;
            else    
                EXE_PC_to_reg<= wire_PC_4;

            EXE_ALU_out  <= wire_ALU_out;
            EXE_rs2_data <= ALU_rs2_1;

            EXE_rd_addr  <= ID_rd_addr;
            EXE_funct3   <= ID_funct3;

            cycle <= cycle + 64'd1;

            if (cycle>64'b1) begin
                case (CSR_branch_type)
                    BR_type : instr_counter <= instr_counter - 64'b1 ;
                    LU_type : instr_counter <= instr_counter ; 
                    default : instr_counter <= instr_counter + 64'b1 ; 
                endcase
            end

        end
    end
endmodule
