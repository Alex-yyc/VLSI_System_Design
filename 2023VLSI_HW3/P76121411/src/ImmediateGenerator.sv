module ImmediateGenerator (
    input [2:0] Imm_Type,
    input [31:0] Instraction_out,

    output reg [31:0] imm
);
    localparam [2:0] I_Imm = 3'b000,
                     S_Imm = 3'b001,
                     B_Imm = 3'b010,
                     U_Imm = 3'b011,
                     J_Imm = 3'b100,
                     C_Imm = 3'b101;
    always_comb begin 
        case (Imm_Type)
            I_Imm :     imm = { {20{Instraction_out[31]}} , Instraction_out[31:20] };
            S_Imm :     imm = { {20{Instraction_out[31]}} , Instraction_out[31:25] , Instraction_out[11:7] };
            B_Imm :  
                        imm = { 
                            {19{Instraction_out[31]}} , 
                            Instraction_out[31] , 
                            Instraction_out[7] , 
                            Instraction_out[30:25] , 
                            Instraction_out[11:8] , 
                            1'b0
                            };
            U_Imm :     imm = { Instraction_out[31:12] , 12'b0 };
            // J_Imm:
            //             imm = {{11{Instraction_out[31]}}, Instraction_out[31], Instraction_out[19:12], Instraction_out[20], Instraction_out[30:21], 1'b0};
            C_Imm:
                imm = {27'b0, Instraction_out[19:15]};
            default: 
                imm = {{11{Instraction_out[31]}}, Instraction_out[31], Instraction_out[19:12], Instraction_out[20], Instraction_out[30:21], 1'b0};
        endcase
    end

endmodule