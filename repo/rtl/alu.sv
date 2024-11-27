module alu #(
    parameter   DATA_WIDTH = 32
)(
    input logic     [DATA_WIDTH -1:0]   ALUop1,  // input data 1
    input logic     [DATA_WIDTH -1:0]   ALUop2,  // input data 2
    input logic     [2:0]               ALUctrl, //decides which instruction 8 different options
    output logic    [DATA_WIDTH -1:0]   SUM, //outputs the sum
    output logic                        EQ //gives signals to control unit on diagram I think it is ZERO
);
always_comb begin
    case (ALUctrl)
    3'b000: SUM = ALUop1 + ALUop2;                     // ADD
    3'b001: SUM = ALUop1 - ALUop2;                     // SUB
    3'b010: SUM = ALUop1 ^ ALUop2;                     // XOR
    3'b011: SUM = ALUop1 | ALUop2;                     // OR
    3'b100: SUM = ALUop1 & ALUop2;                     // AND
    3'b101:    if(ALUop1 == ALUop2)                    // BNE
            EQ = 1'b1;
        else
            EQ = 1'b0;
    3'b110: if EQ = (ALUop1 < ALUop2) ? 1 : 0;         //BLT
    3'b111: if EQ = (ALUop1 >= ALUop2) ? 1 : 0;        //BGE   
    endcase
end
endmodule

