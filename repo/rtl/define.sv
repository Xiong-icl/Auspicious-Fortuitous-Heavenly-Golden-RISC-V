//Defining code words to simplify design

//Defining type instructions
`define R_TYPE              0110011
`define I_TYPE              0010011
`define S_TYPE              0100011
`define B_TYPE              1100011
`define J_TYPE              1101111
`define IJ_TYPE             1100111
`define U_TYPE              0110111
`define AUI_TYPE            0010111
`define LOAD_TYPE           0000011

//Defining ALU code
`define ALU_OPCODE_ADD      4'b0000
`define ALU_OPCODE_SUB      4'b0001
`define ALU_OPCODE_AND      4'b0010
`define ALU_OPCODE_OR       4'b0011
`define ALU_OPCODE_XOR      4'b0100
`define ALU_OPCODE_LSL      4'b0101
`define ALU_OPCODE_LSR      4'b0110
`define ALU_OPCODE_ASR      4'b0111
`define ALU_OPCODE_SLT      4'b1000
`define ALU_OPCODE_SLTU     4'b1001
`define ALU_OPCODE_B        4'b1010

//Defining Sign Extend code
`define SIGN_EXTEND_I       3'b000
`define SIGN_EXTEND_S       3'b001
`define SIGN_EXTEND_B       3'b010
`define SIGN_EXTEND_U       3'b011
`define SIGN_EXTEND_J       3'b100

//Defining Program Counter code
`define PC_NEXT             3'b000
`define PC_ALWAYS_BRANCH    3'b001
`define PC_JALR             3'b010
`define PC_INV_COND_BRANCH  3'b100
`define PC_COND_BRANCH      3'b101

//Defining memory
`define MEM_B    3'b000
`define MEM_H    3'b001
`define MEM_W    3'b010
`define MEM_BU   3'b011
`define MEM_HU   3'b100
