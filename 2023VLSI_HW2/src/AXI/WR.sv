`include "../../include/AXI_define.svh"

module WR (
    input clk,    // Clock
    input rst,  // Asynchronous reset active high

    //master 1 receive
    output logic [`AXI_ID_BITS-1:0] BID_M1,
    output logic [1:0] BRESP_M1,
    output logic BVALID_M1,
    //master1 send
    input BREADY_M1,

    //slave0 send
    input [`AXI_IDS_BITS-1:0] BID_S0,
    input [1:0] BRESP_S0,
    input BVALID_S0,
    //slave0 receive
    output logic BREADY_S0,

    //slave1 send
    input [`AXI_IDS_BITS-1:0] BID_S1,
    input [1:0] BRESP_S1,
    input BVALID_S1,
    //slave0 receive
    output logic BREADY_S1,

    //slaveD send
    input [`AXI_IDS_BITS-1:0] BID_SDEFAULT,
    input [1:0] BRESP_SDEFAULT,
    input BVALID_SDEFAULT,
    // slaveD receive
    output logic BREADY_SDEFAULT
);

logic [2:0] slave;
//consider and store the master should return
logic [`AXI_ID_BITS-1:0] BID_M;
logic [1:0] BRESP_M;
logic BVALID_M;

assign BID_M1 = BID_M;
assign BRESP_M1 = BRESP_M;

//used to decide which slave end ,and send response to master 
always_comb begin  
	if(BVALID_SDEFAULT)
        slave = 3'b100;
	else if(BVALID_S1)
        slave = 3'b010;
    else if(BVALID_S0)
        slave = 3'b001;
    else
        slave = 3'b000;
end

logic READY;
logic [1:0] master;

always_comb begin
    case (master)
        2'b10:begin
            READY = BREADY_M1;
            BVALID_M1 = BVALID_M;
        end 
        default: begin
            READY = 1'b1;
            BVALID_M1 = 1'b0;
        end
    endcase
end

always_comb begin
    case (slave)
        3'b000:begin//default
            master = 2'b0;
            BID_M = `AXI_ID_BITS'b0;
            BRESP_M = 2'b0;
            BVALID_M = 1'b0;
            BREADY_SDEFAULT = 1'b0;
            BREADY_S1 = 1'b0;
            BREADY_S0 = 1'b0;
        end
        3'b001:begin//slave0
            master = BID_S0[5:4];
            BID_M = BID_S0[`AXI_ID_BITS-1:0];
            BRESP_M = BRESP_S0;
            BVALID_M = BVALID_S0;
            BREADY_SDEFAULT = 1'b0;
            BREADY_S1 = 1'b0;
            BREADY_S0 = READY & BVALID_S0;
        end
        3'b010,3'b011:begin//slave1
            master = BID_S1[5:4];
            BID_M = BID_S1[`AXI_ID_BITS-1:0];
            BRESP_M = BRESP_S1;
            BVALID_M = BVALID_S1;
            BREADY_SDEFAULT = 1'b0;
            BREADY_S1 = READY & BVALID_S1;
            BREADY_S0 = 1'b0;
        end
        3'b100,3'b101,3'b110,3'b111:begin
            master = BID_SDEFAULT[5:4];
            BID_M = BID_SDEFAULT[`AXI_ID_BITS-1:0];
            BRESP_M = BRESP_SDEFAULT;
            BVALID_M = BVALID_SDEFAULT;
            BREADY_SDEFAULT = READY & BVALID_SDEFAULT; 
            BREADY_S1 = 1'b0;
            BREADY_S0 = 1'b0;
        end
    endcase
end

endmodule