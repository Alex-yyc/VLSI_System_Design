`include "../../include/AXI_define.svh"
module WA (
    input clk,  
    input rst, 
    //master1 send
    input [`AXI_ID_BITS-1:0] AWID_M1,
    input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    input [`AXI_LEN_BITS-1:0] AWLEN_M1,
    input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    input [1:0] AWBURST_M1,
    input AWVALID_M1,
    //master1 receive the signal return
    output logic AWREADY_M1,

    //slave0 receive
    output logic [`AXI_IDS_BITS-1:0] AWID_S0,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
    output logic [1:0] AWBURST_S0,
    output logic AWVALID_S0,
    //slave 0send
    input AWREADY_S0,

    //slave1 receive
    output logic [`AXI_IDS_BITS-1:0] AWID_S1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
    output logic [1:0] AWBURST_S1,
    output logic AWVALID_S1,
    //slave1 send
    input AWREADY_S1,

    //slave d receive
    output logic [`AXI_IDS_BITS-1:0] AWID_SDEFAULT,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_SDEFAULT,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_SDEFAULT,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_SDEFAULT,
    output logic [1:0] AWBURST_SDEFAULT,
    output logic AWVALID_SDEFAULT,
    //slave d send
    input AWREADY_SDEFAULT
);

logic [`AXI_IDS_BITS-1:0] IDS_M;
logic [`AXI_ADDR_BITS-1:0] ADDR_M;
logic [`AXI_LEN_BITS-1:0] LEN_M;
logic [`AXI_SIZE_BITS-1:0] SIZE_M;
logic [1:0] BURST_M;
logic VALID_M;

// slave0 Instruction Memory
assign AWID_S0      = IDS_M;
assign AWADDR_S0    = ADDR_M;
assign AWLEN_S0     = LEN_M;
assign AWSIZE_S0    = SIZE_M;
assign AWBURST_S0   = BURST_M;

// slave1 Data Memory
assign AWID_S1      = IDS_M;
assign AWADDR_S1    = ADDR_M;
assign AWLEN_S1     = LEN_M;
assign AWSIZE_S1    = SIZE_M;
assign AWBURST_S1   = BURST_M;

// slave Default
assign AWID_SDEFAULT    = IDS_M;
assign AWADDR_SDEFAULT  = ADDR_M;
assign AWLEN_SDEFAULT   = LEN_M;
assign AWSIZE_SDEFAULT  = SIZE_M;
assign AWBURST_SDEFAULT = BURST_M;   

logic READY_S;
logic ARREADY_M0;

Arbiter arbiter(
    .clk(clk),
    .rst(rst),

    // from M0
    .ID_M0(`AXI_ID_BITS'b0),
    .ADDR_M0(`AXI_ADDR_BITS'b0),
    .LEN_M0(`AXI_LEN_BITS'b0),
    .SIZE_M0(`AXI_SIZE_BITS'b0),
    .BURST_M0(2'b0),
    .VALID_M0(1'b0),
    .READY_M0(ARREADY_M0), // Because READY_M0 doesn't exist

    // from M1
    .ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),
    .READY_M1(AWREADY_M1),

    // to slaves
    .READY_M(READY_S),

    .IDS_M(IDS_M),
    .ADDR_M(ADDR_M),
    .LEN_M(LEN_M),
    .SIZE_M(SIZE_M),
    .BURST_M(BURST_M),
    .VALID_M(VALID_M)
    
);

Decoder decoder(
    .VALID(VALID_M),
    .ADDR(ADDR_M),

    .VALID_S0(AWVALID_S0),
    .VALID_S1(AWVALID_S1),
    .VALID_SDEFAULT(AWVALID_SDEFAULT), // not define

    .READY_S0(AWREADY_S0),
    .READY_S1(AWREADY_S1),
    .READY_SDEFAULT(AWREADY_SDEFAULT), // not define

    .READY_S(READY_S)
);

endmodule