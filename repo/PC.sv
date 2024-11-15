module PC #(
    input clk,          // Clock signal
    input rst,          // Reset signal 
    input [31:0] ImmOp, // Immediate operand for branch branch_PC
    input PCsrc,        // Choice between branch and incremented PC
    output [31:0] PC    // Current PC value
);

// Internal signals
logic [31:0] inc_PC;    // PC + 4
logic [31:0] branch_PC; // PC + ImmOp
logic [31:0] next_PC;   // The one we choose


assign inc_PC = PC + 4; // Normal increment
assign branch_PC = PC + ImmOp; // Branch increment
assign next_PC = (PCsrc) ? branch_PC : inc_PC; // The one we feed to PC Reg

// PC Register
always_ff @(posedge clk or posedge rst)
    if (rst) PC <= 32'b0; // Reset
    else PC <= next_PC; // Update


endmodule

