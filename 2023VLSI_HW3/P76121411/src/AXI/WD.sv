// `include "AXI_define.svh"
`include "../../include/AXI_define.svh"
module WD (
    input clk,    // Clock
    input rst,  // Asynchronous reset active high

    // master 1 send
    input [`AXI_DATA_BITS-1:0] WDATA_M1,
    input [`AXI_STRB_BITS-1:0] WSTRB_M1,
    input WLAST_M1,
    input WVALID_M1,
    // master 1 receive
    output logic WREADY_M1,

    // slave 0 receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_ROM,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_ROM,
    output logic WLAST_ROM,
    output logic WVALID_ROM,
    // slave 0 send
    input WREADY_ROM,

    // slave 1 receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_IM,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_IM,
    output logic WLAST_IM,
    output logic WVALID_IM,
    // slave 1 send
    input WREADY_IM,

    // slave 2 receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_DM,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_DM,
    output logic WLAST_DM,
    output logic WVALID_DM,
    // slave 2 send
    input WREADY_DM,

    // slave 3 receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_SC,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_SC,
    output logic WLAST_SC,
    output logic WVALID_SC,
    // slave 3 send
    input WREADY_SC,

    // slave 4 receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_WDT,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_WDT,
    output logic WLAST_WDT,
    output logic WVALID_WDT,
    // slave 4 send
    input WREADY_WDT,

    // slave 5 receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_DRAM,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_DRAM,
    output logic WLAST_DRAM,
    output logic WVALID_DRAM,
    // slave 5 send
    input WREADY_DRAM,

    // slave default receive
    output logic [`AXI_DATA_BITS-1:0] WDATA_SD,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_SD,
    output logic WLAST_SD,
    output logic WVALID_SD,
    // slave 0 send
    input WREADY_SD,

    input AWVALID_ROM,
    input AWVALID_IM,
    input AWVALID_DM,
    input AWVALID_SC,
    input AWVALID_WDT,
    input AWVALID_DRAM,
    input AWVALID_SD
);
//logic
    logic reg_WVALID_ROM, reg_WVALID_IM, reg_WVALID_DM, reg_WVALID_SC, reg_WVALID_WDT, reg_WVALID_DRAM, reg_WVALID_SD;
    logic [6:0] slave;

    logic [`AXI_DATA_BITS-1:0] WDATA_M;
    logic [`AXI_STRB_BITS-1:0] WSTRB_M;
    logic WLAST_M;
    logic WVALID_M;

    logic READY;

// signals from master 1
    assign WDATA_M = WDATA_M1;
    assign WSTRB_M = WSTRB_M1;
    assign WLAST_M = WLAST_M1;
    assign WVALID_M = WVALID_M1;
    // signals to master 1
    assign WREADY_M1 = READY & WVALID_M;
// signals to slaves
    // slave 0
    assign WDATA_ROM = WDATA_M;
    assign WSTRB_ROM = (WVALID_ROM)? WSTRB_M: `AXI_STRB_BITS'b1111;
    assign WLAST_ROM = WLAST_M;
    // slave 1
    assign WDATA_IM = WDATA_M;
    assign WSTRB_IM = (WVALID_IM)? WSTRB_M: `AXI_STRB_BITS'b1111;
    assign WLAST_IM = WLAST_M;
    // slave 2
    assign WDATA_DM = WDATA_M;
    assign WSTRB_DM = (WVALID_DM)? WSTRB_M: `AXI_STRB_BITS'b1111;
    assign WLAST_DM = WLAST_M;
    // slave 3
    assign WDATA_SC = WDATA_M;
    assign WSTRB_SC = (WVALID_SC)? WSTRB_M: `AXI_STRB_BITS'b1111;
    assign WLAST_SC = WLAST_M;
    // slave 4
    assign WDATA_WDT = WDATA_M;
    assign WSTRB_WDT = (WVALID_WDT)? WSTRB_M: `AXI_STRB_BITS'b1111;
    assign WLAST_WDT = WLAST_M;
    // slave 5
    assign WDATA_DRAM = WDATA_M;
    assign WSTRB_DRAM = (WVALID_DRAM)? WSTRB_M: `AXI_STRB_BITS'b1111;
    assign WLAST_DRAM = WLAST_M;
    // slave SD
    assign WDATA_SD = WDATA_M;
    assign WSTRB_SD = WSTRB_M;
    assign WLAST_SD = WLAST_M;
