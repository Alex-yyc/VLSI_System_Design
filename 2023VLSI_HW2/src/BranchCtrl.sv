module BranchCtrl (
    input [1:0] ID_branch , 
    input Zeroflag ,

    output reg [1:0] BranchCtrl
);
    localparam [1:0]    None_branch = 2'b00,
                        JALR_branch = 2'b01,
                        B_branch    = 2'b10,
                        J_branch    = 2'b11;
    localparam [1:0]    PC4 = 2'b00,
                        PCIMM = 2'b01,
                        IMMRS1 = 2'b10 ;

    always_comb begin
        case (ID_branch)
            JALR_branch : BranchCtrl = IMMRS1 ;
            B_branch    : begin
                if(Zeroflag) 
                    BranchCtrl = PCIMM;
                else
                    BranchCtrl = PC4;
            end  
            J_branch    : BranchCtrl = PCIMM  ;
            default: BranchCtrl = PC4;
        endcase
    end
endmodule