`include "define.sv"

module alu #(
    parameter   DATA_WIDTH = 32
)(
    input   logic   [DATA_WIDTH -1:0]   ALUop1,  // input data 1
    input   logic   [DATA_WIDTH -1:0]   ALUop2,  // input data 2
    input   logic   [4:0]               ALUCtrl, //decides which instruction to do changed it to be 4 bits to implement more instructions
    output  logic   [DATA_WIDTH -1:0]   SUM, //outputs the output
    output  logic                       EQ //gives signals to pc counter to branch or not to branch
);
 
logic signed [DATA_WIDTH -1:0] signed_op1;
logic signed [DATA_WIDTH -1:0] signed_op2;
assign signed_op1 = ALUop1;
assign signed_op2 = ALUop2;

always_comb begin
    SUM = 0;
    EQ =  0;
        
    case (ALUCtrl)
        `ALU_ADD:    SUM = ALUop1 + ALUop2;                     // ADD
        `ALU_SUB:    SUM = ALUop1 - ALUop2;                     // SUB
        `ALU_XOR:    SUM = ALUop1 ^ ALUop2;                     // XOR
        `ALU_OR:     SUM = ALUop1 | ALUop2;                     // OR
        `ALU_AND:    SUM = ALUop1 & ALUop2;                     // AND
        `ALU_LSL:    SUM = ALUop1 << ALUop2;                    // sll      I think this should work based on google
        `ALU_LSR:    SUM = ALUop1 >> ALUop2;                    // srl
        `ALU_ASR:    SUM = signed_op1 >>> signed_op2;                   // sra
        `ALU_SLT:    SUM = (signed_op1 < signed_op2) ? 1 : 0;   // slt     singed
        `ALU_SLTU:   SUM = (ALUop1 < ALUop2) ? 1 : 0;           // sltu    unsinged
        `ALU_LUI:    SUM = ALUop2;
        `ALU_BEQ: 
            if(ALUop1 == ALUop2)                       // beq
                EQ = 1'b1;
            else
                EQ = 1'b0;
        `ALU_BNE:    
            if(ALUop1 != ALUop2)                    // bne
                EQ = 1'b1;
            else
                EQ = 1'b0;
        `ALU_BLT: 
            if(signed_op1 < signed_op2)                //blt     signed
                EQ = 1'b1;
            else
                EQ = 1'b0;
        `ALU_BGE: 
            if(signed_op1 >= signed_op2)               //bge
                EQ = 1'b1;
            else
                EQ = 1'b0;
        `ALU_BLTU: 
            if(ALUop1 < ALUop2)                        //bltu    unsigned
                EQ = 1'b1;
            else
                EQ = 1'b0;
        `ALU_BGEU: 
            if(ALUop1 >= ALUop2)                       //bgeu
                EQ = 1'b1;
            else
                EQ = 1'b0;
        default:  SUM = 0;
    endcase
end
endmodule
