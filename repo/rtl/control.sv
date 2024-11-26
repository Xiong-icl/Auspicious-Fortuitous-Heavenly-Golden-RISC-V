module control #(
    parameter DATA_WIDTH = 32
) (
    input  logic [6:0] opcode,              // Opcode from instruction
    input  logic [2:0] funct3,              // funct3 field from instruction
    input  logic [6:0] funct7,              // funct7 field from instruction
    input  logic [DATA_WIDTH-1:0] instr,    // Instruction Memory
    output logic       RegWrite,            // Register file write enable
    output logic       ALUSrc,              // ALU source selector
    output logic [2:0] ALUctrl,             // ALU operation control
    output logic       IMMsrc,              // Immediate source selector
    output logic       PCsrc                // PC source selector (for branches)
);

    // Main control logic
    always_comb begin
        // Default values
        ALUctrl = `ALU_OPCODE_ADD;
        ALUsrc = 1'b0;
        ImmSrc = 3'b000;
        RegWrite = 0;
        PCsrc = `PC_NEXT;

        case(opcode)

            R_TYPE: begin
                RegWrite = 1;
                ALUSrc   = 0; 
                
                // Decode ALU operation based on funct3 and funct7
                case(funct3)
                    3'b000: begin
                        case(funct7)
                            7'h00: begin 
                                ALUctrl = `ALU_OPCODE_ADD; // add instruction
                            end
                            7'h20 begin
                                ALUctrl = `ALU_OPCODE_SUB; // sub instruction
                            end
                            defaul: $display ("warning: undefined add/sub")
                        endcase
                    end
                endcase
            end

            I_TYPE: begin
                RegWrite = 1;
                ALUSrc   = 1;  
                ImmSrc = `SIGN_EXTEND_I;
                
                case(funct3)
                    3'b000: begin
                        ALUctrl = `ALU_OPCODE_ADD; // add instruction
                    end
                    3'b110: begin
                        ALUctrl = `ALU_OPCODE_OR; // or instruction
                    end
                    3'b100: begin
                        ALUctrl = `ALU_OPCODE_XOR; // xor instruction
                    end
                    3'b111: begin
                        ALUctrl = `ALU_OPCODE_AND; // and instruction
                    end
                    default: $display("Warning: undefined I-type instruction");
                endcase
            end

            B_TYPE: begin
                RegWrite = 0;
                ALUSrc   = 0;
                ImmSrc = `SIGN_EXTEND_B;

                case(funct3)
                    3'b000: begin
                        PCsrc = `PC_COND_BRANCH; // beq instruction
                        ALUctrl = `ALU_OPCODE_SUB;
                    end
                    3'b001: begin
                        PCsrc = `PC_INV_COND_BRANCH; // bne instruction
                        ALUctrl = `ALU_OPCODE_SUB;
                    end
                    3'b100: begin
                        PCsrc = `PC_INV_COND_BRANCH; // blt instruction
                        ALUctrl = `ALU_OPCODE_SLT;
                    end
                    3'b101: begin
                        PCsrc = `PC_COND_BRANCH; // bge instruction
                        ALUctrl = `ALU_OPCODE_SLT;
                    end
                    3'b110: begin
                        PCsrc = `PC_INV_COND_BRANCH; // bltu instruction
                        ALUctrl = `ALU_OPCODE_SLTU;
                    end
                    3'b111: begin
                        PCsrc = `PC_COND_BRANCH; // bgeu instruction
                        ALUctrl = `ALU_OPCODE_SLTU;
                    end

                    default: $display("Warning: undefined B-type instruction");
                endcase
            end

            S_TYPE: begin
                ALUsrc = 1;
                ALUctrl = `ALU_OPCODE_ADD;
                ImmSrc = `SIGN_EXTEND_S;

                case(funct3)
                    3'b000: begin
                        AddrMode = `DATA_ADDR_MODE_B; // sb instruction
                    end
                    3'b010: begin
                        AddrMode = `DATA_ADDR_MODE_W; // sw instruction
                    end
                    default: $display("Warning: undefined S-type instruction");
                endcase
            end

        endcase
    end

endmodule
