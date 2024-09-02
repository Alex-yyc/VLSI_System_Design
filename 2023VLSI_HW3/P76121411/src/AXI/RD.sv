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
    input [`AXI_IDS_BITS -1:0] RID_ROM,
    input [`AXI_DATA_BITS-1:0] RDATA_ROM,
    input [1:0] RRESP_ROM,
    input RLAST_ROM,
    input RVALID_ROM,
    //Slave0 receive
    output logic RREADY_ROM,

    //Slave1 send
    input [`AXI_IDS_BITS -1:0] RID_IM,
    input [`AXI_DATA_BITS-1:0] RDATA_IM,
    input [1:0] RRESP_IM,
    input RLAST_IM,
    input RVALID_IM,
    //Slave1 receive
    output logic RREADY_IM,

    //Slave2 send
    input [`AXI_IDS_BITS -1:0] RID_DM,
    input [`AXI_DATA_BITS-1:0] RDATA_DM,
    input [1:0] RRESP_DM,
    input RLAST_DM,
    input RVALID_DM,
    //Slave2 receive
    output logic RREADY_DM,

    //Slave3 send
    input [`AXI_IDS_BITS -1:0] RID_SC,
    input [`AXI_DATA_BITS-1:0] RDATA_SC,
    input [1:0] RRESP_SC,
    input RLAST_SC,
    input RVALID_SC,
    //Slave3 receive
    output logic RREADY_SC,

    //Slave4 send
    input [`AXI_IDS_BITS -1:0] RID_WDT,
    input [`AXI_DATA_BITS-1:0] RDATA_WDT,
    input [1:0] RRESP_WDT,
    input RLAST_WDT,
    input RVALID_WDT,
    //Slave4 receive
    output logic RREADY_WDT,

    //Slave1 send
    input [`AXI_IDS_BITS -1:0] RID_DRAM,
    input [`AXI_DATA_BITS-1:0] RDATA_DRAM,
    input [1:0] RRESP_DRAM,
    input RLAST_DRAM,
    input RVALID_DRAM,
    //Slave1 receive
    output logic RREADY_DRAM,

    //SlaveD send
    input [`AXI_IDS_BITS -1:0] RID_SD,
    input [`AXI_DATA_BITS-1:0] RDATA_SD,
    input [1:0] RRESP_SD,
    input RLAST_SD,
    input RVALID_SD,
    //SlaveD receive
    output logic RREADY_SD
);
// logic
    logic [2:0] slave;
    logic [1:0] master;
// Slave
    logic [`AXI_IDS_BITS -1:0] RID_S;
    logic [`AXI_DATA_BITS-1:0] RDATA_S;
    logic [1:0] RRESP_S;
    logic RLAST_S;
    logic RVALID_S;
// Master
    logic READY_M;
// lock
    logic lock_ROM;
    logic lock_IM;
    logic lock_DM;
    logic lock_SC;
    logic lock_WDT;
    logic lock_DRAM;
    logic lock_SD;

