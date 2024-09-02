module ALU (
    input [31:0] rs1 , 
    input [31:0] rs2 ,
    input [4:0]  ALUCtrl ,

    output reg Zeroflag ,
    output reg [31:0] ALU_out
);
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
                        ALU_MUL      = 5'b10010 ,  //0x12
                        ALU_MULH     = 5'b10011 ,  //0x13
                        ALU_MULHSU   = 5'b10100 ,  //0x14
                        ALU_MULHU    = 5'b10101 ,  //0x15
                        ALU_CsrRW    = 5'b10110 ,  //0x16
                        ALU_CsrRS    = 5'b10111 ,  //0x17
                        ALU_CsrRC    = 5'b11000 ,  //0x18
                        ALU_CsrRWI   = 5'b11001 ,  //0x18
                        ALU_CsrRSI   = 5'b11010 ,
                        ALU_CsrRCI   = 5'b11011 ;

    wire signed [31:0] signed_rs1;
    wire signed [31:0] signed_rs2;
    assign signed_rs1 = rs1;
    assign signed_rs2 = rs2;

    wire [31:0] sum;
    reg [63:0] mul;
    assign sum = rs1 + rs2;

    always_comb begin
        case (ALUCtrl)
            ALU_ADD : ALU_out = sum ;
            ALU_SUB : ALU_out = rs1 - rs2 ;
            ALU_SLL : ALU_out = rs1 << rs2[4:0] ;
            ALU_SLT : ALU_out = ( signed_rs1 < signed_rs2 ) ? 32'b1 : 32'b0 ;
            ALU_SLTU: ALU_out =  rs1 < rs2  ? 32'b1 : 32'b0 ;
            ALU_XOR : ALU_out = rs1 ^ rs2 ;
            ALU_SRL : ALU_out = rs1 >> rs2[4:0] ;
            ALU_SRA : ALU_out = signed_rs1 >>> rs2[4:0] ;
            ALU_OR  : ALU_out = rs1 | rs2 ;
            ALU_AND : ALU_out = rs1 & rs2 ;
            ALU_JALR: ALU_out = { sum[31:1] , 1'b0 } ;
            ALU_IMM : ALU_out = rs2 ;
            ALU_MUL        : begin
                mul = rs1 * rs2;
                ALU_out = mul[31:0];
            end
            ALU_MULH       : begin
                mul = signed_rs1 * signed_rs2;
                ALU_out = mul[63:32];
            end
            ALU_MULHSU     : begin
                mul = signed_rs1 * $signed({1'b0,rs2});
                ALU_out = mul[63:32];
            end
            ALU_MULHU      : begin
                mul = rs1 * rs2;
                ALU_out = mul[63:32];
            end
            default:  ALU_out = 32'b0;  //B-type
        endcase
    end

    //determine Zeroflag
    always_comb begin 
        case (ALUCtrl)
            ALU_BEQ : Zeroflag = ( rs1 == rs2 ) ? 1'b1 : 1'b0 ; 
            ALU_BNE : Zeroflag = ( rs1 != rs2 ) ? 1'b1 : 1'b0 ;
            ALU_BLT : Zeroflag = ( signed_rs1 < signed_rs2 ) ? 1'b1 : 1'b0 ;
            ALU_BGE : Zeroflag = ( signed_rs1 >= signed_rs2 ) ? 1'b1 : 1'b0 ;
            ALU_BLTU: Zeroflag = ( rs1 < rs2 ) ? 1'b1 : 1'b0 ;
            ALU_BGEU: Zeroflag = ( rs1 >= rs2 ) ? 1'b1 : 1'b0 ;
            default:    Zeroflag = 1'b0;
        endcase        
    end

    

endmodule