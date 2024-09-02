`include "../../include/AXI_define.svh"
`include "./RA.sv"
`include "./RD.sv"
`include "./WA.sv"
`include "./WD.sv"
`include "./WR.sv"
`include "./DefaultSlave.sv"
`include "./Arbiter.sv"
`include "./Decoder.sv"
module AXI(

    input ACLK,
    input ARESETn,

    //SLAVE INTERFACE FOR MASTERS
    //WRITE ADDRESS
    input [`AXI_ID_BITS-1:0] AWID_M1,
    input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    input [`AXI_LEN_BITS-1:0] AWLEN_M1,
    input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    input [1:0] AWBURST_M1,
    input AWVALID_M1,
    output AWREADY_M1,
    //WRITE DATA
    input [`AXI_DATA_BITS-1:0] WDATA_M1,
    input [`AXI_STRB_BITS-1:0] WSTRB_M1,
    input WLAST_M1,
    input WVALID_M1,
    output WREADY_M1,
    //WRITE RESPONSE
    output [`AXI_ID_BITS-1:0] BID_M1,
    output [1:0] BRESP_M1,
    output BVALID_M1,
    input BREADY_M1,

    //READ ADDRESS0
    input [`AXI_ID_BITS-1:0] ARID_M0,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    input [`AXI_LEN_BITS-1:0] ARLEN_M0,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    input [1:0] ARBURST_M0,
    input ARVALID_M0,
    output ARREADY_M0,
    //READ DATA0
    output [`AXI_ID_BITS-1:0] RID_M0,
    output [`AXI_DATA_BITS-1:0] RDATA_M0,
    output [1:0] RRESP_M0,
    output RLAST_M0,
    output RVALID_M0,
    input RREADY_M0,
    //READ ADDRESS1
    input [`AXI_ID_BITS-1:0] ARID_M1,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    input [`AXI_LEN_BITS-1:0] ARLEN_M1,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    input [1:0] ARBURST_M1,
    input ARVALID_M1,
    output ARREADY_M1,
    //READ DATA1
    output [`AXI_ID_BITS-1:0] RID_M1,
    output [`AXI_DATA_BITS-1:0] RDATA_M1,
    output [1:0] RRESP_M1,
    output RLAST_M1,
    output RVALID_M1,
    input RREADY_M1,



    //MASTER INTERFACE FOR SLAVES
    //WRITE ADDRESS0
    output [`AXI_IDS_BITS-1:0] AWID_S0,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S0,
    output [`AXI_LEN_BITS-1:0] AWLEN_S0,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
    output [1:0] AWBURST_S0,
    output AWVALID_S0,
    input AWREADY_S0,
    //WRITE DATA0
    output [`AXI_DATA_BITS-1:0] WDATA_S0,
    output [`AXI_STRB_BITS-1:0] WSTRB_S0,
    output WLAST_S0,
    output WVALID_S0,
    input WREADY_S0,
    //WRITE RESPONSE0
    input [`AXI_IDS_BITS-1:0] BID_S0,
    input [1:0] BRESP_S0,
    input BVALID_S0,
    output BREADY_S0,

    //WRITE ADDRESS1
    output [`AXI_IDS_BITS-1:0] AWID_S1,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S1,
    output [`AXI_LEN_BITS-1:0] AWLEN_S1,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
    output [1:0] AWBURST_S1,
    output AWVALID_S1,
    input AWREADY_S1,
    //WRITE DATA1
    output [`AXI_DATA_BITS-1:0] WDATA_S1,
    output [`AXI_STRB_BITS-1:0] WSTRB_S1,
    output WLAST_S1,
    output WVALID_S1,
    input WREADY_S1,
    //WRITE RESPONSE1
    input [`AXI_IDS_BITS-1:0] BID_S1,
    input [1:0] BRESP_S1,
    input BVALID_S1,
    output BREADY_S1,

    //WRITE ADDRESS2
    output [`AXI_IDS_BITS-1:0] AWID_S2,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S2,
    output [`AXI_LEN_BITS-1:0] AWLEN_S2,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
    output [1:0] AWBURST_S2,
    output AWVALID_S2,
    input AWREADY_S2,
    //WRITE DATA2
    output [`AXI_DATA_BITS-1:0] WDATA_S2,
    output [`AXI_STRB_BITS-1:0] WSTRB_S2,
    output WLAST_S2,
    output WVALID_S2,
    input WREADY_S2,
    //WRITE RESPONSE2
    input [`AXI_IDS_BITS-1:0] BID_S2,
    input [1:0] BRESP_S2,
    input BVALID_S2,
    output BREADY_S2,

    //WRITE ADDRESS3
    output [`AXI_IDS_BITS-1:0] AWID_S3,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S3,
    output [`AXI_LEN_BITS-1:0] AWLEN_S3,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
    output [1:0] AWBURST_S3,
    output AWVALID_S3,
    input AWREADY_S3,
    //WRITE DATA3
    output [`AXI_DATA_BITS-1:0] WDATA_S3,
    output [`AXI_STRB_BITS-1:0] WSTRB_S3,
    output WLAST_S3,
    output WVALID_S3,
    input WREADY_S3,
    //WRITE RESPONSE3
    input [`AXI_IDS_BITS-1:0] BID_S3,
    input [1:0] BRESP_S3,
    input BVALID_S3,
    output BREADY_S3,

    //WRITE ADDRESS4
    output [`AXI_IDS_BITS-1:0] AWID_S4,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S4,
    output [`AXI_LEN_BITS-1:0] AWLEN_S4,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
    output [1:0] AWBURST_S4,
    output AWVALID_S4,
    input AWREADY_S4,
    //WRITE DATA4
    output [`AXI_DATA_BITS-1:0] WDATA_S4,
    output [`AXI_STRB_BITS-1:0] WSTRB_S4,
    output WLAST_S4,
    output WVALID_S4,
    input WREADY_S4,
    //WRITE RESPONSE4
    input [`AXI_IDS_BITS-1:0] BID_S4,
    input [1:0] BRESP_S4,
    input BVALID_S4,
    output BREADY_S4,

    //WRITE ADDRESS5
    output [`AXI_IDS_BITS-1:0] AWID_S5,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S5,
    output [`AXI_LEN_BITS-1:0] AWLEN_S5,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
    output [1:0] AWBURST_S5,
    output AWVALID_S5,
    input AWREADY_S5,
    //WRITE DATA5
    output [`AXI_DATA_BITS-1:0] WDATA_S5,
    output [`AXI_STRB_BITS-1:0] WSTRB_S5,
    output WLAST_S5,
    output WVALID_S5,
    input WREADY_S5,
    //WRITE RESPONSE5
    input [`AXI_IDS_BITS-1:0] BID_S5,
    input [1:0] BRESP_S5,
    input BVALID_S5,
    output BREADY_S5,


    //READ ADDRESS0
    output [`AXI_IDS_BITS-1:0] ARID_S0,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S0,
    output [`AXI_LEN_BITS-1:0] ARLEN_S0,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
    output [1:0] ARBURST_S0,
    output ARVALID_S0,
    input ARREADY_S0,
    //READ DATA0
    input [`AXI_IDS_BITS-1:0] RID_S0,
    input [`AXI_DATA_BITS-1:0] RDATA_S0,
    input [1:0] RRESP_S0,
    input RLAST_S0,
    input RVALID_S0,
    output RREADY_S0,

    //READ ADDRESS1
    output [`AXI_IDS_BITS-1:0] ARID_S1,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S1,
    output [`AXI_LEN_BITS-1:0] ARLEN_S1,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
    output [1:0] ARBURST_S1,
    output ARVALID_S1,
    input ARREADY_S1,
    //READ DATA1
    input [`AXI_IDS_BITS-1:0] RID_S1,
    input [`AXI_DATA_BITS-1:0] RDATA_S1,
    input [1:0] RRESP_S1,
    input RLAST_S1,
    input RVALID_S1,
    output RREADY_S1,

    //READ ADDRESS2
    output [`AXI_IDS_BITS-1:0] ARID_S2,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S2,
    output [`AXI_LEN_BITS-1:0] ARLEN_S2,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
    output [1:0] ARBURST_S2,
    output ARVALID_S2,
    input ARREADY_S2,
    //READ DATA2
    input [`AXI_IDS_BITS-1:0] RID_S2,
    input [`AXI_DATA_BITS-1:0] RDATA_S2,
    input [1:0] RRESP_S2,
    input RLAST_S2,
    input RVALID_S2,
    output RREADY_S2,

    //READ ADDRESS3
    output [`AXI_IDS_BITS-1:0] ARID_S3,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S3,
    output [`AXI_LEN_BITS-1:0] ARLEN_S3,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
    output [1:0] ARBURST_S3,
    output ARVALID_S3,
    input ARREADY_S3,
    //READ DATA3
    input [`AXI_IDS_BITS-1:0] RID_S3,
    input [`AXI_DATA_BITS-1:0] RDATA_S3,
    input [1:0] RRESP_S3,
    input RLAST_S3,
    input RVALID_S3,
    output RREADY_S3,

    //READ ADDRESS4
    output [`AXI_IDS_BITS-1:0] ARID_S4,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S4,
    output [`AXI_LEN_BITS-1:0] ARLEN_S4,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
    output [1:0] ARBURST_S4,
    output ARVALID_S4,
    input ARREADY_S4,
    //READ DATA4
    input [`AXI_IDS_BITS-1:0] RID_S4,
    input [`AXI_DATA_BITS-1:0] RDATA_S4,
    input [1:0] RRESP_S4,
    input RLAST_S4,
    input RVALID_S4,
    output RREADY_S4,

    //READ ADDRESS5
    output [`AXI_IDS_BITS-1:0] ARID_S5,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S5,
    output [`AXI_LEN_BITS-1:0] ARLEN_S5,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
    output [1:0] ARBURST_S5,
    output ARVALID_S5,
    input ARREADY_S5,
    //READ DATA5
    input [`AXI_IDS_BITS-1:0] RID_S5,
    input [`AXI_DATA_BITS-1:0] RDATA_S5,
    input [1:0] RRESP_S5,
    input RLAST_S5,
    input RVALID_S5,
    output RREADY_S5
);
// DA receive
    logic [`AXI_IDS_BITS-1:0] w_ARID_SDEFAULT;
    logic [`AXI_ADDR_BITS-1:0] w_ARADDR_SDEFAULT;
    logic [`AXI_LEN_BITS-1:0] w_ARLEN_SDEFAULT;
    logic [`AXI_SIZE_BITS-1:0] w_ARSIZE_SDEFAULT;
    logic [1:0] w_ARBURST_SDEFAULT;
    logic w_ARVALID_SDEFAULT;
