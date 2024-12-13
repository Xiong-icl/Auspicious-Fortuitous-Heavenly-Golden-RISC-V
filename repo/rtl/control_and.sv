module control_and (
    input   logic       branch,
    input   logic       Zero,
    input   logic       jump,
    output  logic       PCSrc
);
    assign PCSrc = ((branch & Zero) || jump);

endmodule
