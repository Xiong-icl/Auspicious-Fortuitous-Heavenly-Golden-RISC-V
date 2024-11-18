module control (
    input  logic [6:0] opcode,    // Opcode from instruction
    input  logic [2:0] funct3,    // funct3 field from instruction
    input  logic [6:0] funct7,    // funct7 field from instruction
    output logic       RegWrite,   // Register file write enable
    output logic       ALUSrc,    // ALU source selector
    output logic [2:0] ALUctrl,   // ALU operation control
    output logic       IMMsrc,    // Immediate source selector
    output logic       PCsrc      // PC source selector (for branches)
);

    // Main control logic
    always_comb begin
        // Default values
        RegWrite = 1'b0;
        ALUSrc   = 2'b00;
        ALUctrl  = ALU_ADD;
        IMMsrc   = 1'b0;
        PCsrc    = 1'b0;

        case(opcode)
            R_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 2'b00;  // Use register operands
                
                // Decode ALU operation based on funct3 and funct7
                case(funct3)
                    3'b000: ALUctrl = (funct7[5]) ? ALU_SUB : ALU_ADD;
                    3'b111: ALUctrl = ALU_AND;
                    3'b110: ALUctrl = ALU_OR;
                endcase
            end

            I_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 2'b01;  // Use immediate operand
                
                case(funct3)
                    3'b000: ALUctrl = ALU_ADD;  // ADDI
                    3'b111: ALUctrl = ALU_AND;  // ANDI
                    3'b110: ALUctrl = ALU_OR;   // ORI
                endcase
            end

            B_TYPE: begin
                RegWrite = 1'b0;
                ALUSrc   = 2'b00;
                ALUctrl  = ALU_SUB;  // For comparison
                PCsrc    = 1'b1;     // Branch instruction
            end

            default: begin
                // Default values for undefined opcodes
                RegWrite = 1'b0;
                ALUSrc   = 2'b00;
                ALUctrl  = ALU_ADD;
                IMMsrc   = 1'b0;
                PCsrc    = 1'b0;
            end
        endcase
    end

endmodule
