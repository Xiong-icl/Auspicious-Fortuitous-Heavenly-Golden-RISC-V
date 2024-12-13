//Module name PC clashes with output logic PC
module program_counter (
    input logic clk,          // Clock signal
    input logic stall,
    input logic [31:0] next_PC,
    output logic [31:0] PC    // Current PC value
);


// PC Register
always_ff @(posedge clk)
    if (!stall) begin 
        PC <= next_PC; // Update
    end
endmodule

