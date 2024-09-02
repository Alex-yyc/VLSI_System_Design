`include "AXI_define.svh"
`include "WDT.sv"
module WDT_wrapper (
    input clk,
    input rst,
    input clk2,
    input rst2,

    // WRITE ADDRESS
    input [`AXI_IDS_BITS-1:0] AWID,
    input [`AXI_ADDR_BITS-1:0] AWADDR,
    input [`AXI_LEN_BITS-1:0] AWLEN,
    input [`AXI_SIZE_BITS-1:0] AWSIZE,
    input [1:0] AWBURST,
    input AWVALID,
    output logic AWREADY,
    // WRITE DATA
    input [`AXI_DATA_BITS-1:0] WDATA,
    input [`AXI_STRB_BITS-1:0] WSTRB,
    input WLAST,
    input WVALID,
    output logic WREADY,
    // WRITE RESPONSE
    output logic [`AXI_IDS_BITS-1:0] BID,
    output logic [1:0] BRESP,
    output logic BVALID,
    input BREADY,

    // READ ADDRESS
    input [`AXI_IDS_BITS-1:0] ARID,
    input [`AXI_ADDR_BITS-1:0] ARADDR,
    input [`AXI_LEN_BITS-1:0] ARLEN,
    input [`AXI_SIZE_BITS-1:0] ARSIZE,
    input [1:0] ARBURST,
    input ARVALID,
    output logic ARREADY,
    // READ DATA
    output logic [`AXI_IDS_BITS-1:0] RID,
    output logic [`AXI_DATA_BITS-1:0] RDATA,
    output logic [1:0] RRESP,
    output logic RLAST,
    output logic RVALID,
    input RREADY,

    output logic wto
);
    logic AW_done, AR_done, R_done, W_done, B_done;
    assign AW_done = AWREADY & AWVALID;
    assign W_done = WREADY & WVALID;
    assign B_done = BREADY & BVALID;
    assign AR_done = ARREADY & ARVALID;
    assign R_done = RREADY & RVALID;

    logic R_donelast,W_donelast;
    assign R_donelast = R_done & RLAST;
    assign W_donelast = W_done & WLAST;

    logic [1:0] s_slave,s_next;
    parameter [1:0] S_addr = 2'b00,
                    S_readdata = 2'b01,
                    S_writedata = 2'b10,
                    S_resp = 2'b11;
                    
    always_ff @(posedge clk) begin
        if (rst) begin
            s_slave <= S_addr;
        end else begin
            s_slave <= s_next;
        end
    end

    always_comb begin
    case (s_slave)
        S_addr:begin
        if (AW_done & W_done) begin
            s_next = S_resp;
        end
        else if (AW_done) begin
            s_next = S_writedata;
        end
        else if (AR_done) begin
            s_next = S_readdata;
        end
        else begin
            s_next = S_addr;
        end
        end
        S_readdata:begin
        if (R_donelast & AW_done) begin
            s_next = S_writedata;
        end
        else if (R_donelast & AR_done) begin
            s_next = S_readdata;
        end
        else if (R_donelast) begin
            s_next = S_addr;
        end
        else s_next = S_readdata;
        end
        S_writedata:begin
        s_next = (W_donelast)?S_resp:S_writedata;
        end
        default: begin  //S_resp
        if (B_done & AW_done) begin
            s_next = S_writedata;
        end
        else if (B_done & AR_done) begin
            s_next = S_readdata;
        end
        else if (B_done) begin
            s_next = S_addr;
        end
        else s_next = S_resp;
        end
    endcase
    end

    always_comb begin
        AWREADY = (s_slave == S_addr)?1'b1:(s_slave == S_resp)?B_done:(s_slave == S_readdata)?R_done:1'b0;
        ARREADY = (s_slave == S_addr)?(~AWVALID):1'b0;
    end

    assign WREADY = (s_slave == S_writedata)? 1'b1:1'b0;
    assign BVALID = (s_slave == S_resp)? 1'b1:1'b0;
    assign RVALID = (s_slave == S_readdata)? 1'b1:1'b0;
    assign RRESP = `AXI_RESP_OKAY;
    assign BRESP = `AXI_RESP_OKAY;

    //ARID, AWID
    logic [`AXI_IDS_BITS-1:0] reg_ARID, reg_AWID;
    always_ff @(posedge clk) begin
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

    //ARLEN, AWLEN
    logic [`AXI_LEN_BITS-1:0] reg_ARLEN, reg_AWLEN;
    always_ff @(posedge clk ) begin
    if (rst) begin
        {reg_ARLEN,reg_AWLEN} <= {2{`AXI_LEN_BITS'b0}};
    end
    else begin
        reg_ARLEN <= (AR_done)?ARLEN:reg_ARLEN;
        reg_AWLEN <= (AW_done)?AWLEN:reg_AWLEN;
    end
    end

    //RLAST
    logic [`AXI_LEN_BITS-1:0] cnt;
    always_ff @(posedge clk ) begin
    if (rst) begin
        cnt <= `AXI_LEN_BITS'b0;
    end
    else begin
        case (s_slave)
        S_readdata:  cnt <= (R_donelast)?`AXI_LEN_BITS'b0:((R_done)? cnt+`AXI_LEN_BITS'b1:cnt);
        S_writedata: cnt <= (W_donelast)?`AXI_LEN_BITS'b0:((W_done)? cnt+`AXI_LEN_BITS'b1:cnt);
        endcase
    end
    end
    assign RLAST = (reg_ARLEN == cnt);

    
    
    //mapping address
    logic [31:0] reg_ADDR;
    always_ff @(posedge clk ) begin
        if(rst) begin
            reg_ADDR <= 32'b0;
        end else begin
            reg_ADDR <= (AW_done)? AWADDR: reg_ADDR;
        end
    end

    //WDT
    logic WDEN,WDLIVE;
    logic [31:0] WDOCNT;
    logic WTO,wto_temp;
    always_ff @(posedge clk) begin
        if(rst) begin
            //WDEN <= 1'b0;
            //WDLIVE <= 1'b0;
            WDOCNT <= 32'b0;
        end
        else if(WVALID) begin
            //if(reg_ADDR[9:0] == 10'h100)
            //    WDEN <= WDATA[0];
            //else if(reg_ADDR[9:0] == 10'h200)
            //    WDLIVE <= WDATA[0];
            if(reg_ADDR[9:0] == 10'h300)
                WDOCNT <= WDATA;
        end
    end

  always_ff @(posedge clk) begin
 	if(rst) begin
            WDEN <= 1'b0;
            WDLIVE <= 1'b0;
        end
	else if (AWVALID) begin
		WDEN <= (AWADDR[9:0]==10'h100) ? 1'b1: 1'b0;
            WDLIVE <= (AWADDR[9:0]==10'h200) ? 1'b1: 1'b0;
	end 
	else begin
	WDEN <= 1'b0;
            WDLIVE <= 1'b0;
	end
end


    always_ff@(posedge clk ) begin
        wto_temp <= WTO;
		wto <= wto_temp;
    end
    
    WDT WDT(
        .clk(clk),
        .rst(rst),
        .clk2(clk2),
        .rst2(rst2),
        .WDEN(WDEN),
        .WDLIVE(WDLIVE),
        .WTOCNT(WDOCNT),
        .WTO(WTO)
    );
    
endmodule