// DA send
    logic w_ARREADY_SDEFAULT;
// DR send
    logic [`AXI_IDS_BITS-1:0] w_RID_SDEFAULT;
    logic [`AXI_DATA_BITS-1:0] w_RDATA_SDEFAULT;
    logic [1:0] w_RRESP_SDEFAULT;
    logic w_RLAST_SDEFAULT;
    logic w_RVALID_SDEFAULT;
// DR receive
    logic w_RREADY_SDEFAULT;
// WA receive
    logic [`AXI_IDS_BITS-1:0] w_AWID_SDEFAULT;
    logic [`AXI_ADDR_BITS-1:0] w_AWADDR_SDFAULT;
    logic [`AXI_LEN_BITS-1:0] w_AWLEN_SDEFAULT;
    logic [`AXI_SIZE_BITS-1:0] w_AWSIZE_SDEFAULT;
    logic [1:0] w_AWBURST_SDEFAULT;
    logic w_AWVALID_SDEFAULT;
// WA send
    logic w_AWREADY_SDEFAULT;
// WD receive
    logic [`AXI_DATA_BITS-1:0] w_WDATA_SDEFAULT;
    logic [`AXI_STRB_BITS-1:0] w_WSTRB_SDEFAULT;
    logic w_WLAST_SDEFAULT;
    logic w_WVALID_SDEFAULT;
