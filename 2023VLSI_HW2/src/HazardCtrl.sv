module HazardCtrl (
    input [1:0] BranchCtrl ,
    input ID_MemRead ,
    input [4:0] ID_rd_addr ,
    input [4:0] rs1_addr ,
    input [4:0] rs2_addr ,

    output reg Instraction_flush ,
    output reg CtrlSignalFlush ,
    output reg IFID_RegWrite ,
    output reg PC_Write,
    output reg [1:0] CSR_branch_type,

    input IM_stall,
    output reg IDEXE_RegWrite,
    input DM_stall,
    output reg EXEMEM_RegWrite,
    output reg MEMWB_RegWrite
);
    localparam [1:0]    PC4 = 2'b00 ,
                        PCIMM = 2'b01 ,
                        IMMRS1 = 2'b10 ;
    localparam [1:0]    BR_type = 2'b00,
                        LU_type = 2'b01,
                        NORMAL_type = 2'b10,
                        IMDM_type = 2'b11;


    always_comb begin
        if (IM_stall | DM_stall) begin
            Instraction_flush      = 1'b0;
            CtrlSignalFlush = 1'b0;
            IFID_RegWrite   = 1'b0;
            PC_Write         = 1'b0;
            IDEXE_RegWrite  = 1'b0;
            EXEMEM_RegWrite = 1'b0;
            MEMWB_RegWrite  = 1'b0;
            CSR_branch_type         = IMDM_type;
        end else if ( BranchCtrl != PC4 ) begin
            Instraction_flush   = 1'b1;
            CtrlSignalFlush     = 1'b1;
            IFID_RegWrite       = 1'b1; 
            PC_Write            = 1'b1;
            IDEXE_RegWrite  = 1'b1;
            EXEMEM_RegWrite = 1'b1;
            MEMWB_RegWrite  = 1'b1;
            CSR_branch_type         = BR_type;
        end
        else if ( ID_MemRead && ( (ID_rd_addr == rs1_addr) || (ID_rd_addr == rs2_addr) )) begin
            Instraction_flush   = 1'b0;
            CtrlSignalFlush     = 1'b1;
            IFID_RegWrite       = 1'b0;
            PC_Write            = 1'b0;
            IDEXE_RegWrite  = 1'b1;
            EXEMEM_RegWrite = 1'b1;
            MEMWB_RegWrite  = 1'b1;
            CSR_branch_type         = LU_type;    
        end else begin
            Instraction_flush   = 1'b0;
            CtrlSignalFlush     = 1'b0;
            IFID_RegWrite       = 1'b1;
            PC_Write            = 1'b1;
            IDEXE_RegWrite  = 1'b1;
            EXEMEM_RegWrite = 1'b1;
            MEMWB_RegWrite  = 1'b1;
            CSR_branch_type         = NORMAL_type;
        end 
    end
endmodule