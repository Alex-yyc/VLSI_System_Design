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
    output logic [`AXI_IDS_BITS-1:0] AWID_ROM,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_ROM,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_ROM,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_ROM,
    output logic [1:0] AWBURST_ROM,
    output logic AWVALID_ROM,
    //slave 0send
    input AWREADY_ROM,

    //slave1 receive
    output logic [`AXI_IDS_BITS-1:0] AWID_IM,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_IM,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_IM,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_IM,
    output logic [1:0] AWBURST_IM,
    output logic AWVALID_IM,
    //slave1 send
    input AWREADY_IM,

    //slave2 receive
    output logic [`AXI_IDS_BITS-1:0] AWID_DM,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_DM,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_DM,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_DM,
    output logic [1:0] AWBURST_DM,
    output logic AWVALID_DM,
    //slave2 send
    input AWREADY_DM,

    //slave3 receive
    output logic [`AXI_IDS_BITS-1:0] AWID_SC,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_SC,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_SC,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_SC,
    output logic [1:0] AWBURST_SC,
    output logic AWVALID_SC,
    //slave3 send
    input AWREADY_SC,

    //slave4 receive
    output logic [`AXI_IDS_BITS-1:0] AWID_WDT,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_WDT,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_WDT,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_WDT,
    output logic [1:0] AWBURST_WDT,
    output logic AWVALID_WDT,
    //slave4 send
    input AWREADY_WDT,

    //slave5 receive
    output logic [`AXI_IDS_BITS-1:0] AWID_DRAM,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_DRAM,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_DRAM,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_DRAM,
    output logic [1:0] AWBURST_DRAM,
    output logic AWVALID_DRAM,
    //slave5 send
    input AWREADY_DRAM,

    //slave d receive
    output logic [`AXI_IDS_BITS-1:0] AWID_SD,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_SD,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_SD,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_SD,
    output logic [1:0] AWBURST_SD,
    output logic AWVALID_SD,
    //slave d send
    input AWREADY_SD
);
//logic
    logic [`AXI_IDS_BITS-1:0] IDS_M;
    logic [`AXI_ADDR_BITS-1:0] ADDR_M;
    logic [`AXI_LEN_BITS-1:0] LEN_M;
    logic [`AXI_SIZE_BITS-1:0] SIZE_M;
    logic [1:0] BURST_M;
    logic VALID_M;
    logic READY_S;
    logic ARREADY_M0;

//ROM
    assign AWID_ROM      = IDS_M;
    assign AWADDR_ROM    = ADDR_M;
    assign AWLEN_ROM     = LEN_M;
    assign AWSIZE_ROM    = SIZE_M;
    assign AWBURST_ROM   = BURST_M;
//IM
    assign AWID_IM      = IDS_M;
    assign AWADDR_IM    = ADDR_M;
    assign AWLEN_IM     = LEN_M;
    assign AWSIZE_IM    = SIZE_M;
    assign AWBURST_IM   = BURST_M;
//DM
    assign AWID_DM      = IDS_M;
    assign AWADDR_DM    = ADDR_M;
    assign AWLEN_DM     = LEN_M;
    assign AWSIZE_DM    = SIZE_M;
    assign AWBURST_DM   = BURST_M;
//SC
    assign AWID_SC      = IDS_M;
    assign AWADDR_SC    = ADDR_M;
    assign AWLEN_SC     = LEN_M;
    assign AWSIZE_SC    = SIZE_M;
    assign AWBURST_SC   = BURST_M;
//WDT
    assign AWID_WDT      = IDS_M;
    assign AWADDR_WDT    = ADDR_M;
    assign AWLEN_WDT     = LEN_M;
    assign AWSIZE_WDT    = SIZE_M;
    assign AWBURST_WDT   = BURST_M;
//DRAM
    assign AWID_DRAM      = IDS_M;
    assign AWADDR_DRAM    = ADDR_M;
    assign AWLEN_DRAM     = LEN_M;
    assign AWSIZE_DRAM    = SIZE_M;
    assign AWBURST_DRAM   = BURST_M;
//SD
    assign AWID_SD      = IDS_M;
    assign AWADDR_SD    = ADDR_M;
    assign AWLEN_SD     = LEN_M;
    assign AWSIZE_SD    = SIZE_M;
    assign AWBURST_SD   = BURST_M;


     Arbiter Arbiter (
        .clk(clk) ,
        .rst(rst) ,

        //M0
        .ID_M0(`AXI_ID_BITS'b0),
        .ADDR_M0(`AXI_ADDR_BITS'b0),
        .LEN_M0(`AXI_LEN_BITS'b0),
        .SIZE_M0(`AXI_SIZE_BITS'b0),
        .BURST_M0(2'b0),
        .VALID_M0(1'b0),

        .READY_M0(ARREADY_M0),

        //M1
        .ID_M1(AWID_M1),
        .ADDR_M1(AWADDR_M1),
        .LEN_M1(AWLEN_M1),
        .SIZE_M1(AWSIZE_M1),
        .BURST_M1(AWBURST_M1),
        .VALID_M1(AWVALID_M1),

        .READY_M1(AWREADY_M1),

        //Slaves
        .IDS_M(IDS_M),
        .ADDR_M(ADDR_M),
        .LEN_M(LEN_M),
        .SIZE_M(SIZE_M),
        .BURST_M(BURST_M),
        .VALID_M(VALID_M),
        
        .READY_M(READY_S)
    );

    Decoder Decoder (
        .VALID(VALID_M),
        .ADDR(ADDR_M),
        
        // VALID
        .VALID_ROM(AWVALID_ROM),
        .VALID_IM(AWVALID_IM),
        .VALID_DM(AWVALID_DM),
        .VALID_SC(AWVALID_SC),
        .VALID_WDT(AWVALID_WDT),
        .VALID_DRAM(AWVALID_DRAM),
        .VALID_SD(AWVALID_SD),
        
        // READY
        .READY_ROM(AWREADY_ROM),
        .READY_IM(AWREADY_IM),
        .READY_DM(AWREADY_DM),
        .READY_SC(AWREADY_SC),
        .READY_WDT(AWREADY_WDT),
        .READY_DRAM(AWREADY_DRAM),
        .READY_SD(AWREADY_SD),
        .READY_S(READY_S)
    );







endmodule