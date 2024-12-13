module rs1_add (
    input  logic [31:0] RD1E,         // Program Counter from Execute stage
    input  logic [31:0] ExtImmE,     // Extended Immediate value
    output logic [31:0] PC_Rs1_Add  // Computed branch address
);
    // Perform the addition
    assign PC_Rs1_Add = RD1E + ExtImmE;

endmodule
