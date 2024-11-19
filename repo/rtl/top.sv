module top #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    
);
    assign a0 = 32'd5;

    // Internal signals
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Extract instruction fields
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // Instruction Memory instantiation
    instrmem instruction_memory (
        .pc(pc),
        .instruction(instr)
    );

    // Control Unit instantiation
    control control_unit (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUctrl(ALUctrl),
        .ALUsrc(ALUsrc),
        .IMMsrc(IMMsrc),
        .PCsrc(PCsrc)
    );

    // Sign Extend instantiation
    signextend sign_extend (
        .instruction(instr),
        .IMMsrc(IMMsrc),
        .ImmOp(ImmOp)
    );

endmodule