//ARREADY
    assign slave = {(reg_WVALID_SD || AWVALID_SD), (reg_WVALID_DRAM || AWVALID_DRAM), (reg_WVALID_WDT || AWVALID_WDT), (reg_WVALID_SC || AWVALID_SC), (reg_WVALID_DM || AWVALID_DM), (reg_WVALID_IM || AWVALID_IM), (reg_WVALID_ROM || AWVALID_ROM)};


    always_ff @(posedge clk ) begin
        if(rst) begin
            reg_WVALID_ROM <= 1'b0;
            reg_WVALID_IM <= 1'b0;
            reg_WVALID_DM <= 1'b0;
            reg_WVALID_SC <= 1'b0;
            reg_WVALID_WDT <= 1'b0;
            reg_WVALID_DRAM <= 1'b0;
            reg_WVALID_SD <= 1'b0;
        end else begin
            reg_WVALID_ROM <= (AWVALID_ROM)? 1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:reg_WVALID_ROM);
            reg_WVALID_IM <=  (AWVALID_IM)?  1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:reg_WVALID_IM);
            reg_WVALID_DM <=  (AWVALID_DM)?  1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:reg_WVALID_DM);
            reg_WVALID_SC <=  (AWVALID_SC)?  1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:reg_WVALID_SC);
            reg_WVALID_WDT <= (AWVALID_WDT)? 1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:reg_WVALID_WDT);
            reg_WVALID_DRAM <=(AWVALID_DRAM)?1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:reg_WVALID_DRAM);
            reg_WVALID_SD <=  (AWVALID_SD)?  1'b1:((WVALID_M & READY & WLAST_M)? 1'b0:reg_WVALID_SD);
        end
    end

    always_comb begin
        case (slave)
            7'b0000001:begin
                READY = WREADY_ROM;
                WVALID_ROM = WVALID_M;
                WVALID_IM = 1'b0;
                WVALID_DM = 1'b0;
                WVALID_SC = 1'b0;
                WVALID_WDT = 1'b0;
                WVALID_DRAM = 1'b0;
                WVALID_SD = 1'b0;
            end 
            7'b0000010:begin
                READY = WREADY_IM;
                WVALID_ROM = 1'b0;
                WVALID_IM = WVALID_M;
                WVALID_DM = 1'b0;
                WVALID_SC = 1'b0;
                WVALID_WDT = 1'b0;
                WVALID_DRAM = 1'b0;
                WVALID_SD = 1'b0;
            end
            7'b0000100:begin
                READY = WREADY_DM;
                WVALID_ROM = 1'b0;
                WVALID_IM = 1'b0;
                WVALID_DM = WVALID_M;
                WVALID_SC = 1'b0;
                WVALID_WDT = 1'b0;
                WVALID_DRAM = 1'b0;
                WVALID_SD = 1'b0;
            end
            7'b0001000:begin
                READY = WREADY_SC;
                WVALID_ROM = 1'b0;
                WVALID_IM = 1'b0;
                WVALID_DM = 1'b0;
                WVALID_SC = WVALID_M;
                WVALID_WDT = 1'b0;
                WVALID_DRAM = 1'b0;
                WVALID_SD = 1'b0;
            end
            7'b0010000:begin
                READY = WREADY_WDT;
                WVALID_ROM = 1'b0;
                WVALID_IM = 1'b0;
                WVALID_DM = 1'b0;
                WVALID_SC = 1'b0;
                WVALID_WDT = WVALID_M;
                WVALID_DRAM = 1'b0;
                WVALID_SD = 1'b0;
            end
            7'b0100000:begin
                READY = WREADY_DRAM;
                WVALID_ROM = 1'b0;
                WVALID_IM = 1'b0;
                WVALID_DM = 1'b0;
                WVALID_SC = 1'b0;
                WVALID_WDT = 1'b0;
                WVALID_DRAM = WVALID_M;
                WVALID_SD = 1'b0;
            end
            7'b1000000:begin
                READY = WREADY_SD;
                WVALID_ROM = 1'b0;
                WVALID_IM = 1'b0;
                WVALID_DM = 1'b0;
                WVALID_SC = 1'b0;
                WVALID_WDT = 1'b0;
                WVALID_DRAM = 1'b0;
                WVALID_SD = WVALID_M;
            end
            default: begin
                READY = 1'b0;
                WVALID_ROM = 1'b0;
                WVALID_IM = 1'b0;
                WVALID_DM = 1'b0;
                WVALID_SC = 1'b0;
                WVALID_WDT = 1'b0;
                WVALID_DRAM = 1'b0;
                WVALID_SD = 1'b0;
            end
        endcase
        
    end

endmodule
