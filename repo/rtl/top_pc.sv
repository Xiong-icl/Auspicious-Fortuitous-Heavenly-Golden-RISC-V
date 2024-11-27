module top_pc (
    input  logic         clk,          // Clock signal
    input  logic         rst,          // Reset signal
    input  logic [31:0]  ImmOp,        // Immediate operand for branch
    input  logic         PCSrc,        // Choice between branch and incremented PC
    output logic [31:0]  PC            // Current PC value
);

    // Internal signals
    logic [31:0] inc_PC;    // PC + 4
    logic [31:0] branch_PC; // PC + ImmOp
    logic [31:0] next_PC;   // Output from mux

    // Assignments
    assign inc_PC = PC + 4; // Normal increment
    assign branch_PC = PC + ImmOp; // Branch increment


    mux #(.DATA_WIDTH(32)) pc_mux (
        .in0(inc_PC),       // Incremented PC
        .in1(branch_PC),    // Branch PC
        .sel(PCSrc),        // Select signal
        .out(next_PC)       
    );

    program_counter pc (
        .clk(clk),
        .rst(rst),
        .ImmOp(ImmOp),
        .PCSrc(PCSrc),
        .PC(PC)
    );

endmodule
