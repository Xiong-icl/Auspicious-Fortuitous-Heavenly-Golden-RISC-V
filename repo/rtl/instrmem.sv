module instrmem #(
    parameter ADDRESS_WIDTH = 32,
              DATA_WIDTH = 8,
              INSTR_WIDTH = 32
) (
    input  logic [ADDRESS_WIDTH-1:0] A, // address input
    output logic [INSTR_WIDTH-1:0] RD   // instruction output
);

    logic [DATA_WIDTH-1:0] array [0:2**12-1]; // memory array

    initial begin
        $display("Loading data into data memory...");
        $readmemh("../rtl/program.hex", array);
    end
    
    assign RD = {array[A + 3], array[A + 2], array[A + 1], array[A]};

    initial begin
        $display("RD is", RD);
    end
    
    always @(A) begin
        assert (A[1:0] == 2'b00) else
            $error("Instruction fetch from non-word-aligned address");
    end

endmodule
