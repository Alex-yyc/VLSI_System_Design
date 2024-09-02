module ALUCtrl (
    input [2:0] ALUOP ,
    input [2:0] funct3 ,
    input [6:0] funct7 ,
    input [11:0] CSRimm ,

    output reg [4:0] ALUCtrl
);
    localparam [2:0]    R_type    = 3'b000 ,  //0 
                        I_type    = 3'b001 ,  //1
                        ADD_type  = 3'b010 ,  //2
                        JALR_type = 3'b011 ,  //3
                        B_type    = 3'b100 ,  //4
                        LUI_type  = 3'b101 ,  //5
                        CSR_type  = 3'b110 ;  //6

    localparam [4:0]    ALU_ADD = 5'b00000 ,  //0X00 
                        ALU_SUB = 5'b00001 ,  //0X01
                        ALU_SLL = 5'b00010 ,  //0x02
                        ALU_SLT = 5'b00011 ,  //0x03
                        ALU_SLTU= 5'b00100 ,  //0x04
                        ALU_XOR = 5'b00101 ,  //0x05
                        ALU_SRL = 5'b00110 ,  //0x06
                        ALU_SRA = 5'b00111 ,  //0x07
                        ALU_OR  = 5'b01000 ,  //0x08
                        ALU_AND = 5'b01001 ,  //0x09
                        ALU_JALR= 5'b01010 ,  //0x0A
                        ALU_BEQ = 5'b01011 ,  //0x0B
                        ALU_BNE = 5'b01100 ,  //0x0C
                        ALU_BLT = 5'b01101 ,  //0x0D
                        ALU_BGE = 5'b01110 ,  //0x0E
                        ALU_BLTU= 5'b01111 ,  //0x0F
                        ALU_BGEU= 5'b10000 ,  //0x10
                        ALU_IMM = 5'b10001 ,  //0x11
                        ALU_RDINSTRETH = 5'b10010 ,  //0x12
                        ALU_RDINSTRET  = 5'b10011 ,  //0x13
                        ALU_RDCYCLEH   = 5'b10100 ,  //0x14
                        ALU_RDCYCLE    = 5'b10101 ,  //0x15
                        ALU_MUL        = 5'b10110 ,  //0x16
                        ALU_MULH       = 5'b10111 ,  //0x17
                        ALU_MULHSU     = 5'b11000 ,  //0x18
                        ALU_MULHU      = 5'b11001 ;  //0x18

    always_comb begin 
        case (ALUOP)
            R_type : begin
                case (funct3)
                    3'b000 : begin
                        if ( funct7 == 7'b0 ) 
                            ALUCtrl = ALU_ADD ;
                        else if(funct7 == 7'b0000001) 
                            ALUCtrl = ALU_MUL;
                        else 
                            ALUCtrl = ALU_SUB ;    
                    end
                    3'b001 : begin 
                        if(funct7 == 7'b0000001) 
                            ALUCtrl = ALU_MULH;
                        else 
                            ALUCtrl = ALU_SLL ;
                    end
                    3'b010 :begin 
                        if(funct7 == 7'b0000001) 
                            ALUCtrl = ALU_MULHSU;
                        else 
                            ALUCtrl = ALU_SLT ;
                    end 
                    3'b011 : begin 
                        if(funct7 == 7'b0000001) 
                            ALUCtrl = ALU_MULHU;
                        else 
                            ALUCtrl = ALU_SLTU ;
                    end 
                    3'b100 : ALUCtrl = ALU_XOR ;
                    3'b101 : begin
                        if ( funct7 == 7'b0 ) ALUCtrl = ALU_SRL ;
                        else ALUCtrl = ALU_SRA ; 
                    end
                    3'b110 : ALUCtrl = ALU_OR ;
                    3'b111 : ALUCtrl = ALU_AND ;
                endcase
            end

            I_type : begin
                case (funct3)
                    3'b000 : ALUCtrl = ALU_ADD ;
                    3'b001 : ALUCtrl = ALU_SLL ;  //why can't see LW?
                    3'b010 : ALUCtrl = ALU_SLT ;
                    3'b011 : ALUCtrl = ALU_SLTU;
                    3'b100 : ALUCtrl = ALU_XOR ;
                    3'b101 : begin
                        if( funct7 == 7'b0 ) ALUCtrl = ALU_SRL ;
                        else ALUCtrl = ALU_SRA ;
                    end
                    3'b110 : ALUCtrl = ALU_OR ;
                    3'b111 : ALUCtrl = ALU_AND ;
                endcase
            end

            ADD_type : begin
                ALUCtrl = ALU_ADD ;
            end

            JALR_type : begin
                ALUCtrl = ALU_JALR ;
            end

            B_type : begin
                case (funct3)
                    3'b000 : ALUCtrl = ALU_BEQ ;
                    3'b001 : ALUCtrl = ALU_BNE ;
                    3'b100 : ALUCtrl = ALU_BLT ;
                    3'b101 : ALUCtrl = ALU_BGE ;
                    3'b110 : ALUCtrl = ALU_BLTU ; 
                    default: ALUCtrl = ALU_BGEU ; // 3'b111
                endcase
            end

            CSR_type : begin
                case (CSRimm)
                    12'b110010000010 : ALUCtrl = ALU_RDINSTRETH ;
                    12'b110000000010 : ALUCtrl = ALU_RDINSTRET ;
                    12'b110010000000 : ALUCtrl = ALU_RDCYCLEH ;
                    default: ALUCtrl = ALU_RDCYCLE ;
                    
                endcase
            end

            default: begin  //LUI_type
            ALUCtrl = ALU_IMM ;
            end

        endcase
    end


endmodule