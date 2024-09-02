`include "../include/AXI_define.svh"
// `include "def.svh"
module Master (
    input clk,
    input rst,

    //from CPU
    input read,
    input write,
    input [`AXI_STRB_BITS-1:0] write_type,
    input [`AXI_DATA_BITS-1:0] data_in,
    input [`AXI_ADDR_BITS-1:0] addr_in,
    //to CPU
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic stall, // to be fixed

    //AXI 
    //write address
    output logic [`AXI_ID_BITS   -1:0] AWID,
    output logic [`AXI_ADDR_BITS -1:0] AWADDR,
    output logic [`AXI_LEN_BITS  -1:0] AWLEN,
    output logic [`AXI_SIZE_BITS -1:0] AWSIZE,
    output logic [1:0] AWBURST,
    output logic AWVALID,
    input AWREADY,
    //write data
    output logic [`AXI_DATA_BITS-1:0] WDATA,
    output logic [`AXI_STRB_BITS-1:0] WSTRB,
    output logic WLAST,
    output logic WVALID,
    input WREADY,
    //write response
    input [`AXI_ID_BITS   -1:0] BID,
    input [1:0] BRESP,
    input BVALID,
    output logic BREADY,

    //read address
    output logic [`AXI_ID_BITS   -1:0] ARID,
    output logic [`AXI_ADDR_BITS -1:0] ARADDR,
    output logic [`AXI_LEN_BITS  -1:0] ARLEN,
    output logic [`AXI_SIZE_BITS -1:0] ARSIZE,
    output logic [1:0] ARBURST,
    output logic ARVALID,
    input ARREADY,
    //read data
    input [`AXI_ID_BITS  -1:0] RID,
    input [`AXI_DATA_BITS-1:0] RDATA,
    input [1:0] RRESP,
    input RLAST,
    input RVALID,
    output logic RREADY
);
    logic [2:0] master_state , next_state;
    parameter   state_init = 3'b000,
                state_read_addr = 3'b001,
                state_read_data = 3'b010,
                state_write_addr = 3'b011,
                state_write_data = 3'b100,
                state_response = 3'b101 ;

//=============================================
    logic AW_done, AR_done, R_done, W_done, B_done;
    assign AW_done = AWREADY & AWVALID;
    assign W_done  = WREADY  & WVALID;
    assign B_done  = BREADY  & BVALID;
    assign AR_done = ARREADY & ARVALID;
    assign R_done  = RREADY  & RVALID;
//=============================================
// AR // address read==========================
    assign ARID = `AXI_ID_BITS'b0;
    assign ARLEN = `AXI_LEN_BITS'h0; //`AXI_LEN_BITS'b11
    assign ARSIZE = `AXI_SIZE_BITS'b10;
    assign ARBURST = `AXI_BURST_INC;
    assign ARADDR = addr_in;
//=============================================
// R // data read==============================
    logic [`AXI_DATA_BITS-1:0] reg_RDATA;
    assign data_out = R_done ? RDATA : reg_RDATA;
    assign RREADY = (master_state == state_read_data) ? 1'b1 : 1'b0;
//=============================================
// AW //=======================================
    assign AWID    = `AXI_ID_BITS'b0;
    assign AWLEN   = `AXI_LEN_BITS'b11; //`AXI_LEN_BITS'h0;   //`AXI_LEN_BITS'b11; 123123
    assign AWSIZE  = `AXI_SIZE_BITS'b10;
    assign AWBURST = `AXI_BURST_INC;
    assign AWADDR  = addr_in;
//=============================================
// W //========================================
    assign WSTRB = write_type;
    assign WLAST = 1'b1;
    assign WDATA = data_in;
    //mode choose
    assign WVALID = (master_state == state_write_data) ? 1'b1 : 1'b0; 
//=============================================
// B //========================================
    assign BREADY = ( (master_state == state_response) || W_done ) ? 1'b1 : 1'b0;
//=============================================
// decide stall or not //======================
    assign stall = ( read & ~R_done ) | ( write & ~W_done);
//=============================================

//next state FF
    always_ff @(posedge clk )begin
        if(rst)
            master_state <= state_init;
        else
            master_state <= next_state;
    end

    logic r,w;
    always_ff @( posedge clk ) begin
        if(rst)begin
            r <= 1'b0;
            w <= 1'b0;
        end
        else begin
            r <= 1'b1;
            w <= 1'b1;
        end
    end
//choose master state
    always_comb begin 
        case (master_state)
            state_init:begin
                if(ARVALID)
                    if(AR_done)
                        next_state = state_read_data;
                    else
                        next_state = state_read_addr;
                else if(AWVALID)
                    if(AW_done)
                        next_state = state_write_data;
                    else
                        next_state = state_write_addr;
                else
                    next_state = state_init;
            end 
            state_read_addr:begin
                if(AR_done)
                    next_state = state_read_data;
                else
                    next_state = state_read_addr;
            end 
            state_read_data:begin
                if(R_done & RLAST)
                    next_state = state_init;
                else
                    next_state = state_read_data;

            end 
            state_write_addr:begin
                if(AW_done)
                    next_state = state_write_data;
                else
                    next_state = state_write_addr;
            end 
            state_write_data:begin
                if(W_done)
                    next_state = state_response;
                else
                    next_state = state_write_data;
            end 
            default: begin //state_response
                if(B_done)
                    next_state = state_init;
                else
                    next_state = state_response;
            end
        endcase
    end

//ARVALID every state mode
    always_comb begin
        case (master_state)
            state_init:
                ARVALID =  read & r;
            state_read_addr:
                ARVALID = 1'b1;
            default:
                ARVALID = 1'b0;
        endcase
    end

//R
    always_ff @( posedge clk) begin
        if (rst) begin
            reg_RDATA <= `AXI_DATA_BITS'b0;
        end else begin
            reg_RDATA <= R_done ? RDATA : reg_RDATA;
        end
    end
    
//AWVALID every state mode
    always_comb begin
        case (master_state)
            state_init:
                AWVALID = write & w;
            state_write_addr:
                AWVALID = 1'b1;
            default: 
                AWVALID = 1'b0;
        endcase
    end

endmodule
