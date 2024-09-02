`include "AXI_define.svh"
module DefaultSlave (
    input clk,    // Clock
    input rst,  // Asynchronous reset active high

    // DA receive
    input [`AXI_IDS_BITS-1:0] ARID_SDEFAULT,
    input [`AXI_ADDR_BITS-1:0] ARADDR_SDEFAULT,
    input [`AXI_LEN_BITS-1:0] ARLEN_SDEFAULT,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_SDEFAULT,
    input [1:0] ARBURST_SDEFAULT,
    input ARVALID_SDEFAULT,
    // DA send
    output logic ARREADY_SDEFAULT,

    // WD receive
    input [`AXI_DATA_BITS-1:0] WDATA_SDEFAULT,
    input [`AXI_STRB_BITS-1:0] WSTRB_SDEFAULT,
    input WLAST_SDEFAULT,
    input WVALID_SDEFAULT,
    // WD send
    output logic WREADY_SDEFAULT,

    // WR send
    output logic [`AXI_IDS_BITS-1:0] BID_SDEFAULT,
    output logic [1:0] BRESP_SDEFAULT,
    output logic BVALID_SDEFAULT,
    // WR receive
    input BREADY_SDEFAULT,

    // WA receive
    input [`AXI_IDS_BITS-1:0] AWID_SDEFAULT,
    input [`AXI_ADDR_BITS-1:0] AWADDR_SDEFAULT,
    input [`AXI_LEN_BITS-1:0] AWLEN_SDEFAULT,
    input [`AXI_SIZE_BITS-1:0] AWSIZE_SDEFAULT,
    input [1:0] AWBURST_SDEFAULT,
    input AWVALID_SDEFAULT,
    // WA send
    output logic AWREADY_SDEFAULT,

    // DR send
    output logic [`AXI_IDS_BITS-1:0] RID_SDEFAULT,
    output logic [`AXI_DATA_BITS-1:0] RDATA_SDEFAULT,
    output logic [1:0] RRESP_SDEFAULT,
    output logic RLAST_SDEFAULT,
    output logic RVALID_SDEFAULT,
    // DR receive
    input RREADY_SDEFAULT
);
    
logic [1:0] slave_state , next_state;
parameter [1:0] M_address = 2'b00 , 
                M_dataread = 2'b01,
                M_datawrite = 2'b10,
                M_response = 2'b11 ;



logic AW_SDEFAULT_done,W_SDEFAULT_done,B_SDEFAULT_done,AR_SDEFAULT_done,R_SDEFAULT_done;
logic R_done_last, W_done_last;
logic [13:0] reg_RADDR, reg_WADDR;
logic [`AXI_IDS_BITS-1:0] reg_ARID, reg_AWID;
logic [`AXI_LEN_BITS-1:0] reg_ARLEN, reg_AWLEN;
logic [`AXI_LEN_BITS-1:0] cnt;
logic reg_RVALID;
logic [`AXI_DATA_BITS-1:0] reg_RDATA;



//HandShake
    assign AW_SDEFAULT_done = AWVALID_SDEFAULT & AWREADY_SDEFAULT;
    assign W_SDEFAULT_done  = WVALID_SDEFAULT & WREADY_SDEFAULT;
    assign B_SDEFAULT_done  = BVALID_SDEFAULT & BREADY_SDEFAULT;
    assign AR_SDEFAULT_done = ARVALID_SDEFAULT & ARREADY_SDEFAULT;
    assign R_SDEFAULT_done  = RVALID_SDEFAULT & RREADY_SDEFAULT;
//Rx
    assign RLAST_SDEFAULT = (reg_ARLEN == cnt);
    assign RDATA_SDEFAULT = 32'b0 ;
    assign RID_SDEFAULT = reg_ARID;
    assign RRESP_SDEFAULT = `AXI_RESP_DECERR;
//Bx
    assign BID_SDEFAULT = reg_AWID;
    assign BRESP_SDEFAULT = `AXI_RESP_DECERR;
    
assign W_done_last = WLAST_SDEFAULT & W_SDEFAULT_done;
assign R_done_last = RLAST_SDEFAULT & R_SDEFAULT_done;

//===out===
assign WREADY_SDEFAULT = (slave_state == M_datawrite)? 1'b1:1'b0;
assign BVALID_SDEFAULT = (slave_state == M_response)? 1'b1:1'b0;
assign RVALID_SDEFAULT = (slave_state == M_dataread)? 1'b1:1'b0;

always_ff @( posedge clk or negedge rst ) begin
    if (~rst) begin
        slave_state <= M_address;
    end else begin
        slave_state <= next_state;
    end
end

always_comb begin //slave state
    case (slave_state)
        M_address: begin
            if(AR_SDEFAULT_done)
                next_state = M_dataread;
            else if(AW_SDEFAULT_done)
                next_state = M_datawrite;
            else
                next_state = M_address;
        end 
        M_dataread: begin
            if(R_done_last & AW_SDEFAULT_done)
                next_state = M_datawrite;
            else if(R_done_last & AR_SDEFAULT_done)
                next_state = M_dataread;
            else if(R_done_last)
                next_state = M_address;
            else
                next_state = M_dataread;
        end
        M_datawrite: begin
            if(WLAST_SDEFAULT & W_SDEFAULT_done)
                next_state = M_response;
            else
                next_state = M_datawrite;
        end
        M_response: begin
            if(B_SDEFAULT_done & AW_SDEFAULT_done)
                next_state = M_datawrite;
            else if(B_SDEFAULT_done & AR_SDEFAULT_done)
                next_state = M_dataread;
            else if(B_SDEFAULT_done)
                next_state = M_address;
            else
                next_state = M_response;
        end
    endcase
end


//RA , R
always_ff @(posedge clk or negedge rst) begin
    if(~rst) begin
        reg_ARID <= `AXI_IDS_BITS'b0;
        reg_AWID <= `AXI_IDS_BITS'b0;
    end else begin
        reg_ARID <= (AR_SDEFAULT_done)? ARID_SDEFAULT : reg_ARID;
        reg_AWID <= (AW_SDEFAULT_done)? AWID_SDEFAULT : reg_AWID;
    end
end

always_ff @( posedge clk or negedge rst ) begin 
    if(~rst) begin
        reg_ARLEN <= `AXI_LEN_BITS'b0;
        reg_AWLEN <= `AXI_LEN_BITS'b0;
    end
    else begin
        reg_ARLEN <= (AR_SDEFAULT_done)? ARLEN_SDEFAULT:reg_ARLEN;
        reg_AWLEN <= (AW_SDEFAULT_done)? AWLEN_SDEFAULT:reg_AWLEN;
    end
end
    
always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
        cnt <= `AXI_LEN_BITS'b0;
    end
    else begin
        case (slave_state)
            M_dataread: cnt <= (R_done_last)? `AXI_LEN_BITS'b0:((R_SDEFAULT_done)? cnt+`AXI_LEN_BITS'b1:cnt);
            M_datawrite:cnt <= (W_done_last)? `AXI_LEN_BITS'b0:((W_SDEFAULT_done)? cnt+`AXI_LEN_BITS'b1:cnt);
            M_address : cnt <= `AXI_LEN_BITS'b0;
        endcase
    end
end

always_comb begin
        case(slave_state)
            M_address   :begin
                AWREADY_SDEFAULT = 1'b1;
                ARREADY_SDEFAULT = ~AWVALID_SDEFAULT;
            end
            M_dataread :begin
                AWREADY_SDEFAULT = R_SDEFAULT_done;
                ARREADY_SDEFAULT = 1'b0;
            end
            M_datawrite:begin
                AWREADY_SDEFAULT = 1'b0;
                ARREADY_SDEFAULT = 1'b0;
            end
            default:begin /*M_response*/
                AWREADY_SDEFAULT = B_SDEFAULT_done;
                ARREADY_SDEFAULT = 1'b0;
            end
        endcase
    end

endmodule