// WD send
    logic w_WREADY_SDEFAULT;
// WR send
    logic [`AXI_IDS_BITS-1:0] w_BID_SDEFAULT;
    logic [1:0] w_BRESP_SDEFAULT;
    logic w_BVALID_SDEFAULT;
// WR receive
    logic w_BREADY_SDEFAULT;

    DefaultSlave DefaultSlave(
        .clk(ACLK),    // Clock
        .rst(ARESETn),  // Asynchronous reset active high

        // DA receive
        .ARID_SDEFAULT(w_ARID_SDEFAULT),
        .ARADDR_SDEFAULT(w_ARADDR_SDEFAULT),
        .ARLEN_SDEFAULT(w_ARLEN_SDEFAULT),
        .ARSIZE_SDEFAULT(w_ARSIZE_SDEFAULT),
        .ARBURST_SDEFAULT(w_ARBURST_SDEFAULT),
        .ARVALID_SDEFAULT(w_ARVALID_SDEFAULT),
        // DA send
        .ARREADY_SDEFAULT(w_ARREADY_SDEFAULT),

        // WD receive
        .WDATA_SDEFAULT(w_WDATA_SDEFAULT),
        .WSTRB_SDEFAULT(w_WSTRB_SDEFAULT),
        .WLAST_SDEFAULT(w_WLAST_SDEFAULT),
        .WVALID_SDEFAULT(w_WVALID_SDEFAULT),
        // WD send
        .WREADY_SDEFAULT(w_WREADY_SDEFAULT),

        // WR send
        .BID_SDEFAULT(w_BID_SDEFAULT),
        .BRESP_SDEFAULT(w_BRESP_SDEFAULT),
        .BVALID_SDEFAULT(w_BVALID_SDEFAULT),
        // WR receive
        .BREADY_SDEFAULT(w_BREADY_SDEFAULT),

        // WA receive
        .AWID_SDEFAULT(w_AWID_SDEFAULT),
        .AWADDR_SDEFAULT(w_AWADDR_SDFAULT),
        .AWLEN_SDEFAULT(w_AWLEN_SDEFAULT),
        .AWSIZE_SDEFAULT(w_AWSIZE_SDEFAULT),
        .AWBURST_SDEFAULT(w_AWBURST_SDEFAULT),
        .AWVALID_SDEFAULT(w_AWVALID_SDEFAULT),
        // WA send
        .AWREADY_SDEFAULT(w_AWREADY_SDEFAULT),

        // DR send
        .RID_SDEFAULT(w_RID_SDEFAULT),
        .RDATA_SDEFAULT(w_RDATA_SDEFAULT),
        .RRESP_SDEFAULT(w_RRESP_SDEFAULT),
        .RLAST_SDEFAULT(w_RLAST_SDEFAULT),
        .RVALID_SDEFAULT(w_RVALID_SDEFAULT),
        // DR receive
        .RREADY_SDEFAULT(w_RREADY_SDEFAULT)
    );

    RA RA(
        .clk(ACLK),
        .rst(ARESETn),

        // Master 0 send
        .ARID_M0(ARID_M0),
        .ARADDR_M0(ARADDR_M0),
        .ARLEN_M0(ARLEN_M0),
        .ARSIZE_M0(ARSIZE_M0),
        .ARBURST_M0(ARBURST_M0),
        .ARVALID_M0(ARVALID_M0),
        //Master0 receive slave's return
        .ARREADY_M0(ARREADY_M0),

        // Master1 send through
        .ARID_M1(ARID_M1),
        .ARADDR_M1(ARADDR_M1),
        .ARLEN_M1(ARLEN_M1),
        .ARSIZE_M1(ARSIZE_M1),
        .ARBURST_M1(ARBURST_M1),
        .ARVALID_M1(ARVALID_M1),
        //Master1 receive slave's return
        .ARREADY_M1(ARREADY_M1),

        // ROM
        .ARID_ROM(ARID_S0),
        .ARADDR_ROM(ARADDR_S0),
        .ARLEN_ROM(ARLEN_S0),
        .ARSIZE_ROM(ARSIZE_S0),
        .ARBURST_ROM(ARBURST_S0),
        .ARVALID_ROM(ARVALID_S0),
        // ROM send to master
        .ARREADY_ROM(ARREADY_S0),

        // IM
        .ARID_IM(ARID_S1),
        .ARADDR_IM(ARADDR_S1),
        .ARLEN_IM(ARLEN_S1),
        .ARSIZE_IM(ARSIZE_S1),
        .ARBURST_IM(ARBURST_S1),
        .ARVALID_IM(ARVALID_S1),
        // IM send to master
        .ARREADY_IM(ARREADY_S1),

        // DM
        .ARID_DM(ARID_S2),
        .ARADDR_DM(ARADDR_S2),
        .ARLEN_DM(ARLEN_S2),
        .ARSIZE_DM(ARSIZE_S2),
        .ARBURST_DM(ARBURST_S2),
        .ARVALID_DM(ARVALID_S2),
        // DM send to master
        .ARREADY_DM(ARREADY_S2),

        // SC
        .ARID_SC(ARID_S4),
        .ARADDR_SC(ARADDR_S4),
        .ARLEN_SC(ARLEN_S4),
        .ARSIZE_SC(ARSIZE_S4),
        .ARBURST_SC(ARBURST_S4),
        .ARVALID_SC(ARVALID_S4),
        // SC send to master
        .ARREADY_SC(ARREADY_S4),

        // WDT
        .ARID_WDT( ARID_S5),
        .ARADDR_WDT( ARADDR_S5),
        .ARLEN_WDT( ARLEN_S5),
        .ARSIZE_WDT( ARSIZE_S5),
        .ARBURST_WDT( ARBURST_S5),
        .ARVALID_WDT( ARVALID_S5),
        // WDT send to master
        .ARREADY_WDT( ARREADY_S5),

        // DRAM
        .ARID_DRAM( ARID_S3),
        .ARADDR_DRAM( ARADDR_S3),
        .ARLEN_DRAM( ARLEN_S3),
        .ARSIZE_DRAM( ARSIZE_S3),
        .ARBURST_DRAM( ARBURST_S3),
        .ARVALID_DRAM( ARVALID_S3),
        // DRAM send to master
        .ARREADY_DRAM( ARREADY_S3),

        // Default slave
        .ARID_SD(w_ARID_SDEFAULT),
        .ARADDR_SD(w_ARADDR_SDEFAULT),
        .ARLEN_SD(w_ARLEN_SDEFAULT),
        .ARSIZE_SD(w_ARSIZE_SDEFAULT),
        .ARBURST_SD(w_ARBURST_SDEFAULT),
        .ARVALID_SD(w_ARVALID_SDEFAULT),
        // Default slave
        .ARREADY_SD(w_ARREADY_SDEFAULT)
    );

    RD RD (
        .clk(ACLK),
        .rst(ARESETn),

        //Master0 to slave
        .RID_M0(RID_M0),
        .RDATA_M0(RDATA_M0),
        .RRESP_M0(RRESP_M0),
        .RLAST_M0(RLAST_M0),
        .RVALID_M0(RVALID_M0),
        //Master0 send
        .RREADY_M0(RREADY_M0),

        //Master1 receive
        .RID_M1(RID_M1),
        .RDATA_M1(RDATA_M1),
        .RRESP_M1(RRESP_M1),
        .RLAST_M1(RLAST_M1),
        .RVALID_M1(RVALID_M1),
        //Master1 send
        .RREADY_M1(RREADY_M1),

        //Slave0 send
        .RID_ROM(RID_S0),
        .RDATA_ROM(RDATA_S0),
        .RRESP_ROM(RRESP_S0),   
        .RLAST_ROM(RLAST_S0),
        .RVALID_ROM(RVALID_S0),
        //Slave0 receive
        .RREADY_ROM(RREADY_S0),

        //Slave1 send
        .RID_IM(RID_S1),
        .RDATA_IM(RDATA_S1),
        .RRESP_IM(RRESP_S1),
        .RLAST_IM(RLAST_S1),
        .RVALID_IM(RVALID_S1),
        //Slave1 receive
        .RREADY_IM(RREADY_S1),

        //Slave2 send
        .RID_DM(RID_S2),
        .RDATA_DM(RDATA_S2),
        .RRESP_DM(RRESP_S2),
        .RLAST_DM(RLAST_S2),
        .RVALID_DM(RVALID_S2),
        //Slave2 receive
        .RREADY_DM(RREADY_S2),

        //Slave3 send
        .RID_SC(RID_S4),
        .RDATA_SC(RDATA_S4),
        .RRESP_SC(RRESP_S4),
        .RLAST_SC(RLAST_S4),
        .RVALID_SC(RVALID_S4),
        //Slave3 receive
        .RREADY_SC(RREADY_S4),

        //Slave4 send
        .RID_WDT( RID_S5),
        .RDATA_WDT( RDATA_S5),
        .RRESP_WDT( RRESP_S5),
        .RLAST_WDT( RLAST_S5),
        .RVALID_WDT( RVALID_S5),
        //Slave4 receive
        .RREADY_WDT( RREADY_S5),
        //Slave5 send
        .RID_DRAM( RID_S3),
        .RDATA_DRAM( RDATA_S3),
        .RRESP_DRAM( RRESP_S3),
        .RLAST_DRAM( RLAST_S3),
        .RVALID_DRAM( RVALID_S3),
        //Slave5 receive
        .RREADY_DRAM( RREADY_S3),

        //SlaveD send
        .RID_SD(w_RID_SDEFAULT),
        .RDATA_SD(w_RDATA_SDEFAULT),
        .RRESP_SD(w_RRESP_SDEFAULT),
        .RLAST_SD(w_RLAST_SDEFAULT),
        .RVALID_SD(w_RVALID_SDEFAULT),
        //SlaveD receive
        .RREADY_SD(w_RREADY_SDEFAULT)
    );

    WA WA (
        .clk(ACLK),  
        .rst(ARESETn), 
        //master1 send
        .AWID_M1(AWID_M1),
        .AWADDR_M1(AWADDR_M1),
        .AWLEN_M1(AWLEN_M1),
        .AWSIZE_M1(AWSIZE_M1),
        .AWBURST_M1(AWBURST_M1),
        .AWVALID_M1(AWVALID_M1),
        //master1 receive the signal return
        .AWREADY_M1(AWREADY_M1),

        //slave0 receive
        .AWID_ROM(AWID_S0),
        .AWADDR_ROM(AWADDR_S0),
        .AWLEN_ROM(AWLEN_S0),
        .AWSIZE_ROM(AWSIZE_S0),
        .AWBURST_ROM(AWBURST_S0),
        .AWVALID_ROM(AWVALID_S0),
        //slave 0send
       .AWREADY_ROM(AWREADY_S0),

        //slave1 receive
        .AWID_IM(AWID_S1),
        .AWADDR_IM(AWADDR_S1),
        .AWLEN_IM(AWLEN_S1),
        .AWSIZE_IM(AWSIZE_S1),
        .AWBURST_IM(AWBURST_S1),
        .AWVALID_IM(AWVALID_S1),
        //slave1 send
        .AWREADY_IM(AWREADY_S1),

        //slave2 receive
        .AWID_DM(AWID_S2),
        .AWADDR_DM(AWADDR_S2),
        .AWLEN_DM(AWLEN_S2),
        .AWSIZE_DM(AWSIZE_S2),
        .AWBURST_DM(AWBURST_S2),
        .AWVALID_DM(AWVALID_S2),
        //slave2 send
        .AWREADY_DM(AWREADY_S2),

        //slave3 receive
        .AWID_SC(AWID_S4),
        .AWADDR_SC(AWADDR_S4),
        .AWLEN_SC(AWLEN_S4),
        .AWSIZE_SC(AWSIZE_S4),
        .AWBURST_SC(AWBURST_S4),
        .AWVALID_SC(AWVALID_S4),
        //slave3 send
        .AWREADY_SC(AWREADY_S4),

        //slave4 receive
        .AWID_WDT( AWID_S5),
        .AWADDR_WDT( AWADDR_S5),
        .AWLEN_WDT( AWLEN_S5),
        .AWSIZE_WDT( AWSIZE_S5),
        .AWBURST_WDT( AWBURST_S5),
        .AWVALID_WDT( AWVALID_S5),
        //slave4 send
        .AWREADY_WDT( AWREADY_S5),

        //slave5 receive
        .AWID_DRAM( AWID_S3),
        .AWADDR_DRAM( AWADDR_S3),
        .AWLEN_DRAM( AWLEN_S3),
        .AWSIZE_DRAM( AWSIZE_S3),
        .AWBURST_DRAM( AWBURST_S3),
        .AWVALID_DRAM( AWVALID_S3),
        //slave5 send
        .AWREADY_DRAM( AWREADY_S3),

        //slave d receive
        .AWID_SD(w_AWID_SDEFAULT),
        .AWADDR_SD(w_AWADDR_SDFAULT),
        .AWLEN_SD(w_AWLEN_SDEFAULT),
        .AWSIZE_SD(w_AWSIZE_SDEFAULT),
        .AWBURST_SD(w_AWBURST_SDEFAULT),
        .AWVALID_SD(w_AWVALID_SDEFAULT),
        //slave d send
        .AWREADY_SD(w_AWREADY_SDEFAULT)
    );

    WD WD (
        .clk(ACLK),    // Clock
        .rst(ARESETn),  // Asynchronous reset active high

        // master 1 send
        .WDATA_M1(WDATA_M1),
        .WSTRB_M1(WSTRB_M1),
        .WLAST_M1(WLAST_M1),
        .WVALID_M1(WVALID_M1),
        // master 1 receive
        .WREADY_M1(WREADY_M1),

        // slave 0 receive
        .WDATA_ROM(WDATA_S0),
        .WSTRB_ROM(WSTRB_S0),
        .WLAST_ROM(WLAST_S0),
        .WVALID_ROM(WVALID_S0),
        // slave 0 send
        .WREADY_ROM(WREADY_S0),

        // slave 1 receive
        .WDATA_IM(WDATA_S1),
        .WSTRB_IM(WSTRB_S1),
        .WLAST_IM(WLAST_S1),
        .WVALID_IM(WVALID_S1),
        // slave 1 send
        .WREADY_IM(WREADY_S1),

        // slave 2 receive
        .WDATA_DM(WDATA_S2),
        .WSTRB_DM(WSTRB_S2),
        .WLAST_DM(WLAST_S2),
        .WVALID_DM(WVALID_S2),
        // slave 2 send
        .WREADY_DM(WREADY_S2),

        // slave 3 receive
        .WDATA_SC(WDATA_S4),
        .WSTRB_SC(WSTRB_S4),
        .WLAST_SC(WLAST_S4),
        .WVALID_SC(WVALID_S4),
        // slave 3 send
        .WREADY_SC(WREADY_S4),

        // slave 4 receive
        .WDATA_WDT( WDATA_S5),
        .WSTRB_WDT( WSTRB_S5),
        .WLAST_WDT( WLAST_S5),
        .WVALID_WDT( WVALID_S5),
        // slave 4 send
        .WREADY_WDT( WREADY_S5),

        // slave 5 receive
        .WDATA_DRAM( WDATA_S3),
        .WSTRB_DRAM( WSTRB_S3),
        .WLAST_DRAM( WLAST_S3),
        .WVALID_DRAM( WVALID_S3),
        // slave 5 send
        .WREADY_DRAM( WREADY_S3),

        // slave default receive
        .WDATA_SD(w_WDATA_SDEFAULT),
        .WSTRB_SD(w_WSTRB_SDEFAULT),
        .WLAST_SD(w_WLAST_SDEFAULT),
        .WVALID_SD(w_WVALID_SDEFAULT),
        // slave 0 send
        .WREADY_SD(w_WREADY_SDEFAULT),


        .AWVALID_ROM(AWVALID_S0),
        .AWVALID_IM(AWVALID_S1),
        .AWVALID_DM(AWVALID_S2),
        .AWVALID_SC(AWVALID_S4),
        .AWVALID_WDT(AWVALID_S5),
        .AWVALID_DRAM(AWVALID_S3),
        .AWVALID_SD(w_AWVALID_SDEFAULT)
    );

    WR WR (
    .clk(ACLK),    // Clock
    .rst(ARESETn),  // Asynchronous reset active high

    // master 1 receive
    .BID_M1(BID_M1),
    .BRESP_M1(BRESP_M1),
    .BVALID_M1(BVALID_M1),
    // master 1 send
    .BREADY_M1(BREADY_M1),

    // slave 0 send
    .BID_ROM(BID_S0),
    .BRESP_ROM(BRESP_S0),
    .BVALID_ROM(BVALID_S0),
    // slave 0 receive
    .BREADY_ROM(BREADY_S0),

    // slave 1 send
    .BID_IM(BID_S1),
    .BRESP_IM(BRESP_S1),
    .BVALID_IM(BVALID_S1),
    // slave 1 receive
    .BREADY_IM(BREADY_S1),

    // slave 2 send
    .BID_DM(BID_S2),
    .BRESP_DM(BRESP_S2),
    .BVALID_DM(BVALID_S2),
    // slave 2 receive
    .BREADY_DM(BREADY_S2),

    // slave 3 send
    .BID_SC( BID_S4),
    .BRESP_SC( BRESP_S4),
    .BVALID_SC( BVALID_S4),
    // slave 3 receive
    .BREADY_SC( BREADY_S4),

    // slave 4 send
    .BID_WDT( BID_S5),
    .BRESP_WDT( BRESP_S5),
    .BVALID_WDT( BVALID_S5),
    // slave 4 receive
    .BREADY_WDT( BREADY_S5),
    
    // slave 5 send
    .BID_DRAM(BID_S3),
    .BRESP_DRAM(BRESP_S3),
    .BVALID_DRAM(BVALID_S3),
    // slave 5 receive
    .BREADY_DRAM(BREADY_S3),

    // slave default send
    .BID_SD(w_BID_SDEFAULT),
    .BRESP_SD(w_BRESP_SDEFAULT),
    .BVALID_SD(w_BVALID_SDEFAULT),
    // slave 0 receive
    .BREADY_SD(w_BREADY_SDEFAULT)
);


endmodule
