`include "../../include/AXI_define.svh"
module WR (
    input clk,    // Clock
    input rst,  // Asynchronous reset active high

    // master 1 receive
    output logic [`AXI_ID_BITS-1:0] BID_M1,
    output logic [1:0] BRESP_M1,
    output logic BVALID_M1,
    // master 1 send
    input BREADY_M1,

    // slave 0 send
    input [`AXI_IDS_BITS-1:0] BID_ROM,
    input [1:0] BRESP_ROM,
    input BVALID_ROM,
    // slave 0 receive
    output logic BREADY_ROM,

    // slave 1 send
    input [`AXI_IDS_BITS-1:0] BID_IM,
    input [1:0] BRESP_IM,
    input BVALID_IM,
    // slave 1 receive
    output logic BREADY_IM,

    // slave 2 send
    input [`AXI_IDS_BITS-1:0] BID_DM,
    input [1:0] BRESP_DM,
    input BVALID_DM,
    // slave 2 receive
    output logic BREADY_DM,

    // slave 3 send
    input [`AXI_IDS_BITS-1:0] BID_SC,
    input [1:0] BRESP_SC,
    input BVALID_SC,
    // slave 3 receive
    output logic BREADY_SC,

    // slave 4 send
    input [`AXI_IDS_BITS-1:0] BID_WDT,
    input [1:0] BRESP_WDT,
    input BVALID_WDT,
    // slave 4 receive
    output logic BREADY_WDT,
    
    // slave 5 send
    input [`AXI_IDS_BITS-1:0] BID_DRAM,
    input [1:0] BRESP_DRAM,
    input BVALID_DRAM,
    // slave 5 receive
    output logic BREADY_DRAM,

    // slave default send
    input [`AXI_IDS_BITS-1:0] BID_SD,
    input [1:0] BRESP_SD,
    input BVALID_SD,
    // slave 0 receive
    output logic BREADY_SD
);
//LOGIC
    logic [6:0] slave;
    logic [1:0] master;

    logic READY;
    logic [`AXI_ID_BITS-1:0] BID_M;
    logic [1:0] BRESP_M;
    logic BVALID_M;

    logic lock_ROM, lock_IM, lock_DM, lock_SC, lock_WDT, lock_DRAM, lock_SD;

    assign BID_M1 = BID_M;
    assign BRESP_M1 = BRESP_M;

    always_ff @( posedge clk ) begin
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
            lock_ROM <= (lock_ROM & READY)?  1'b0 : (BVALID_ROM & ~BVALID_IM & ~BVALID_DM & ~BVALID_SC & ~BVALID_WDT & ~BVALID_DRAM & ~BVALID_SD & ~READY)? 1'b1: lock_ROM;
            lock_IM <= (lock_IM & READY)?    1'b0 : (~lock_ROM & BVALID_IM & ~BVALID_DM & ~BVALID_SC & ~BVALID_WDT & ~BVALID_DRAM & ~BVALID_SD & ~READY)? 1'b1: lock_IM;
            lock_DM <= (lock_DM & READY)?    1'b0 : (~lock_ROM & ~lock_IM & BVALID_DM & ~BVALID_SC & ~BVALID_WDT & ~BVALID_DRAM & ~BVALID_SD & ~READY)? 1'b1: lock_DM;
            lock_SC <= (lock_SC & READY)?    1'b0 : (~lock_ROM & ~lock_IM & ~lock_DM & BVALID_SC & ~BVALID_WDT & ~BVALID_DRAM & ~BVALID_SD & ~READY)? 1'b1: lock_SC;
            lock_WDT <= (lock_WDT & READY)?  1'b0 : (~lock_ROM & ~lock_IM & ~lock_DM & ~lock_SC & BVALID_WDT & ~BVALID_DRAM & ~BVALID_SD & ~READY)? 1'b1: lock_WDT;
            lock_DRAM <= (lock_DRAM & READY)?1'b0 : (~lock_ROM & ~lock_IM & ~lock_DM & ~lock_SC & ~lock_WDT & BVALID_DRAM & ~BVALID_SD & ~READY)? 1'b1: lock_DRAM;
            lock_SD <= (lock_SD & READY)?    1'b0 : (~lock_ROM & ~lock_IM & ~lock_DM & ~lock_SC & ~lock_WDT & ~lock_DRAM & BVALID_SD & ~READY)? 1'b1: lock_SD;
        end
    end
    
    always_comb begin
        if((BVALID_SD & ~(lock_ROM|lock_IM|lock_DM|lock_SC|lock_WDT|lock_DRAM))|lock_SD)
            slave = 7'b1000000;
        else if((BVALID_DRAM & ~(lock_ROM|lock_IM|lock_DM|lock_SC|lock_WDT))|lock_DRAM)
            slave = 7'b0100000;
        else if((BVALID_WDT & ~(lock_ROM|lock_IM|lock_DM|lock_SC))|lock_WDT)
            slave = 7'b0010000;
        else if((BVALID_SC & ~(lock_ROM|lock_IM|lock_DM))|lock_SC)
            slave = 7'b0001000;
        else if((BVALID_DM & ~(lock_ROM|lock_IM)) | lock_DM)
            slave = 7'b0000100;
        else if((BVALID_IM & ~lock_ROM)|lock_IM)
            slave = 7'b0000010;
        else if(BVALID_ROM | lock_ROM)
            slave = 7'b0000001;
        else
            slave = 7'b0000000;
    end
    // always_comb begin
    //     if(BVALID_SD)
    //         slave = 7'b1000000;
    //     else if(BVALID_DRAM)
    //         slave = 7'b0100000;
    //     else if(BVALID_WDT)
    //         slave = 7'b0010000;
    //     else if(BVALID_SC)
    //         slave = 7'b0001000;
    //     else if(BVALID_DM)
    //         slave = 7'b0000100;
    //     else if(BVALID_IM)
    //         slave = 7'b0000010;
    //     else if(BVALID_ROM)
    //         slave = 7'b0000001;
    //     else
    //         slave = 7'b0000000;
    // end

    
    always_comb begin
        case(master)
            2'b10: begin
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
            7'b0000001: begin
            master = BID_ROM[5:4];
            BID_M = BID_ROM[`AXI_ID_BITS-1:0];
            BRESP_M = BRESP_ROM;
            BVALID_M = BVALID_ROM;
            
            BREADY_ROM = READY & BVALID_ROM;
            BREADY_IM = 1'b0;
            BREADY_DM = 1'b0;
            BREADY_SC = 1'b0;
            BREADY_WDT = 1'b0;
            BREADY_DRAM = 1'b0;
            BREADY_SD = 1'b0;
            end
            7'b0000010: begin
                master = BID_IM[5:4];
                BID_M = BID_IM[`AXI_ID_BITS-1:0];
                BRESP_M = BRESP_IM;
                BVALID_M = BVALID_IM;

                BREADY_ROM = 1'b0;
                BREADY_IM = READY & BVALID_IM;
                BREADY_DM = 1'b0;
                BREADY_SC = 1'b0;
                BREADY_WDT = 1'b0;
                BREADY_DRAM = 1'b0;
                BREADY_SD = 1'b0;
            end
            7'b0000100: begin
                master = BID_DM[5:4];
                BID_M = BID_DM[`AXI_ID_BITS-1:0];
                BRESP_M = BRESP_DM;
                BVALID_M = BVALID_DM;

                BREADY_ROM = 1'b0;
                BREADY_IM = 1'b0;
                BREADY_DM = READY & BVALID_DM;
                BREADY_SC = 1'b0;
                BREADY_WDT = 1'b0;
                BREADY_DRAM = 1'b0;
                BREADY_SD = 1'b0;
            end
            7'b0001000: begin
                master = BID_SC[5:4];
                BID_M = BID_SC[`AXI_ID_BITS-1:0];
                BRESP_M = BRESP_SC;
                BVALID_M = BVALID_SC;

                BREADY_ROM = 1'b0;
                BREADY_IM = 1'b0;
                BREADY_DM = 1'b0;
                BREADY_SC = READY & BVALID_SC;
                BREADY_WDT = 1'b0;
                BREADY_DRAM = 1'b0;
                BREADY_SD = 1'b0;
            end
            7'b0010000: begin
                master = BID_WDT[5:4];
                BID_M = BID_WDT[`AXI_ID_BITS-1:0];
                BRESP_M = BRESP_WDT;
                BVALID_M = BVALID_WDT;

                BREADY_ROM = 1'b0;
                BREADY_IM = 1'b0;
                BREADY_DM = 1'b0;
                BREADY_SC = 1'b0;
                BREADY_WDT = READY & BVALID_WDT;
                BREADY_DRAM = 1'b0;
                BREADY_SD = 1'b0;
            end
            7'b0100000: begin
                master = BID_DRAM[5:4];
                BID_M = BID_DRAM[`AXI_ID_BITS-1:0];
                BRESP_M = BRESP_DRAM;
                BVALID_M = BVALID_DRAM;

                BREADY_ROM = 1'b0;
                BREADY_IM = 1'b0;
                BREADY_DM = 1'b0;
                BREADY_SC = 1'b0;
                BREADY_WDT = 1'b0; 
                BREADY_DRAM = READY & BVALID_DRAM;
                BREADY_SD = 1'b0;
            end
            7'b1000000: begin
                master = BID_SD[5:4];
                BID_M = BID_SD[`AXI_ID_BITS-1:0];
                BRESP_M = BRESP_SD;
                BVALID_M = BVALID_SD;

                BREADY_ROM = 1'b0;
                BREADY_IM = 1'b0;
                BREADY_DM = 1'b0;
                BREADY_SC = 1'b0;
                BREADY_WDT = 1'b0; 
                BREADY_DRAM = 1'b0;
                BREADY_SD = READY & BVALID_SD;
            end
            default:begin
                master = 2'b0;
                BID_M = `AXI_ID_BITS'b0;
                BRESP_M = 2'b0;
                BVALID_M = 1'b0;

                BREADY_ROM = 1'b0;
                BREADY_IM = 1'b0;
                BREADY_DM = 1'b0;
                BREADY_SC = 1'b0;
                BREADY_WDT = 1'b0; 
                BREADY_DRAM = 1'b0;
                BREADY_SD = 1'b0;
            end 
        endcase
        
    end

endmodule