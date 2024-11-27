module instrmem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 8
)(
    input  logic [31:0] PC,        // Program Counter input
    output logic [31:0] instr      // Instruction output
);

    // Instruction memory array
    logic [ADDRESS_WIDTH-1:0] rom [0:2**DATA_WIDTH - 1];  // 256 x 32-bit memory array
                               // Size can be adjusted based on needs

    // Read-only behavior
    assign instr = rom[PC[9:2]]; // Word-aligned addressing (PC/4)
    
    // Initialize memory with program
    initial begin
        // Clear all memory locations first
        for (int i = 0; i < 256; i++) begin
            rom[i] = 32'h0;
        end

        // You can also load instructions from a file:
        // $readmemh("program.hex", rom);
    end


    always @(PC) begin
        assert (PC[1:0] == 2'b00) else
            $error("Instruction fetch from non-word-aligned address");
    end
    // synthesis translate_on

endmodule
