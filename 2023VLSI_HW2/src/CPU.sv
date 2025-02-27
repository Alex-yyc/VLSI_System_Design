`include "IFE.sv"
`include "ID.sv"
`include "EXE.sv"
`include "MEM.sv"
`include "WB.sv"
`include "Forwarding_Unit.sv"
`include "BranchCtrl.sv"
`include "HazardCtrl.sv"
`include "AXI_define.svh"

module CPU (
    input clk,    // Clock
    input rst,  // Asynchronous reset active high

    // IF
    output logic b_instr_read,
    output logic [`AXI_ADDR_BITS-1:0] instr_addr,
    input [`AXI_DATA_BITS-1:0] instr_out,

    // MEM
    output logic b_data_read,
    output logic b_data_write,
    output logic [3:0] write_type,
    output logic [`AXI_ADDR_BITS-1:0] data_addr,
    output logic [`AXI_DATA_BITS-1:0] data_in,
    input [`AXI_DATA_BITS-1:0] data_out,

    // stall
    input IM_stall,
    input DM_stall
);
// IM DM stall
    logic IDEXE_RegWrite;
    logic EXEMEM_RegWrite;
    logic MEMWB_RegWrite;

    wire [1:0] wire_BranchCtrl;
    wire InstrFlush;
    wire IFID_RegWrite;
    wire [31:0] IF_pc_out;
    wire [31:0] IF_instr_out;

    wire [31:0] pc_imm;
    wire [31:0] pc_immrs1;

    wire PCWrite;

    // wire [31:0] instr_out; from CPU_wrapper
    wire [31:0] pc_out;

    wire [31:0] WB_rd_data;
    wire [4:0]  WB_rd_addr;
    wire WB_RegWrite;

    wire CtrlSignalFlush;

    wire [31:0] ID_pc_out;
    wire [31:0] ID_rs1;
    wire [31:0] ID_rs2;
    wire [31:0] ID_imm;
    wire [2:0]  ID_funct3;
    wire [6:0]  ID_funct7;
    wire [4:0]  ID_rd_addr;
    wire [4:0]  ID_rs1_addr;
    wire [4:0]  ID_rs2_addr;
    wire [2:0]  ID_ALUOP;
    wire ID_PCtoRegSrc;
    wire ID_ALUSrc;
    wire ID_RDSrc;
    wire ID_MemRead;
    wire ID_MemWrite;
    wire ID_MemtoReg;
    wire ID_RegWrite;
    wire [1:0] ID_branch;

    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;

    wire [31:0] wire_MEM_rd_data;

    wire [1:0] ForwardRS1Src;
    wire [1:0] ForwardRS2Src;

    wire EXE_RDsrc;
    wire EXE_MemRead;
    wire EXE_MemWrite;
    wire EXE_MemtoReg;
    wire EXE_RegWrite;
    wire [31:0] EXE_pc_to_reg;
    wire [31:0] EXE_alu_out;
    wire [31:0] EXE_rs2_data;
    wire [4:0] EXE_rd_addr;
    wire [2:0] EXE_funct3;

    wire ZeroFlag;

    wire MEM_MemtoReg;
    wire MEM_RegWrite;
    wire [31:0] MEM_rd_data;
    wire [31:0] MEM_lw_data;
    wire [4:0] MEM_rd_addr;

    // wire [31:0] wire_lw_data;
    wire wire_chipSelect;
    wire [3:0] wire_writeEnable;
    wire [31:0] wire_dataIn;
    logic [1:0] wire_CSR_type;
