`include "../../include/AXI_define.svh"
`include "RA.sv"
`include "RD.sv"
`include "WA.sv"
`include "WD.sv"
`include "WR.sv"
`include "DefaultSlave.sv"
`include "Arbiter.sv"
`include "Decoder.sv"

module AXI
(
    input logic ACLK,
    input logic ARESETn,

    // AXI to master 0 (IF-stage)
    // ARx
    input logic [`AXI_ID_BITS-1:0] ARID_M0,
    input logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    input logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
    input logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    input logic [1:0] ARBURST_M0,
    input logic ARVALID_M0,
    output logic ARREADY_M0,
    // Rx
    output logic [`AXI_ID_BITS-1:0] RID_M0,
    output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
    output logic [1:0] RRESP_M0,
    output logic RLAST_M0,
    output logic RVALID_M0,
    input logic RREADY_M0,

    // AXI to master 1 (MEM-stage)
    // AWx
    input logic [`AXI_ID_BITS-1:0] AWID_M1,
    input logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    input logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
    input logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    input logic [1:0] AWBURST_M1,
    input logic AWVALID_M1,
    output logic AWREADY_M1,
    // Wx
    input logic [`AXI_DATA_BITS-1:0] WDATA_M1,
    input logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
    input logic WLAST_M1,
    input logic WVALID_M1,
    output logic WREADY_M1,
    // Bx
    output logic [`AXI_ID_BITS-1:0] BID_M1,
    output logic [1:0] BRESP_M1,
    output logic BVALID_M1,
    input logic BREADY_M1,
    // ARx
    input logic [`AXI_ID_BITS-1:0] ARID_M1,
    input logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    input logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
    input logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    input logic [1:0] ARBURST_M1,
    input logic ARVALID_M1,
    output logic ARREADY_M1,
    // Rx
    output logic [`AXI_ID_BITS-1:0] RID_M1,
    output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
    output logic [1:0] RRESP_M1,
    output logic RLAST_M1,
    output logic RVALID_M1,
    input logic RREADY_M1,

    // AXI to slave 0 (IM)
    // AWx
    output logic [`AXI_IDS_BITS-1:0] AWID_S0,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
    output logic [1:0] AWBURST_S0,
    output logic AWVALID_S0,
    input logic AWREADY_S0,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
    output logic WLAST_S0,
    output logic WVALID_S0,
    input logic WREADY_S0,
    // Bx
    input logic [`AXI_IDS_BITS-1:0] BID_S0,
    input logic [1:0] BRESP_S0,
    input logic BVALID_S0,
    output logic BREADY_S0,
    // ARx
    output logic [`AXI_IDS_BITS-1:0] ARID_S0,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
    output logic [1:0] ARBURST_S0,
    output logic ARVALID_S0,
    input logic ARREADY_S0,
    // Rx
    input logic [`AXI_IDS_BITS-1:0] RID_S0,
    input logic [`AXI_DATA_BITS-1:0] RDATA_S0,
    input logic [1:0] RRESP_S0,
    input logic RLAST_S0,
    input logic RVALID_S0,
    output logic RREADY_S0,

    // AXI to slave 1 (DM)
    // AWx
    output logic [`AXI_IDS_BITS-1:0] AWID_S1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
    output logic [1:0] AWBURST_S1,
    output logic AWVALID_S1,
    input logic AWREADY_S1,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
    output logic WLAST_S1,
    output logic WVALID_S1,
    input logic WREADY_S1,
    // WBx
    input logic [`AXI_IDS_BITS-1:0] BID_S1,
    input logic [1:0] BRESP_S1,
    input logic BVALID_S1,
    output logic BREADY_S1,
    // ARx
    output logic [`AXI_IDS_BITS-1:0] ARID_S1,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
    output logic [1:0] ARBURST_S1,
    output logic ARVALID_S1,
    input logic ARREADY_S1,
    // Rx
    input logic [`AXI_IDS_BITS-1:0] RID_S1,
    input logic [`AXI_DATA_BITS-1:0] RDATA_S1,
    input logic [1:0] RRESP_S1,
    input logic RLAST_S1,
    input logic RVALID_S1,
    output logic RREADY_S1
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
logic [`AXI_ADDR_BITS-1:0] w_AWADDR_SDEFAULT;
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

DefaultSlave udefaultslave(
    .clk(ACLK),
    .rst(ARESETn),

    //address send to DefaultSlave
    .ARID_SDEFAULT(w_ARID_SDEFAULT),
    .ARADDR_SDEFAULT(w_ARADDR_SDEFAULT),
    .ARLEN_SDEFAULT(w_ARLEN_SDEFAULT),
    .ARSIZE_SDEFAULT(w_ARSIZE_SDEFAULT),
    .ARBURST_SDEFAULT(w_ARBURST_SDEFAULT),
    .ARVALID_SDEFAULT(w_ARVALID_SDEFAULT),
    //ARREADY write back from DefaultSlave
    .ARREADY_SDEFAULT(w_ARREADY_SDEFAULT),

    //data/strb .etc to DefaultSlave
    .WDATA_SDEFAULT(w_WDATA_SDEFAULT),
    .WSTRB_SDEFAULT(w_WSTRB_SDEFAULT),
    .WLAST_SDEFAULT(w_WLAST_SDEFAULT),
    .WVALID_SDEFAULT(w_WVALID_SDEFAULT),
    //WREADY write back from DefaultSlave
    .WREADY_SDEFAULT(w_WREADY_SDEFAULT),

    //response signal write back from DefaultSlave
    .BID_SDEFAULT(w_BID_SDEFAULT),
    .BRESP_SDEFAULT(w_BRESP_SDEFAULT),
    .BVALID_SDEFAULT(w_BVALID_SDEFAULT),
    //
    .BREADY_SDEFAULT(w_BREADY_SDEFAULT),

    //address write needs some signal
    .AWID_SDEFAULT(w_AWID_SDEFAULT),
    .AWADDR_SDEFAULT(w_AWADDR_SDEFAULT),
    .AWLEN_SDEFAULT(w_AWLEN_SDEFAULT),
    .AWSIZE_SDEFAULT(w_AWSIZE_SDEFAULT),
    .AWBURST_SDEFAULT(w_AWBURST_SDEFAULT),
    .AWVALID_SDEFAULT(w_AWVALID_SDEFAULT),
    //AWREADY write back from DefaultSlave
    .AWREADY_SDEFAULT(w_AWREADY_SDEFAULT),

    .RID_SDEFAULT(w_RID_SDEFAULT),
    .RDATA_SDEFAULT(w_RDATA_SDEFAULT),
    .RRESP_SDEFAULT(w_RRESP_SDEFAULT),
    .RLAST_SDEFAULT(w_RLAST_SDEFAULT),
    .RVALID_SDEFAULT(w_RVALID_SDEFAULT),

    .RREADY_SDEFAULT(w_RREADY_SDEFAULT)
);

RA ura(
    .clk(ACLK),
    .rst(ARESETn),

    //master0 send to slave
    .ARID_M0(ARID_M0),
    .ARADDR_M0(ARADDR_M0),
    .ARLEN_M0(ARLEN_M0),
    .ARSIZE_M0(ARSIZE_M0),
    .ARBURST_M0(ARBURST_M0),
    .ARVALID_M0(ARVALID_M0),
    //ARREADY.. master0 need slave's return
    .ARREADY_M0(ARREADY_M0),

    //master1 send to slave
    .ARID_M1(ARID_M1),
    .ARADDR_M1(ARADDR_M1),
    .ARLEN_M1(ARLEN_M1),
    .ARSIZE_M1(ARSIZE_M1),
    .ARBURST_M1(ARBURST_M1),
    .ARVALID_M1(ARVALID_M1),
    //ARREADY.. master1 need slave's return
    .ARREADY_M1(ARREADY_M1),

    //slave0 through RA pipe that receive signal
    .ARID_S0(ARID_S0),
    .ARADDR_S0(ARADDR_S0),
    .ARLEN_S0(ARLEN_S0),
    .ARSIZE_S0(ARSIZE_S0),
    .ARBURST_S0(ARBURST_S0),
    .ARVALID_S0(ARVALID_S0),
    //slave0 through RA pipr that send signal to master
    .ARREADY_S0(ARREADY_S0),

    //slave1 through RA pipe that receive signal
    .ARID_S1(ARID_S1),
    .ARADDR_S1(ARADDR_S1),
    .ARLEN_S1(ARLEN_S1),
    .ARSIZE_S1(ARSIZE_S1),
    .ARBURST_S1(ARBURST_S1),
    .ARVALID_S1(ARVALID_S1),
    //slave1 through RA pipr that send signal to master
    .ARREADY_S1(ARREADY_S1),

    //slaveD through RA pipe that receive signal
    .ARID_SDEFAULT(w_ARID_SDEFAULT),
    .ARADDR_SDEFAULT(w_ARADDR_SDEFAULT),
    .ARLEN_SDEFAULT(w_ARLEN_SDEFAULT),
    .ARSIZE_SDEFAULT(w_ARSIZE_SDEFAULT),
    .ARBURST_SDEFAULT(w_ARBURST_SDEFAULT),
    .ARVALID_SDEFAULT(w_ARVALID_SDEFAULT),
    //slaveD through RA pipr that send signal to master
    .ARREADY_SDEFAULT(w_ARREADY_SDEFAULT)
);

RD urd(
    .clk(ACLK),
    .rst(ARESETn),

    //master0 receive
    .RID_M0(RID_M0),
    .RDATA_M0(RDATA_M0),
    .RRESP_M0(RRESP_M0),
    .RLAST_M0(RLAST_M0),
    .RVALID_M0(RVALID_M0),
    //master0 send
    .RREADY_M0(RREADY_M0),

    //master1 receive
    .RID_M1(RID_M1),
    .RDATA_M1(RDATA_M1),
    .RRESP_M1(RRESP_M1),
    .RLAST_M1(RLAST_M1),
    .RVALID_M1(RVALID_M1),
    //master1 send
    .RREADY_M1(RREADY_M1),

    //slave0 send
    .RID_S0(RID_S0),
    .RDATA_S0(RDATA_S0),
    .RRESP_S0(RRESP_S0),
    .RLAST_S0(RLAST_S0),
    .RVALID_S0(RVALID_S0),
    //slave0 receive
    .RREADY_S0(RREADY_S0),

    //slave1 send
    .RID_S1(RID_S1),
    .RDATA_S1(RDATA_S1),
    .RRESP_S1(RRESP_S1),
    .RLAST_S1(RLAST_S1),
    .RVALID_S1(RVALID_S1),
    //slave1 receive
    .RREADY_S1(RREADY_S1),

    //slave0 send
    .RID_SDEFAULT(w_RID_SDEFAULT),
    .RDATA_SDEFAULT(w_RDATA_SDEFAULT),
    .RRESP_SDEFAULT(w_RRESP_SDEFAULT),
    .RLAST_SDEFAULT(w_RLAST_SDEFAULT),
    .RVALID_SDEFAULT(w_RVALID_SDEFAULT),
    //slave0 receive
    .RREADY_SDEFAULT(w_RREADY_SDEFAULT)
);

WA uwa(
    .clk(ACLK),
    .rst(ARESETn),

    //master1 sned
    .AWID_M1(AWID_M1),
    .AWADDR_M1(AWADDR_M1),
    .AWLEN_M1(AWLEN_M1),
    .AWSIZE_M1(AWSIZE_M1),
    .AWBURST_M1(AWBURST_M1),
    .AWVALID_M1(AWVALID_M1),
    //master receive
    .AWREADY_M1(AWREADY_M1),

    //slave0 receive
    .AWID_S0(AWID_S0),
    .AWADDR_S0(AWADDR_S0),
    .AWLEN_S0(AWLEN_S0),
    .AWSIZE_S0(AWSIZE_S0),
    .AWBURST_S0(AWBURST_S0),
    .AWVALID_S0(AWVALID_S0),
    //slave0 send
    .AWREADY_S0(AWREADY_S0),

    //slave0 receive
    .AWID_S1(AWID_S1),
    .AWADDR_S1(AWADDR_S1),
    .AWLEN_S1(AWLEN_S1),
    .AWSIZE_S1(AWSIZE_S1),
    .AWBURST_S1(AWBURST_S1),
    .AWVALID_S1(AWVALID_S1),
    //slave0 send
    .AWREADY_S1(AWREADY_S1),

    //slaveD receive
    .AWID_SDEFAULT(w_AWID_SDEFAULT),
    .AWADDR_SDEFAULT(w_AWADDR_SDEFAULT),
    .AWLEN_SDEFAULT(w_AWLEN_SDEFAULT),
    .AWSIZE_SDEFAULT(w_AWSIZE_SDEFAULT),
    .AWBURST_SDEFAULT(w_AWBURST_SDEFAULT),
    .AWVALID_SDEFAULT(w_AWVALID_SDEFAULT),
    //slaveD send
    .AWREADY_SDEFAULT(w_AWREADY_SDEFAULT)
);

WD uwd(
    .clk(ACLK),
    .rst(ARESETn),

    //master1 send
    .WDATA_M1(WDATA_M1),
    .WSTRB_M1(WSTRB_M1),
    .WLAST_M1(WLAST_M1),
    .WVALID_M1(WVALID_M1),
    //master1 receive
    .WREADY_M1(WREADY_M1),

    //master1 send
    .WDATA_S0(WDATA_S0),
    .WSTRB_S0(WSTRB_S0),
    .WLAST_S0(WLAST_S0),
    .WVALID_S0(WVALID_S0),
    //master1 receive
    .WREADY_S0(WREADY_S0),

    //master1 send
    .WDATA_S1(WDATA_S1),
    .WSTRB_S1(WSTRB_S1),
    .WLAST_S1(WLAST_S1),
    .WVALID_S1(WVALID_S1),
    //master1 receive
    .WREADY_S1(WREADY_S1),

    //master1 send
    .WDATA_SDEFAULT(w_WDATA_SDEFAULT),
    .WSTRB_SDEFAULT(w_WSTRB_SDEFAULT),
    .WLAST_SDEFAULT(w_WLAST_SDEFAULT),
    .WVALID_SDEFAULT(w_WVALID_SDEFAULT),
    //master1 receive
    .WREADY_SDEFAULT(w_WREADY_SDEFAULT),

    .AWVALID_S0(AWVALID_S0),
    .AWVALID_S1(AWVALID_S1),
    .AWVALID_SDEFAULT(w_AWVALID_SDEFAULT)
);

WR uwr(
    .clk(ACLK),
    .rst(ARESETn),

    //master1 receive
    .BID_M1(BID_M1),
    .BRESP_M1(BRESP_M1),
    .BVALID_M1(BVALID_M1),
    //master1 send
    .BREADY_M1(BREADY_M1),

    //slave0 send
    .BID_S0(BID_S0),
    .BRESP_S0(BRESP_S0),
    .BVALID_S0(BVALID_S0),
    //slave0 receive
    .BREADY_S0(BREADY_S0),

    //slave1 send
    .BID_S1(BID_S1),
    .BRESP_S1(BRESP_S1),
    .BVALID_S1(BVALID_S1),
    //slave1 receive
    .BREADY_S1(BREADY_S1),

    //slaveD send
    .BID_SDEFAULT(w_BID_SDEFAULT),
    .BRESP_SDEFAULT(w_BRESP_SDEFAULT),
    .BVALID_SDEFAULT(w_BVALID_SDEFAULT),
    //slaveD receive
    .BREADY_SDEFAULT(w_BREADY_SDEFAULT)
);

endmodule
