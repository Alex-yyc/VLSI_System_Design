`include "../../include/AXI_define.svh"

module Decoder (
    input VALID,
    input [`AXI_ADDR_BITS-1:0] ADDR,

    output logic VALID_S0,
    output logic VALID_S1,
    output logic VALID_SDEFAULT,
    
    input READY_S0,
    input READY_S1,
    input READY_SDEFAULT,

    output logic READY_S
);
    always_comb begin
        //Slave 1: 0x0000_0000 – 0x0000_ffff
        //Slave 2: 0x0001_0000 – 0x0001_ffff
        //Slave D: 0x0002_0000 – 0xffff_ffff
        //take high addr to check which slave
        case (ADDR[31:16])
            16'h0000:begin  //slave1
               VALID_SDEFAULT = 1'b0;
               VALID_S1 = 1'b0;
               VALID_S0 = VALID;
               //READY_S  = READY_S0;
               READY_S = VALID ? READY_S0 : 1'b1;
            end 
            16'h0001:begin  //slave2
                VALID_SDEFAULT = 1'b0;
                VALID_S1 = VALID;
                VALID_S0 = 1'b0;
                //READY_S  = READY_S1;
                READY_S = VALID ? READY_S1 : 1'b1;
            end
            default:begin  //slaveD
                VALID_SDEFAULT = VALID;
                VALID_S1 = 1'b0;
                VALID_S0 = 1'b0;
                //READY_S  = READY_SDEFAULT;
                READY_S = VALID ? READY_SDEFAULT : 1'b1;
            end
        endcase
    end
endmodule