// CPU wrapper
    // IF
    assign b_instr_read = 1'b1;
    assign instr_addr = pc_out;

    // MEM
    assign b_data_read = EXE_MemRead;
    assign b_data_write = EXE_MemWrite;
    assign write_type = wire_writeEnable;
    assign data_addr = EXE_alu_out;
    assign data_in = wire_dataIn;


    IFE IFE(
        .clk(clk) , 
        .rst(rst) ,
        .BranchCtrl(wire_BranchCtrl) , 
        .PC_imm(pc_imm) , 
        .PC_immrs1(pc_immrs1) ,

        .Instraction_flush(InstrFlush) ,
        .IFID_Regwrite(IFID_RegWrite) ,

        .PC_write(PCWrite) ,

        .Instraction_out(instr_out) ,

        .IF_PC_out(IF_pc_out) ,
        .IF_Instraction_out(IF_instr_out),

        .PC_out(pc_out)
    );

    ID ID(
        .clk(clk) ,
        .rst(rst) ,
        .IF_Instraction_out(IF_instr_out) ,
        .IF_PC_out(IF_pc_out) ,

        .WB_rd_data(WB_rd_data) ,
        .WB_rd_addr(WB_rd_addr) , 
        .WB_reg_write(WB_RegWrite) ,

        .CtrlSignalFlush(CtrlSignalFlush) , 

        .ID_PC_out(ID_pc_out) , 
        .ID_rs1_data(ID_rs1) , 
        .ID_rs2_data(ID_rs2) , 
        .ID_imm(ID_imm) ,
        .ID_funct3(ID_funct3) , 
        .ID_funct7(ID_funct7),
        .ID_rd_addr(ID_rd_addr),
        .ID_rs1_addr(ID_rs1_addr),
        .ID_rs2_addr(ID_rs2_addr),
        .ID_ALUOP(ID_ALUOP),
        .ID_PCtoRegSrc(ID_PCtoRegSrc),
        .ID_ALUSrc(ID_ALUSrc),
        .ID_RDSrc(ID_RDSrc),
        .ID_MemRead(ID_MemRead),
        .ID_MemWrite(ID_MemWrite),
        .ID_MemtoReg(ID_MemtoReg),
        .ID_RegWrite(ID_RegWrite),
        .ID_branch(ID_branch),

        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),

        .IDEXE_RegWrite(IDEXE_RegWrite)
    );

    EXE EXE (
        .clk(clk),    // Clock
        .rst(rst),

        .ID_PC_out(ID_pc_out),
        .ID_rs1_data(ID_rs1),
        .ID_rs2_data(ID_rs2),
        .ID_imm(ID_imm),
        .ID_funct3(ID_funct3),
        .ID_funct7(ID_funct7),
        .ID_rd_addr(ID_rd_addr),
        .ID_rs1_addr(ID_rs1_addr),
        .ID_rs2_addr(ID_rs2_addr),
        .ID_ALUOP(ID_ALUOP),
        .ID_PCtoRegSrc(ID_PCtoRegSrc),
        .ID_ALUSrc(ID_ALUSrc),
        .ID_RDSrc(ID_RDSrc),
        .ID_MemRead(ID_MemRead),
        .ID_MemWrite(ID_MemWrite),
        .ID_MemtoReg(ID_MemtoReg),
        .ID_RegWrite(ID_RegWrite),

        .wire_MEM_rd_data(wire_MEM_rd_data),
        .WB_rd_data(WB_rd_data),

        .Forwarding_rs1_src(ForwardRS1Src),
        .Forwarding_rs2_src(ForwardRS2Src),

        .CSR_branch_type(wire_CSR_type),

        .EXE_RDsrc(EXE_RDsrc),
        .EXE_MemRead(EXE_MemRead),
        .EXE_MemWrite(EXE_MemWrite),
        .EXE_MemtoReg(EXE_MemtoReg),
        .EXE_RegWrite(EXE_RegWrite),
        .EXE_PC_to_reg(EXE_pc_to_reg),
        .EXE_ALU_out(EXE_alu_out),
        .EXE_rs2_data(EXE_rs2_data),
        .EXE_rd_addr(EXE_rd_addr),
        .EXE_funct3(EXE_funct3),

        .Zeroflag(ZeroFlag),
        .PC_imm(pc_imm),
        .PC_immrs1(pc_immrs1),

        .EXEMEM_RegWrite(EXEMEM_RegWrite)
    );

    MEM MEM (
        .clk(clk),    // Clock
        .rst(rst),

        .EXE_RDsrc(EXE_RDsrc),
        .EXE_MemRead(EXE_MemRead),
        .EXE_MemWrite(EXE_MemWrite),
        .EXE_MemtoReg(EXE_MemtoReg),
        .EXE_RegWrite(EXE_RegWrite),
        .EXE_PC_to_reg(EXE_pc_to_reg),
        .EXE_ALU_out(EXE_alu_out),
        .EXE_rs2_data(EXE_rs2_data),
        .EXE_rd_addr(EXE_rd_addr),
        .EXE_funct3(EXE_funct3),

        .MEM_MemtoReg(MEM_MemtoReg),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_rd_data(MEM_rd_data), // Data from ALU
        .MEM_lw_data(MEM_lw_data), // Data from Data memory
        .MEM_rd_addr(MEM_rd_addr),
        .wire_MEM_rd_data(wire_MEM_rd_data),

        .wire_lw_data(data_out),
        .wire_chipSelect(wire_chipSelect),
        .wire_writeEnable(wire_writeEnable),
        .wire_dataIn(wire_dataIn),

        .MEMWB_RegWrite(MEMWB_RegWrite)
    );

    WB WB(
        .clk(clk),    // Clock
        .rst(rst),

        .MEM_MemtoReg(MEM_MemtoReg),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_rd_data(MEM_rd_data), // Data from ALU
        .MEM_lw_data(MEM_lw_data), // Data from Data memory
        .MEM_rd_addr(MEM_rd_addr),

        .WB_rd_data(WB_rd_data),
        .WB_rd_addr(WB_rd_addr),
        .WB_RegWrite(WB_RegWrite)
    );

    Forwarding_Unit ForwardUnit(
        .ID_rs1_addr(ID_rs1_addr),
        .ID_rs2_addr(ID_rs2_addr),
        .EXE_RegWrite(EXE_RegWrite),
        .EXE_rd_addr(EXE_rd_addr),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_rd_addr(MEM_rd_addr),

        .Forwarding_rs1_src(ForwardRS1Src),
        .Forwarding_rs2_src(ForwardRS2Src)
    );

    BranchCtrl BranchCtrl(
        .ID_branch(ID_branch),
        .Zeroflag(ZeroFlag),
        .BranchCtrl(wire_BranchCtrl)
    );

    HazardCtrl HazardCtrl(
        .BranchCtrl(wire_BranchCtrl),
        .ID_MemRead(ID_MemRead),
        .ID_rd_addr(ID_rd_addr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),

        .Instraction_flush(InstrFlush),
        .CtrlSignalFlush(CtrlSignalFlush),
        .IFID_RegWrite(IFID_RegWrite),
        .PC_Write(PCWrite),

        .CSR_branch_type(wire_CSR_type),

        .IM_stall(IM_stall),
        .IDEXE_RegWrite(IDEXE_RegWrite),
        .DM_stall(DM_stall),
        .EXEMEM_RegWrite(EXEMEM_RegWrite),
        .MEMWB_RegWrite(MEMWB_RegWrite)
    );
endmodule