module alu #(
    parameter   DATA_WIDTH = 32
)(
    input logic ALUop1,  // input data 1
    input logic ALUop2,  // input data 2
    input logic ALUctrl, //decides which instruction either addi or bne
    output logic [DATA_WIDTH -1:0]SUM, //outputs the sum
    output logic EQ //gives signals to control unit
);
always_comb begin
    case (alu_ctrl)
    1'b0:    SUM =  ALUop1 + ALUop2;
    1'b1:    if(ALUop1 == ALUop2)
            EQ = 1'b1;
        else
            EQ = 1'b0;
    endcase
end
endmodule
