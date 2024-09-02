`include "../../include/AXI_define.svh"

module RA (
    input clk,
    input rst,

    // Master 0 send
    input [`AXI_ID_BITS-1:0] ARID_M0,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    input [`AXI_LEN_BITS-1:0] ARLEN_M0,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    input [1:0] ARBURST_M0,
    input ARVALID_M0,
    //Master0 receive slave's return
    output logic ARREADY_M0,

    // Master1 send through
    input [`AXI_ID_BITS-1:0] ARID_M1,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    input [`AXI_LEN_BITS-1:0] ARLEN_M1,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    input [1:0] ARBURST_M1,
    input ARVALID_M1,
    //Master1 receive slave's return
    output logic ARREADY_M1,

    // ROM
    output logic [`AXI_IDS_BITS-1:0] ARID_ROM,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_ROM,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_ROM,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_ROM,
    output logic [1:0] ARBURST_ROM,
    output logic ARVALID_ROM,
    // ROM send to master
    input ARREADY_ROM,

    // IM
    output logic [`AXI_IDS_BITS-1:0] ARID_IM,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_IM,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_IM,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_IM,
    output logic [1:0] ARBURST_IM,
    output logic ARVALID_IM,
    // IM send to master
    input ARREADY_IM,

    // DM
    output logic [`AXI_IDS_BITS-1:0] ARID_DM,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_DM,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_DM,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_DM,
    output logic [1:0] ARBURST_DM,
    output logic ARVALID_DM,
    // DM send to master
    input ARREADY_DM,

    // SC
    output logic [`AXI_IDS_BITS-1:0] ARID_SC,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_SC,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_SC,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_SC,
    output logic [1:0] ARBURST_SC,
    output logic ARVALID_SC,
    // SC send to master
    input ARREADY_SC,

    // WDT
    output logic [`AXI_IDS_BITS-1:0] ARID_WDT,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_WDT,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_WDT,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_WDT,
    output logic [1:0] ARBURST_WDT,
    output logic ARVALID_WDT,
    // WDT send to master
    input ARREADY_WDT,

    // DRAM
    output logic [`AXI_IDS_BITS-1:0] ARID_DRAM,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_DRAM,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_DRAM,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_DRAM,
    output logic [1:0] ARBURST_DRAM,
    output logic ARVALID_DRAM,
    // DRAM send to master
    input ARREADY_DRAM,

    // Default slave
    output logic [`AXI_IDS_BITS-1:0] ARID_SD,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_SD,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_SD,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_SD,
    output logic [1:0] ARBURST_SD,
    output logic ARVALID_SD,
    // Default slave
    input ARREADY_SD
);
//summary which master you choose
    logic [`AXI_IDS_BITS-1:0] IDS_M;  
    logic [`AXI_ADDR_BITS-1:0] ADDR_M;
    logic [`AXI_LEN_BITS-1:0] LEN_M;
    logic [`AXI_SIZE_BITS-1:0] SIZE_M;
    logic [1:0] BURST_M;
    logic VALID_M;

    logic READY_S;
    logic tmp_ARVALID_SDEFAULT;

// ROM 
    assign ARID_ROM    = IDS_M;
    assign ARADDR_ROM  = ADDR_M;
    assign ARLEN_ROM   = LEN_M;
    assign ARSIZE_ROM  = SIZE_M;
    assign ARBURST_ROM = BURST_M;
// IM
    assign ARID_IM    = IDS_M;
    assign ARADDR_IM  = ADDR_M;
    assign ARLEN_IM   = LEN_M;
    assign ARSIZE_IM  = SIZE_M;
    assign ARBURST_IM = BURST_M;
// DM
    assign ARID_DM    = IDS_M;
    assign ARADDR_DM  = ADDR_M;
    assign ARLEN_DM   = LEN_M;
    assign ARSIZE_DM  = SIZE_M;
    assign ARBURST_DM = BURST_M;
// SenserCtrl
    assign ARID_SC    = IDS_M;
    assign ARADDR_SC  = ADDR_M;
    assign ARLEN_SC   = LEN_M;
    assign ARSIZE_SC  = SIZE_M;
    assign ARBURST_SC = BURST_M;
// WDT
    assign ARID_WDT    = IDS_M;
    assign ARADDR_WDT  = ADDR_M;
    assign ARLEN_WDT   = LEN_M;
    assign ARSIZE_WDT  = SIZE_M;
    assign ARBURST_WDT = BURST_M;
// DRAM
    assign ARID_DRAM    = IDS_M;
    assign ARADDR_DRAM  = ADDR_M;
    assign ARLEN_DRAM   = LEN_M;
    assign ARSIZE_DRAM  = SIZE_M;
    assign ARBURST_DRAM = BURST_M;
// Default
    assign ARID_SD    = IDS_M;
    assign ARADDR_SD  = ADDR_M;
    assign ARLEN_SD   = LEN_M;
    assign ARSIZE_SD  = SIZE_M;
    assign ARBURST_SD = BURST_M;

    Arbiter Arbiter (
        .clk(clk) ,
        .rst(rst) ,

        //M0
        .ID_M0(ARID_M0),
        .ADDR_M0(ARADDR_M0),
        .LEN_M0(ARLEN_M0),
        .SIZE_M0(ARSIZE_M0),
        .BURST_M0(ARBURST_M0),
        .VALID_M0(ARVALID_M0),

        .READY_M0(ARREADY_M0),

        //M1
        .ID_M1(ARID_M1),
        .ADDR_M1(ARADDR_M1),
        .LEN_M1(ARLEN_M1),
        .SIZE_M1(ARSIZE_M1),
        .BURST_M1(ARBURST_M1),
        .VALID_M1(ARVALID_M1),

        .READY_M1(ARREADY_M1),

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
        .VALID_ROM(ARVALID_ROM),
        .VALID_IM(ARVALID_IM),
        .VALID_DM(ARVALID_DM),
        .VALID_SC(ARVALID_SC),
        .VALID_WDT(ARVALID_WDT),
        .VALID_DRAM(ARVALID_DRAM),
        .VALID_SD(tmp_ARVALID_SDEFAULT),
        
        // READY
        .READY_ROM(ARREADY_ROM),
        .READY_IM(ARREADY_IM),
        .READY_DM(ARREADY_DM),
        .READY_SC(ARREADY_SC),
        .READY_WDT(ARREADY_WDT),
        .READY_DRAM(ARREADY_DRAM),
        .READY_SD(ARREADY_SD),
        
        .READY_S(READY_S)
    );

endmodule