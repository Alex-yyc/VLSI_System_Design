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
    

parameter [1:0] M_address = 2'b00 , 
                M_dataread = 2'b01,
                M_datawrite = 2'b10,
                M_response = 2'b11 ;
logic [1:0] slave_state , next_state;
logic [3:0]temp_ARLEN;

logic AW_SDEFAULT_done,W_SDEFAULT_done,B_SDEFAULT_done,AR_SDEFAULT_done,R_SDEFAULT_done;
//HandShake
    assign AW_SDEFAULT_done = AWVALID_SDEFAULT & AWREADY_SDEFAULT;
    assign W_SDEFAULT_done  = WVALID_SDEFAULT & WREADY_SDEFAULT;
    assign B_SDEFAULT_done  = BVALID_SDEFAULT & BREADY_SDEFAULT;
    assign AR_SDEFAULT_done = ARVALID_SDEFAULT & ARREADY_SDEFAULT;
    assign R_SDEFAULT_done  = RVALID_SDEFAULT & RREADY_SDEFAULT;

always_ff @( posedge clk ) begin
    if (rst) begin
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
            if(R_SDEFAULT_done)
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
            if(B_SDEFAULT_done)
                next_state = M_address;
            else
                next_state = M_response;
        end
    endcase
end

always_ff @( posedge clk ) begin 
    if(rst) begin
        temp_ARLEN <= `AXI_LEN_BITS'b0;
    end
    else begin
        temp_ARLEN <= (AR_SDEFAULT_done)? ARLEN_SDEFAULT:temp_ARLEN;
    end
end

assign ARREADY_SDEFAULT = (slave_state==M_address)?1'b1:1'b0;

//RA , R
always_ff @(posedge clk ) begin
    if(rst) begin
        RID_SDEFAULT <= 8'b0;
    end else begin
        RID_SDEFAULT <= (AR_SDEFAULT_done)? ARID_SDEFAULT : RID_SDEFAULT;
    end
end
    assign RDATA_SDEFAULT = 32'b0 ;
    assign RRESP_SDEFAULT = `AXI_RESP_DECERR;


always_ff @(posedge clk) begin
    if (rst) begin
        RLAST_SDEFAULT <= 1'b1;
    end else begin
        if (AR_SDEFAULT_done) begin
            if (ARLEN_SDEFAULT == 4'b0) RLAST_SDEFAULT <= 1'b1;
            else RLAST_SDEFAULT <= 1'b0;
        end
        else if(R_SDEFAULT_done) begin
            if ((temp_ARLEN == 4'b1) & (RLAST_SDEFAULT == 1'b0)) begin
                RLAST_SDEFAULT <= 1'b1;
            end
        end
    end
end


assign RVALID_SDEFAULT = (slave_state==M_dataread)?1'b1:1'b0;
assign AWREADY_SDEFAULT = (AWVALID_SDEFAULT & (slave_state==M_address))?1'b1:1'b0;

always_ff @( posedge clk ) begin
    if(rst)begin
        BID_SDEFAULT <= 8'b0;
    end
    else begin
        BID_SDEFAULT <= (AW_SDEFAULT_done)?AWID_SDEFAULT:BID_SDEFAULT;
    end
end

assign WREADY_SDEFAULT = (WVALID_SDEFAULT && (slave_state==M_datawrite));
assign BRESP_SDEFAULT = `AXI_RESP_DECERR;
assign BVALID_SDEFAULT = (slave_state==M_response)?1'b1:1'b0;
    
// always_ff @(posedge clk ) begin
//     if (rst) begin
//         cnt <= `AXI_LEN_BITS'b0;
//     end
//     else begin
//         case (slave_state)
//             M_dataread: cnt <= (R_done_last)? `AXI_LEN_BITS'b0:((R_SDEFAULT_done)? cnt+`AXI_LEN_BITS'b1:cnt);
//             M_datawrite:cnt <= (W_done_last)? `AXI_LEN_BITS'b0:((W_SDEFAULT_done)? cnt+`AXI_LEN_BITS'b1:cnt);
//             M_address : cnt <= `AXI_LEN_BITS'b0;
//         endcase
//     end
// end

// always_comb begin
//         case(slave_state)
//             M_address   :begin
//                 AWREADY_SDEFAULT = 1'b1;
//                 ARREADY_SDEFAULT = ~AWVALID_SDEFAULT;
//             end
//             M_dataread :begin
//                 AWREADY_SDEFAULT = R_SDEFAULT_done;
//                 ARREADY_SDEFAULT = 1'b0;
//             end
//             M_datawrite:begin
//                 AWREADY_SDEFAULT = 1'b0;
//                 ARREADY_SDEFAULT = 1'b0;
//             end
//             default:begin /*M_response*/
//                 AWREADY_SDEFAULT = B_SDEFAULT_done;
//                 ARREADY_SDEFAULT = 1'b0;
//             end
//         endcase
//     end

endmodule