//M0
    assign RID_M0   = RID_S[`AXI_ID_BITS-1:0];
    assign RDATA_M0 = RDATA_S;
    assign RRESP_M0 = RRESP_S;
    assign RLAST_M0 = RLAST_S;
//M1
    assign RID_M1   = RID_S[`AXI_ID_BITS-1:0];
    assign RDATA_M1 = RDATA_S;
    assign RRESP_M1 = RRESP_S;
    assign RLAST_M1 = RLAST_S;

    always_ff @( posedge clk) begin
        if (rst) begin
            lock_ROM <= 1'b0;
            lock_IM <= 1'b0;
            lock_DM <= 1'b0;
            lock_SC <= 1'b0;
            lock_WDT <= 1'b0;
            lock_DRAM <= 1'b0;
            lock_SD <= 1'b0;
        end
        else begin
            lock_ROM <=  (lock_ROM & READY_M & RLAST_ROM)?  1'b0:(RVALID_ROM & ~RVALID_IM & ~RVALID_DM & ~RVALID_SC & ~RVALID_WDT & ~RVALID_DRAM & ~RVALID_SD & ~READY_M)?1'b1:lock_ROM;
            lock_IM <=   (lock_IM & READY_M & RLAST_IM)?    1'b0:(~lock_ROM & RVALID_IM & ~RVALID_DM & ~RVALID_SC & ~RVALID_WDT & ~RVALID_DRAM & ~RVALID_SD & ~READY_M)?1'b1:lock_IM;
            lock_DM <=   (lock_DM & READY_M & RLAST_DM)?    1'b0:(~lock_ROM & ~lock_IM & RVALID_DM & ~RVALID_SC & ~RVALID_WDT & ~RVALID_DRAM & ~RVALID_SD & ~READY_M)?1'b1:lock_DM;
            lock_SC <=   (lock_SC & READY_M & RLAST_SC)?    1'b0:(~lock_ROM & ~lock_IM & ~lock_DM & RVALID_SC & ~RVALID_WDT & ~RVALID_DRAM & ~RVALID_SD & ~READY_M)?1'b1:lock_SC;
            lock_WDT <=  (lock_WDT & READY_M & RLAST_WDT)?  1'b0:(~lock_ROM & ~lock_IM & ~lock_DM & ~lock_SC & RVALID_WDT & ~RVALID_DRAM & ~RVALID_SD & ~READY_M)?1'b1:lock_WDT;
            lock_DRAM <= (lock_DRAM & READY_M & RLAST_DRAM)?1'b0:(~lock_ROM & ~lock_IM & ~lock_DM & ~lock_SC & ~lock_WDT & RVALID_DRAM & ~RVALID_SD & ~READY_M)?1'b1:lock_DRAM;
            lock_SD <=   (lock_SD & READY_M & RLAST_SD)?    1'b0:(~lock_ROM & ~lock_IM & ~lock_DM & ~lock_SC & ~lock_WDT & ~lock_DRAM & RVALID_SD & ~READY_M)?1'b1:lock_SD;
        end
    end

    always_comb begin
        if( (RVALID_SD & ~(lock_ROM | lock_IM | lock_DM | lock_SC | lock_WDT | lock_DRAM)) | lock_SD ) slave = 3'b111;
        else if( (RVALID_DRAM & ~(lock_ROM | lock_IM | lock_DM | lock_SC | lock_WDT)) | lock_DRAM ) slave = 3'b110;
        else if ((RVALID_WDT & ~(lock_ROM | lock_IM | lock_DM | lock_SC)) | lock_WDT) slave = 3'b101; 
        else if ((RVALID_SC & ~(lock_ROM | lock_IM | lock_DM)) | lock_SC) slave = 3'b100;
        else if ((RVALID_DM & ~(lock_ROM | lock_IM)) | lock_DM) slave = 3'b011;
        else if ((RVALID_IM & ~(lock_ROM)) | lock_IM) slave = 3'b010; 
        else if (RVALID_ROM | lock_ROM) slave = 3'b001; 
        else slave = 3'b0;
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
                master = RID_ROM[5:4];
                RID_S = RID_ROM;
                RDATA_S  = RDATA_ROM;
                RRESP_S  = RRESP_ROM;
                RLAST_S  = RLAST_ROM;
                RVALID_S = RVALID_ROM;
                 
                RREADY_ROM = READY_M & RVALID_ROM;
                RREADY_IM = 1'b0;
                RREADY_DM = 1'b0;
                RREADY_SC = 1'b0;
                RREADY_WDT = 1'b0;
                RREADY_DRAM = 1'b0;
                RREADY_SD = 1'b0;
            end
            3'b010:begin
                master = RID_IM[5:4];
                RID_S = RID_IM;
                RDATA_S  = RDATA_IM;
                RRESP_S  = RRESP_IM;
                RLAST_S  = RLAST_IM;
                RVALID_S = RVALID_IM;
                 
                RREADY_ROM = 1'b0;
                RREADY_IM = READY_M & RVALID_IM;
                RREADY_DM = 1'b0;
                RREADY_SC = 1'b0;
                RREADY_WDT = 1'b0;
                RREADY_DRAM = 1'b0;
                RREADY_SD = 1'b0;
            end
            3'b011:begin
                master = RID_DM[5:4];
                RID_S = RID_DM;
                RDATA_S  = RDATA_DM;
                RRESP_S  = RRESP_DM;
                RLAST_S  = RLAST_DM;
                RVALID_S = RVALID_DM;
                 
                RREADY_ROM = 1'b0;
                RREADY_IM = 1'b0;
                RREADY_DM = READY_M & RVALID_DM;
                RREADY_SC = 1'b0;
                RREADY_WDT = 1'b0;
                RREADY_DRAM = 1'b0;
                RREADY_SD = 1'b0;
            end
            3'b100:begin
                master = RID_SC[5:4];
                RID_S = RID_SC;
                RDATA_S  = RDATA_SC;
                RRESP_S  = RRESP_SC;
                RLAST_S  = RLAST_SC;
                RVALID_S = RVALID_SC;
                 
                RREADY_ROM = 1'b0;
                RREADY_IM = 1'b0;
                RREADY_DM = 1'b0;
                RREADY_SC = READY_M & RVALID_SC;
                RREADY_WDT = 1'b0;
                RREADY_DRAM = 1'b0;
                RREADY_SD = 1'b0;
            end
            3'b101:begin
                master = RID_WDT[5:4];
                RID_S = RID_WDT;
                RDATA_S  = RDATA_WDT;
                RRESP_S  = RRESP_WDT;
                RLAST_S  = RLAST_WDT;
                RVALID_S = RVALID_WDT;
                 
                RREADY_ROM = 1'b0;
                RREADY_IM = 1'b0;
                RREADY_DM = 1'b0;
                RREADY_SC = 1'b0;
                RREADY_WDT = READY_M & RVALID_WDT;
                RREADY_DRAM = 1'b0;
                RREADY_SD = 1'b0;
            end
            3'b110:begin
                master = RID_DRAM[5:4];
                RID_S = RID_DRAM;
                RDATA_S  = RDATA_DRAM;
                RRESP_S  = RRESP_DRAM;
                RLAST_S  = RLAST_DRAM;
                RVALID_S = RVALID_DRAM;
                 
                RREADY_ROM = 1'b0;
                RREADY_IM = 1'b0;
                RREADY_DM = 1'b0;
                RREADY_SC = 1'b0;
                RREADY_WDT = 1'b0;
                RREADY_DRAM = READY_M & RVALID_DRAM;
                RREADY_SD = 1'b0;
            end
            3'b111:begin
                master = RID_SD[5:4];
                RID_S = RID_SD;
                RDATA_S  = RDATA_SD;
                RRESP_S  = RRESP_SD;
                RLAST_S  = RLAST_SD;
                RVALID_S = RVALID_SD;
                 
                RREADY_ROM = 1'b0;
                RREADY_IM = 1'b0;
                RREADY_DM = 1'b0;
                RREADY_SC = 1'b0;
                RREADY_WDT = 1'b0;
                RREADY_DRAM = 1'b0;
                RREADY_SD = READY_M & RVALID_SD;
            end
            default: begin
                master = 2'b00;
                RID_S = `AXI_IDS_BITS'b0;
                RDATA_S  = `AXI_DATA_BITS'b0;
                RRESP_S  = 2'b0;
                RLAST_S  = 1'b0;
                RVALID_S = 1'b0;
                 
                RREADY_ROM = 1'b0;
                RREADY_IM = 1'b0;
                RREADY_DM = 1'b0;
                RREADY_SC = 1'b0;
                RREADY_WDT = 1'b0;
                RREADY_DRAM = 1'b0;
                RREADY_SD = 1'b0;
            end
        endcase
    end





endmodule