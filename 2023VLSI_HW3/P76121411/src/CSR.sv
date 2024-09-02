module CSR (
    input clk,
    input rst,
    input [1:0] state,

    // func
    input [2:0] funct3,
    input [6:0] funct7,

    //source
    input [31:0] rs1,
    input [31:0] imm,
    input [4:0] rs1_addr,

    //CSR addr / enable
    input [11:0] CSR_addr,
    input CSR_write,

    //Regwrite
    input EXEMEM_Regwrite,

    //interrupt
    input interrupt,

    //PC
    input [31:0] EXE_pc,
    input timeout,

    output [31:0] CSR_return_pc,
    output [31:0] CSR_ISR_pc,

    //output data
    output logic[31:0] CSR_rdata,

    //stall
    output logic CSR_stall,
    output logic CSR_control,
    output logic CSR_ret,
    output logic CSR_rst
);
//status
    parameter [4:0] MPP  = 5'd11, 
                    MPIE = 5'd7,  
                    MIE  = 5'd3,  
                    MEIP = 5'd11, 
                    MEIE = 5'd11, 
                    MTIE = 5'd7,
                    MTIP = 5'd7;

    parameter [1:0] PC4 = 2'b00,
                Branch = 2'b01,
                Loaduse = 2'b10;

    parameter [1:0] CSRRW = 2'b01,
                    CSRRS = 2'b10,
                    CSRRC = 2'b11;

    logic [31:0] mstatus;
    logic [31:0] mie;
    logic [31:0] mepc;      // the address that executing before interrupt 
    logic [31:0] mip;       //1 if interrupt pending(wait for cpu to deal with the interrupt)
    logic [31:0] csrtemp;

    logic [31:0] csr, csr_in;
    logic [31:0] rdcycle, rdcycleh;


    logic [31:0] rdinstret, rdinstreth;
    //0 ignore interrupt, 1 enable interrupt
    
    assign CSR_return_pc = mepc;
    assign CSR_ISR_pc = 32'h10000;

    always_ff @( posedge clk )begin
        if (rst) begin
            {rdcycleh, rdcycle} <= 64'b0;
            {rdinstreth, rdinstret} <= 64'b0;
        end 
        else begin
            if (EXEMEM_Regwrite) begin
                {rdcycleh, rdcycle} <= {rdcycleh, rdcycle} + 64'b1;
                if (rdcycle > 32'b1) begin
                    if (state == Branch) {rdinstreth, rdinstret} <= {rdinstreth, rdinstret} - 64'b1;
                    else if (state == Loaduse) {rdinstreth, rdinstret} <= {rdinstreth, rdinstret};
                    else {rdinstreth, rdinstret} <= {rdinstreth, rdinstret} + 64'b1;
                end
            end
        end
    end
// interrupt
    always_comb begin           
        if ( funct3[2] == 1'b1 ) begin
            csrtemp = imm;
        end else begin
            csrtemp = rs1;
        end
    end
    //(3.1)if mstatus.MIE & (interrupt | timeout) => pc go to csrISR_pc in IF, then mip[MEIP] <= 1'b0, pc = pc+4
    assign CSR_control = mstatus[MIE] & interrupt & mip[MEIP] & mie[MEIE];
    assign CSR_rst = timeout;
    //(4.1)give origin pc back to IF
    assign CSR_ret = ((funct3 == 3'b0) & (funct7[4] == 1'b1) & CSR_write)? 1'b1:1'b0;


    always_ff @( posedge clk ) begin
        if (rst) begin
            {mstatus, mip, mie, mepc} <= {128'b0};
        end
        else if ((funct3 == 3'b0) & CSR_write) begin
            if(funct7[4] == 1'b1) begin             //interrupt return
                mstatus[MPP+:2] <= 2'b11;
                mstatus[MPIE]   <= 1'b1;
                mstatus[MIE]    <= mstatus[MPIE];
            end
            else begin                              //(2)WFI, if interrupt the do interrupt, else keep doing origin instruction
                mepc <= EXE_pc + 32'd4;                     //interrupt => pc+4, exception => pc
                mip[MEIP] <= mie[MEIE]? 1'b1:mip[MEIP];     //exter interrupt pending if enable
                mip[MTIP] <= mie[MTIE]? 1'b1:mip[MTIP];     //timer interrupt pending if enable
            end
        end
        else if (interrupt & EXEMEM_Regwrite) begin
            mstatus[MPP+:2] <= mip[MEIP]? 2'b11:mstatus[MPP+:2];
            mstatus[MPIE]   <= mip[MEIP]? mstatus[MIE]:mstatus[MPIE];
            mstatus[MIE]    <= mip[MEIP]? 1'b0:mstatus[MIE];

            mip[MEIP] <= 1'b0;  //start deal with the interrupt
        end
        else if(timeout & EXEMEM_Regwrite) begin                //(3.2b)Time interrupt & exter interrupt's prior before time's interrupt
            mstatus[MPP+:2] <= mip[MTIP]? 2'b11:mstatus[MPP+:2];
            mstatus[MPIE]   <= mip[MTIP]? mstatus[MIE]:mstatus[MPIE];
            mstatus[MIE]    <= mip[MTIP]? 1'b0:mstatus[MIE];

            mip[MTIP] <= 1'b0;  //start deal with the timeout
        end
        else begin
            if(EXEMEM_Regwrite & CSR_write) begin
                case(CSR_addr) 
                    12'h300: begin
                        case (funct3[1:0])
                            CSRRW:begin
                                mstatus[MPP+:2] <= csrtemp[MPP+:2];
                                mstatus[MPIE]   <= csrtemp[MPIE];
                                mstatus[MIE]    <= csrtemp[MIE];
                            end
                            CSRRS:begin
                                mstatus[MPP+:2] <= mstatus[MPP+:2] | csrtemp[MPP+:2];
                                mstatus[MPIE]   <= mstatus[MPIE]   | csrtemp[MPIE];
                                mstatus[MIE]    <= mstatus[MIE]    | csrtemp[MIE];
                            end
                            CSRRC:begin
                                mstatus[MPP+:2] <= mstatus[MPP+:2] & ~csrtemp[MPP+:2];
                                mstatus[MPIE]   <= mstatus[MPIE]   & ~csrtemp[MPIE];
                                mstatus[MIE]    <= mstatus[MIE]    & ~csrtemp[MIE];
                            end
                            default: mstatus <= mstatus;
                        endcase
                    end
                    12'h304: begin                          //need to check//
                        case (funct3[1:0])
                            CSRRW:  begin
                                mie[MEIE] <= csrtemp[MEIE];
                                mie[MTIE] <= csrtemp[MTIE];
                            end 
                            CSRRS:  begin
                                mie[MEIE] <= mie[MEIE] | csrtemp[MEIE];
                                mie[MTIE] <= mie[MTIE] | csrtemp[MTIE];
                            end 
                            CSRRC:  begin
                                mie[MEIE] <= mie[MEIE] & ~csrtemp[MEIE];
                                mie[MTIE] <= mie[MTIE] & ~csrtemp[MTIE];
                            end 
                            default: mie <= mie;
                        endcase
                    end
                    12'h341: begin
                        case (funct3[1:0])
                            CSRRW:  mepc[31:2] <= csrtemp[31:2];
                            CSRRS:  mepc[31:2] <= mepc[31:2] | csrtemp[31:2];
                            CSRRC:  mepc[31:2] <= mepc[31:2] & ~csrtemp[31:2];
                            default: mepc <= mepc;
                        endcase
                    end

                endcase
            end
        end
    end

    always_comb begin       //give the value out to EXE_ALUout (rd<= csr)
        case (CSR_addr)
            12'h300: CSR_rdata = mstatus;
            12'h304: CSR_rdata = mie;
            12'h305: CSR_rdata = 32'h10000;      //mtvec
            12'h341: CSR_rdata = mepc;
            12'h344: CSR_rdata = mip;
            12'hb00: CSR_rdata = rdcycle;        //Machine mode
            12'hb02: CSR_rdata = rdinstret;
            12'hb80: CSR_rdata = rdcycleh;
            12'hb82: CSR_rdata = rdinstreth;
            default: CSR_rdata = 32'b0;
        endcase
    end

    always_ff @(posedge clk ) begin
        if(rst) begin
            CSR_stall <= 1'b0;
        end
        else if(EXEMEM_Regwrite) begin
            if((funct7[4] == 1'b0)&(funct3==3'b0)&CSR_write) begin    //WFI, if mie can handle then stall 
                CSR_stall <= mie[MEIE];
            end
        end
        else if(CSR_control) begin                                  //Start dealing interrupt
            CSR_stall <= 1'b0;
        end
    end

endmodule
