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

    input IM_stall,
    output reg IDEXE_RegWrite,
    input DM_stall,
    output reg EXEMEM_RegWrite,
    output reg MEMWB_RegWrite,

    //CSR
    input CSR_stall,
    input CSR_control,
    input CSR_ret
);

    localparam [1:0]    BR_type = 2'b00,
                        LU_type = 2'b01,
                        NORMAL_type = 2'b10,
                        IMDM_type = 2'b11;

    localparam [1:0]    PC4 = 2'b00 ,
                        PCIMM = 2'b01 ,
                        IMMRS1 = 2'b10 ;

    // logic loaduse_hazard, control_hazard;

    // assign loaduse_hazard = ( ID_MemRead && ( (ID_rd_addr == rs1_addr) || (ID_rd_addr == rs2_addr) ) ) ? 1'b1 : 1'b0;
    // assign control_hazard = ( BranchCtrl != PC4 ) ? 1'b1 : 1'b0;

    // assign Instraction_flush = ~(IM_stall | DM_stall | CSR_stall) & (control_hazard | CSR_control | CSR_ret);
    // assign CtrlSignalFlush = ~(IM_stall | DM_stall | CSR_stall) & (loaduse_hazard | control_hazard | CSR_control | CSR_ret);
    // assign IFID_RegWrite = ~(IM_stall | DM_stall | CSR_stall | loaduse_hazard);
    // assign PC_Write = ~(IM_stall | DM_stall | CSR_stall | loaduse_hazard);
    // assign IDEXE_RegWrite = ~(IM_stall | DM_stall | CSR_stall);
    // assign EXEMEM_RegWrite = ~(IM_stall | DM_stall | CSR_stall);
    // assign MEMWB_RegWrite =  ~(IM_stall | DM_stall | CSR_stall);

    always_comb begin
        if (IM_stall | DM_stall | CSR_stall) begin
            Instraction_flush = 1'b0;
            IFID_RegWrite = 1'b0;
            PC_Write = 1'b0;
            CtrlSignalFlush = 1'b0;
            IDEXE_RegWrite = 1'b0;
            EXEMEM_RegWrite = 1'b0;
            MEMWB_RegWrite = 1'b0;
        end
        else if (BranchCtrl!=PC4|CSR_control|CSR_ret) begin
            Instraction_flush = 1'b1;
            IFID_RegWrite = 1'b1;
            PC_Write = 1'b1;
            CtrlSignalFlush = 1'b1;
            IDEXE_RegWrite = 1'b1;
            EXEMEM_RegWrite = 1'b1;
            MEMWB_RegWrite = 1'b1;
        end
        else if (ID_MemRead && ((ID_rd_addr==rs1_addr)||(ID_rd_addr==rs2_addr))) begin
            PC_Write = 1'b0;
            IFID_RegWrite = 1'b0;
            Instraction_flush = 1'b0;
            CtrlSignalFlush = 1'b1;
            IDEXE_RegWrite = 1'b1;
            EXEMEM_RegWrite = 1'b1;
            MEMWB_RegWrite = 1'b1;
        end
        else begin
            PC_Write = 1'b1;
            IFID_RegWrite = 1'b1;
            Instraction_flush = 1'b0;
            CtrlSignalFlush = 1'b0;
            IDEXE_RegWrite = 1'b1;
            EXEMEM_RegWrite = 1'b1;
            MEMWB_RegWrite = 1'b1;
        end
    end
    
endmodule