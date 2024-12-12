//Module name PC clashes with output logic PC
module program_counter (
    input logic clk,          // Clock signal
    input logic rst,          // Reset signal 
    input logic [31:0] next_PC,
    output logic [31:0] PC    // Current PC value
);


// PC Register
always_ff @(posedge clk or posedge rst)
    if (rst) PC <= 32'b0; // Reset
    else PC <= next_PC; // Update

endmodule
