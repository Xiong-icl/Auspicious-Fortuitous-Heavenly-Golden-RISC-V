//Defining code words to simplify design

//Defining type instructions
`define R_TYPE              7'b0110011
`define I_TYPE              7'b0010011
`define S_TYPE              7'b0100011
`define B_TYPE              7'b1100011
`define J_TYPE              7'b1101111
`define IJ_TYPE             7'b1100111
`define U_TYPE              7'b0110111
`define AUI_TYPE            7'b0010111
`define LOAD_TYPE           7'b0000011

//Defining ALU code
`define ALU_ADD      5'b00000
`define ALU_SUB      5'b00001
`define ALU_AND      5'b00010
`define ALU_OR       5'b00011
`define ALU_XOR      5'b00100
`define ALU_LSL      5'b00101
`define ALU_LSR      5'b00110
`define ALU_ASR      5'b00111
`define ALU_SLT      5'b01000
`define ALU_SLTU     5'b01001
`define ALU_LUI      5'b01010
`define ALU_BEQ      5'b01011
`define ALU_BNE      5'b01100
`define ALU_BLT      5'b01101
`define ALU_BGE      5'b01110
`define ALU_BLTU     5'b01111
`define ALU_BGEU     5'b10000

//Defining Sign Extend code
`define SIGN_EXTEND_I       3'b000
`define SIGN_EXTEND_S       3'b001
`define SIGN_EXTEND_B       3'b010
`define SIGN_EXTEND_U       3'b011
`define SIGN_EXTEND_J       3'b100
`define SIGN_EXTEND_IJ      3'b101

//Defining memory
`define MEM_B    3'b000
`define MEM_H    3'b001
`define MEM_W    3'b010
`define MEM_BU   3'b011
`define MEM_HU   3'b100
