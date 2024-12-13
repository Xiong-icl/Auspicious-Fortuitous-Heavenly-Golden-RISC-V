`include "define.sv"
module signextend (
    /* verilator lint_off UNUSED */
    input logic [31:0] instr,
    /* verilator lint_on UNUSED */
    input  logic [2:0]  IMMSrc,    // Immediate format selector
    output logic [31:0] ImmOp      // Sign-extended immediate output
);


    always_comb begin
        case(IMMSrc)
            // I-type: Load, ALU immediate
            3'b000: begin
                ImmOp = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type: Store
            3'b001: begin
                ImmOp = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: Branch
            3'b010: begin
                ImmOp = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // U-type: LUI, AUIPC
            3'b011: begin
                ImmOp = {instr[31:12], 12'b0};
            end

            // J-type: JAL
            3'b100: begin
                ImmOp = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            3'b101: begin 
                ImmOp = {{27'b0}, instr[24:20]};
            end

            // Default case
            default: begin
                ImmOp = 32'b0;
            end
        endcase
    end

endmodule
