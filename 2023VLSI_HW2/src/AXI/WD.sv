`include "../../include/AXI_define.svh"
module WD (
    input clk,    
    input rst,   

    //master1 send
    input [`AXI_DATA_BITS-1:0] WDATA_M1,
    input [`AXI_STRB_BITS-1:0] WSTRB_M1,
    input WLAST_M1,
    input WVALID_M1,
    //master1 receive
    output logic WREADY_M1,

    //slave0 receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
    output logic WLAST_S0,
    output logic WVALID_S0,
    //slave0 send
    input WREADY_S0,

    //slave1 reseive
    output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
    output logic WLAST_S1,
    output logic WVALID_S1,
    //slave1 send
    input WREADY_S1,

    //slave default receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_SDEFAULT,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_SDEFAULT,
    output logic WLAST_SDEFAULT,
    output logic WVALID_SDEFAULT,
    //slave default send
    input WREADY_SDEFAULT,

    input AWVALID_S0,
    input AWVALID_S1,
    input AWVALID_SDEFAULT
);
//use to decide which slave should choose
logic temp_WVALID_S0;
logic temp_WVALID_S1;
logic temp_WVALID_SDEFAULT;
//use to remember to do which slave
logic [2:0] slave; 

logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic WLAST_M;
logic WVALID_M;

logic READY;
//come from master 1
assign WDATA_M = WDATA_M1;
assign WSTRB_M = WSTRB_M1;
assign WLAST_M = WLAST_M1;
assign WVALID_M = WVALID_M1;
//send to master 1
assign WREADY_M1 = READY & WVALID_M;

//send to slaves. sned all type out ,no matter choose which
//slave 0
assign WDATA_S0 = WDATA_M;
assign WSTRB_S0 = (WVALID_S0)?WSTRB_M: `AXI_STRB_BITS'b1111;//if can send, see strb ,else fill all bits
assign WLAST_S0 = WLAST_M;
// slave 1
assign WDATA_S1 = WDATA_M;
assign WSTRB_S1 = (WVALID_S1)?WSTRB_M: `AXI_STRB_BITS'b1111;
assign WLAST_S1 = WLAST_M;
// slave default
assign WDATA_SDEFAULT = WDATA_M;
assign WSTRB_SDEFAULT = WSTRB_M;
assign WLAST_SDEFAULT = WLAST_M;

// ARREADY is used to decide which slave should receive the data
assign slave = {(temp_WVALID_SDEFAULT | AWVALID_SDEFAULT), (temp_WVALID_S1 | AWVALID_S1), (temp_WVALID_S0 | AWVALID_S0)};

always_ff @( posedge clk or negedge rst ) begin
    if (~rst) begin
        temp_WVALID_S0        <= 1'b0;
        temp_WVALID_S1        <= 1'b0;
        temp_WVALID_SDEFAULT  <= 1'b0;
    end else begin
        temp_WVALID_S0 <= (AWVALID_S0)? 1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:temp_WVALID_S0);
        temp_WVALID_S1 <= (AWVALID_S1)? 1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:temp_WVALID_S1);
        temp_WVALID_SDEFAULT <= (AWVALID_SDEFAULT)? 1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:temp_WVALID_SDEFAULT);
        // temp_WVALID_S0 <= (AWVALID_S0)? 1'b1:((WREADY_M1 & WLAST_M)? 1'b0:temp_WVALID_S0);
        // temp_WVALID_S1 <= (AWVALID_S1)? 1'b1:((WREADY_M1 & WLAST_M)? 1'b0:temp_WVALID_S1);
        // temp_WVALID_SDEFAULT <= (AWVALID_SDEFAULT)? 1'b1:((WREADY_M1 & WLAST_M)? 1'b0:temp_WVALID_SDEFAULT);
    end
end

always_comb begin
    case(slave)
        // slave 0
        3'b001: begin
            READY = WREADY_S0;
            WVALID_SDEFAULT = 1'b0;
            WVALID_S1       = 1'b0;
            WVALID_S0       = WVALID_M;
        end
        // slave 1
        3'b010: begin
            READY = WREADY_S1;
            WVALID_SDEFAULT = 1'b0;
            WVALID_S1       = WVALID_M;
            WVALID_S0       = 1'b0;
        end
        // slave default
        3'b100: begin
            READY = WREADY_SDEFAULT;
            WVALID_SDEFAULT = WVALID_M;
            WVALID_S1       = 1'b0;
            WVALID_S0       = 1'b0;
        end
        default: begin // shouldn't exist
            READY = 1'b1;
            WVALID_SDEFAULT = 1'b0;
            WVALID_S1       = 1'b0;
            WVALID_S0       = 1'b0;
        end
    endcase // slave
end

endmodule