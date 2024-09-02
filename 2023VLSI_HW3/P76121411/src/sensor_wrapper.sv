`include "AXI_define.svh"
`include "sensor_ctrl.sv"
module sensor_wrapper (
    input clk,
    input rst,

    // AXI
    //WRITE ADDRESS
    input [`AXI_IDS_BITS   -1:0] AWID,
    input [`AXI_ADDR_BITS -1:0] AWADDR,
    input [`AXI_LEN_BITS  -1:0] AWLEN,
    input [`AXI_SIZE_BITS -1:0] AWSIZE,
    input [1:0] AWBURST,
    input AWVALID,
    output logic AWREADY,
    //WRITE DATA
    input [`AXI_DATA_BITS-1:0] WDATA,
    input [`AXI_STRB_BITS-1:0] WSTRB,
    input WLAST,
    input WVALID,
    output logic WREADY,
    //WRITE RESPONSE
    output logic [`AXI_IDS_BITS   -1:0] BID,
    output logic [1:0] BRESP,
    output logic BVALID,
    input BREADY,

    //READ ADDRESS
    input [`AXI_IDS_BITS   -1:0] ARID,
    input [`AXI_ADDR_BITS -1:0] ARADDR,
    input [`AXI_LEN_BITS  -1:0] ARLEN,
    input [`AXI_SIZE_BITS -1:0] ARSIZE,
    input [1:0] ARBURST,
    input ARVALID,
    output logic ARREADY,
    //READ DATA
    output logic [`AXI_IDS_BITS  -1:0] RID,
    output logic [`AXI_DATA_BITS-1:0] RDATA,
    output logic [1:0] RRESP,
    output logic RLAST,
    output logic RVALID,
    input RREADY,

    input sensor_ready,
    input [31:0] sensor_out,

    output logic sensor_en,
    output logic sensor_interrupt
);
//=============================================// assign
    logic AW_done, AR_done, R_done, W_done, B_done, R_done_last, W_done_last;
    assign AW_done = AWREADY & AWVALID;
    assign W_done  = WREADY  & WVALID;
    assign B_done  = BREADY  & BVALID;
    assign AR_done = ARREADY & ARVALID;
    assign R_done  = RREADY  & RVALID;
    assign R_done_last = R_done & RLAST;
    assign W_done_last = W_done & WLAST;
//=============================================// State handler
    logic [1:0] slave_state, next_state;
    parameter [1:0] M_address    = 2'b00,
                    M_dataread  = 2'b01,
                    M_datawrite = 2'b10,
                    M_response   = 2'b11;
//push next_state to slave_state
    always_ff @(posedge clk  ) begin
        if(rst) begin
            slave_state <= M_address;
        end else begin
            slave_state <= next_state;
        end
    end                
//decide the next_state and push it into next_state
    always_comb begin 
        case(slave_state)
            M_address: begin
                if(AW_done & W_done)
                    next_state = M_response;
                else if(AW_done)
                    next_state = M_datawrite;
                else if(AR_done)
                    next_state = M_dataread;
                else
                    next_state = M_address;
            end
            M_dataread: begin
                if(R_done_last & AW_done)
                    next_state = M_datawrite;
                else if(R_done_last & AR_done)
                    next_state = M_dataread;
                else if(R_done_last)
                    next_state = M_address;
                else
                    next_state = M_dataread;
            end
            M_datawrite: begin
                if(W_done_last)
                    next_state = M_response;
                else
                    next_state = M_datawrite;
            end
            default/*M_response*/: begin
                if(B_done & AW_done)
                    next_state = M_datawrite;
                else if(B_done & AR_done)
                    next_state = M_dataread;
                else if(B_done)
                    next_state = M_address;
                else
                    next_state = M_response;
            end
        endcase // slave_state
    end    

//Rx
    
    assign RRESP = `AXI_RESP_OKAY;
//Bx
    
    assign BRESP = `AXI_RESP_OKAY;
//wire signal
    // assign W_done_last = WLAST & W_done;
    // assign R_done_last = RLAST & R_done;
//WREADY,BVALID,RVALID
    assign WREADY = (slave_state == M_datawrite)? 1'b1:1'b0;
    assign BVALID = (slave_state == M_response)? 1'b1:1'b0;
    assign RVALID = (slave_state == M_dataread)? 1'b1:1'b0;
//=============================================// RWID
    logic [`AXI_IDS_BITS-1:0] reg_ARID, reg_AWID;
    always_ff @(posedge clk ) begin
        if(rst) begin
                reg_ARID <= `AXI_IDS_BITS'b0;
                reg_AWID <= `AXI_IDS_BITS'b0;
        end else begin
            reg_ARID <= (AR_done)? ARID:reg_ARID;
            reg_AWID <= (AW_done)? AWID:reg_AWID;
        end
    end
    assign RID = reg_ARID;
    assign BID = reg_AWID;
//=============================================// len
    logic [`AXI_LEN_BITS-1:0] reg_ARLEN, reg_AWLEN;
    always_ff @(posedge clk  ) begin
        if(rst) begin
            reg_ARLEN <= `AXI_LEN_BITS'b0;
            reg_AWLEN <= `AXI_LEN_BITS'b0;
        end else begin
            reg_ARLEN <= (AR_done)? ARLEN:reg_ARLEN;
            reg_AWLEN <= (AW_done)? AWLEN:reg_AWLEN;
        end
    end
//=============================================// cnt
    logic [`AXI_LEN_BITS-1:0] cnt;
    always_ff @(posedge clk ) begin
        if (rst) begin
            cnt <= `AXI_LEN_BITS'b0;
        end
        else begin
            case (slave_state)
                M_dataread: cnt <= (R_done_last)? `AXI_LEN_BITS'b0:((R_done)? cnt+`AXI_LEN_BITS'b1:cnt);
                M_datawrite:cnt <= (W_done_last)? `AXI_LEN_BITS'b0:((W_done)? cnt+`AXI_LEN_BITS'b1:cnt);
                M_address : cnt <= `AXI_LEN_BITS'b0;
            endcase
        end
    end
    assign RLAST = (reg_ARLEN == cnt);
    
//slave_state choose lots signal
    always_comb begin
        // case(slave_state)
        //     M_address   :begin
        //         AWREADY = 1'b1;                
        //         ARREADY = ~AWVALID;
        //     end
        //     M_dataread :begin
        //         AWREADY = R_done;
        //         ARREADY = 1'b0;
        //     end
        //     M_datawrite:begin
        //         AWREADY = 1'b0;
        //         ARREADY = 1'b0;
        //     end
        //     default:begin /*M_response*/
        //         AWREADY = B_done;
        //         ARREADY = 1'b0;
        //     end
        // endcase
        AWREADY = (slave_state==M_address)?1'b1:(slave_state==M_response)?B_done:(slave_state==M_dataread)?R_done:1'b0;
        ARREADY = (slave_state==M_address)?(~AWVALID):1'b0;
    end
//=============================================// Choose ADDR
    logic [31:0] reg_ADDR;
    always_ff @(posedge clk  ) begin
        if (rst) begin
            reg_ADDR <= 32'b0;
        end else begin
            reg_ADDR <= (AW_done)? AWADDR: (AR_done)? ARADDR : reg_ADDR;
        end
    end
//=============================================// sensor en and clear
    logic sctrl_en;
    logic sctrl_clear;
    always_ff @(posedge clk ) begin
        if (rst) begin
            sctrl_en <= 1'b0;
            sctrl_clear <= 1'b0;
        end 
        else if (WVALID) begin
            if (reg_ADDR[9:0] == 10'h100)
                sctrl_en <= WDATA[0];
            else if (reg_ADDR[9:0] == 10'h200)
                sctrl_clear <= WDATA[0];
        end

    end
//=============================================// sensor_ctrl
    sensor_ctrl sensor_ctrl(
        .clk(clk),
        .rst(rst),
        .sctrl_en(sctrl_en),
        .sctrl_clear(sctrl_clear),
        .sctrl_addr(reg_ADDR[7:2]),
        .sensor_ready(sensor_ready),
        .sensor_out(sensor_out),
        .sctrl_interrupt(sensor_interrupt),
        .sctrl_out(RDATA),
        .sensor_en(sensor_en)
    );
//=============================================//
endmodule
