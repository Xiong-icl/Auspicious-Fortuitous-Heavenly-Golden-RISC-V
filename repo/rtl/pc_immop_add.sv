module pc_immop_add (
    input  logic [31:0] PCE,         // Program Counter from Execute stage
    input  logic [31:0] ExtImmE,     // Extended Immediate value
    output logic [31:0] PC_ImmOp_Add  // Computed branch address
);
    // Perform the addition
    assign PC_ImmOp_Add = PCE + ExtImmE;

endmodule
