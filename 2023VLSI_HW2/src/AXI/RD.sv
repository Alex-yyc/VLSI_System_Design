`include "../../include/AXI_define.svh"

module RD (

    input clk,
    input rst,

    //Master0 to slave
    output [`AXI_ID_BITS  -1:0] RID_M0,
    output [`AXI_DATA_BITS-1:0] RDATA_M0,
    output [1:0] RRESP_M0,
    output logic RLAST_M0,
    output logic RVALID_M0,
    //Master0 send
    input RREADY_M0,

    //Master1 receive
    output [`AXI_ID_BITS  -1:0] RID_M1,
    output [`AXI_DATA_BITS-1:0] RDATA_M1,
    output [1:0] RRESP_M1,
    output logic RLAST_M1,
    output logic RVALID_M1,
    //Master1 send
    input RREADY_M1,

    //Slave0 send
    input [`AXI_IDS_BITS -1:0] RID_S0,
    input [`AXI_DATA_BITS-1:0] RDATA_S0,
    input [1:0] RRESP_S0,
    input RLAST_S0,
    input RVALID_S0,
    //Slave0 receive
    output logic RREADY_S0,

    //Slave1 send
    input [`AXI_IDS_BITS -1:0] RID_S1,
    input [`AXI_DATA_BITS-1:0] RDATA_S1,
    input [1:0] RRESP_S1,
    input RLAST_S1,
    input RVALID_S1,
    //Slave1 receive
    output logic RREADY_S1,

    //SlaveD send
    input [`AXI_IDS_BITS -1:0] RID_SDEFAULT,
    input [`AXI_DATA_BITS-1:0] RDATA_SDEFAULT,
    input [1:0] RRESP_SDEFAULT,
    input RLAST_SDEFAULT,
    input RVALID_SDEFAULT,
    //SlaveD receive
    output logic RREADY_SDEFAULT
);
logic [2:0] slave;
logic [1:0] master;

//Slave
logic [`AXI_IDS_BITS -1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [1:0] RRESP_S;
logic RLAST_S;
logic RVALID_S;
//Master
logic READY_M;

logic lock_S0;
logic lock_S1;
logic lock_SDEFAULT;

//master0
assign RID_M0   = RID_S[`AXI_ID_BITS-1:0];
assign RDATA_M0 = RDATA_S;
assign RRESP_M0 = RRESP_S;
assign RLAST_M0 = RLAST_S;
//master1
assign RID_M1   = RID_S[`AXI_ID_BITS-1:0];
assign RDATA_M1 = RDATA_S;
assign RRESP_M1 = RRESP_S;
assign RLAST_M1 = RLAST_S;

always_ff @( posedge clk or negedge rst ) begin
    if(~rst) begin
        lock_S0 <= 1'b0;
        lock_S1 <= 1'b0;
        lock_SDEFAULT <= 1'b0; 
    end
    else begin
        lock_S0 <= (READY_M & RLAST_S0) ? 1'b0:(RVALID_S0 & ~RVALID_S1 & ~RVALID_SDEFAULT) ? 1'b1 : lock_S0;
        lock_S1 <= (READY_M & RLAST_S1) ? 1'b0:(~lock_S0 & RVALID_S1 & ~RVALID_SDEFAULT) ? 1'b1 : lock_S1;
        lock_SDEFAULT <= (READY_M & RLAST_SDEFAULT) ? 1'b0:(~lock_S0 & ~lock_S1 & RVALID_SDEFAULT) ? 1'b1 : lock_SDEFAULT;
    end
end

always_comb begin
    if ((RVALID_SDEFAULT & ~(lock_S0|lock_S1))|lock_SDEFAULT) 
        slave = 3'b100;
    else if((RVALID_S1 & ~lock_S0) | lock_S1)
        slave = 3'b010;
    else if(RVALID_S0|lock_S0)
        slave = 3'b001;
    else
        slave = 3'b000;
end

always_comb begin
    case (master)
        2'b01 :begin
            READY_M   = RREADY_M0;
            RVALID_M1 = 1'b0;
            RVALID_M0 =  RVALID_S;
        end 
        2'b10 :begin
            READY_M   = RREADY_M1;
            RVALID_M1 = RVALID_S;
            RVALID_M0 = 1'b0;
        end
        default:begin
            READY_M   = 1'b1;
            RVALID_M1 = 1'b0;
            RVALID_M0 = 1'b0;
        end 
    endcase
end

always_comb begin
    case (slave)
        3'b001:begin
            master   = RID_S0[5:4];
            RID_S    = RID_S0;
            RDATA_S  = RDATA_S0;
            RRESP_S  = RRESP_S0;
            RLAST_S  = RLAST_S0;
            //RLAST_S = 1'b0;
            RVALID_S = RVALID_S0;
            
            RREADY_SDEFAULT = 1'b0;
            RREADY_S1       = 1'b0;
            RREADY_S0       = READY_M & RVALID_S0;
        end 
        3'b010:begin
            master   = RID_S1[5:4];
            RID_S    = RID_S1;
            RDATA_S  = RDATA_S1;
            RRESP_S  = RRESP_S1;
            RLAST_S  = RLAST_S1;
            //RLAST_S = 1'b0;
            RVALID_S = RVALID_S1;
            
            RREADY_SDEFAULT = 1'b0;
            RREADY_S1       = READY_M & RVALID_S1;
            RREADY_S0       = 1'b0;
        end
        3'b100:begin
            master   = RID_SDEFAULT[5:4];
            RID_S    = RID_SDEFAULT;
            RDATA_S  = RDATA_SDEFAULT;
            RRESP_S  = RRESP_SDEFAULT;
            RLAST_S  = RLAST_SDEFAULT;
            //RLAST_S = 1'b0;
            RVALID_S = RVALID_SDEFAULT;
            
            RREADY_SDEFAULT = READY_M & RVALID_SDEFAULT;
            RREADY_S1       = 1'b0;
            RREADY_S0       = 1'b0;
        end
        default:begin
            master   = 2'b0;
            RID_S    = `AXI_IDS_BITS'b0;
            RDATA_S  = `AXI_DATA_BITS'b0;
            RRESP_S  = 2'b0;
            RLAST_S  = 1'b0;
            RVALID_S = 1'b0;
            
            RREADY_SDEFAULT = 1'b0;
            RREADY_S1       = 1'b0;
            RREADY_S0       = 1'b0;
        end 
    endcase
end

endmodule