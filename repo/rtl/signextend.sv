module signextend (
    input  logic [31:0] instr,     // Full instruction
    input  logic [2:0]  IMMsrc,    // Immediate format selector
    output logic [31:0] ImmOp      // Sign-extended immediate output
);

    // IMMsrc encoding
    typedef enum logic [2:0] {
        I_TYPE = 3'b000,  // I-type instructions
        S_TYPE = 3'b001,  // Store instructions
        B_TYPE = 3'b010,  // Branch instructions
        U_TYPE = 3'b011,  // Upper immediate instructions
        J_TYPE = 3'b100   // Jump instructions
    } imm_type_t;

    always_comb begin
        case(IMMsrc)
            // I-type: Load, ALU immediate
            I_TYPE: begin
                ImmOp = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type: Store
            S_TYPE: begin
                ImmOp = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: Branch
            B_TYPE: begin
                ImmOp = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // U-type: LUI, AUIPC
            U_TYPE: begin
                ImmOp = {instr[31:12], 12'b0};
            end

            // J-type: JAL
            J_TYPE: begin
                ImmOp = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            // Default case
            default: begin
                ImmOp = 32'b0;
            end
        endcase
    end

    //Why is this necessary?
    // Assertions for verification
    // synthesis translate_off
    always @(instr, IMMsrc) begin
        assert (IMMsrc <= 3'b100) else
            $error("Invalid IMMsrc value: %b", IMMsrc);
    end
    // synthesis translate_on

endmodule
