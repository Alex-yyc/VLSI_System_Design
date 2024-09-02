`include "../../include/AXI_define.svh"

module Decoder (
    input VALID,
    input [`AXI_ADDR_BITS-1:0] ADDR,
    
    // VALID
    output logic VALID_ROM,
    output logic VALID_IM,
    output logic VALID_DM,
    output logic VALID_SC,
    output logic VALID_WDT,
    output logic VALID_DRAM,
    output logic VALID_SD,
    
    // READY
    input READY_ROM,
    input READY_IM,
    input READY_DM,
    input READY_SC,
    input READY_WDT,
    input READY_DRAM,
    input READY_SD,
    
    output logic READY_S
);

    always_comb begin
        if (ADDR[31:16]==16'h0000 && ADDR[15:0]<= 16'h1FFF) begin // ROM
            VALID_ROM   = VALID; 
            VALID_IM    = 1'b0;
            VALID_DM    = 1'b0;
            VALID_SC    = 1'b0;
            VALID_WDT   = 1'b0;
            VALID_DRAM  = 1'b0;
            VALID_SD    = 1'b0;

            READY_S = (VALID) ? READY_ROM : 1'b0;
        end
        else if (ADDR[31:16]==16'h0001) begin // IM
            VALID_ROM   = 1'b0; 
            VALID_IM    = VALID;
            VALID_DM    = 1'b0;
            VALID_SC    = 1'b0;
            VALID_WDT   = 1'b0;
            VALID_DRAM  = 1'b0;
            VALID_SD    = 1'b0;

            READY_S = (VALID) ? READY_IM : 1'b0;
        end
        else if (ADDR[31:16]==16'h0002) begin // DM
            VALID_ROM   = 1'b0; 
            VALID_IM    = 1'b0;
            VALID_DM    = VALID;
            VALID_SC    = 1'b0;
            VALID_WDT   = 1'b0;
            VALID_DRAM  = 1'b0;
            VALID_SD    = 1'b0;

            READY_S = (VALID) ? READY_DM : 1'b0;
        end
        else if (ADDR[31:16]==16'h1000 && ADDR[15:0]<=16'h03FF) begin // sensor_ctrl
            VALID_ROM   = 1'b0; 
            VALID_IM    = 1'b0;
            VALID_DM    = 1'b0;
            VALID_SC    = VALID;
            VALID_WDT   = 1'b0;
            VALID_DRAM  = 1'b0;
            VALID_SD    = 1'b0;

            READY_S = (VALID) ? READY_SC : 1'b0;
        end
        else if (ADDR[31:16]==16'h1001 && ADDR[15:0]<=16'h03FF) begin // WDT
            VALID_ROM   = 1'b0; 
            VALID_IM    = 1'b0;
            VALID_DM    = 1'b0;
            VALID_SC    = 1'b0;
            VALID_WDT   = VALID;
            VALID_DRAM  = 1'b0;
            VALID_SD    = 1'b0;

            READY_S = (VALID) ? READY_WDT : 1'b0;
        end
        else if (ADDR[31:16]>=16'h2000 && ADDR[31:16]<=16'h201F) begin // DRAM
            VALID_ROM   = 1'b0; 
            VALID_IM    = 1'b0;
            VALID_DM    = 1'b0;
            VALID_SC    = 1'b0;
            VALID_WDT   = 1'b0;
            VALID_DRAM  = VALID;
            VALID_SD    = 1'b0;

            READY_S = (VALID) ? READY_DRAM : 1'b0;
        end
        else begin // Default
            VALID_ROM   = 1'b0; 
            VALID_IM    = 1'b0;
            VALID_DM    = 1'b0;
            VALID_SC    = 1'b0;
            VALID_WDT   = 1'b0;
            VALID_DRAM  = 1'b0;
            VALID_SD    = VALID;

            READY_S = (VALID) ? READY_SD : 1'b0;
        end
    end




endmodule