module control #(
    parameter INSTR_WIDTH = 32
)(
    input  logic [INSTR_WIDTH 6:0]   opcode,    // Opcode from instruction
    input  logic [INSTR_WIDTH 14:12] funct3,    // funct3 field from instruction
    input  logic [INSTR_WIDTH 31:24] funct7,    // funct7 field from instruction
    output logic       RegWrite,   // Register file write enable
    output logic       ALUSrc,    // ALU source selector
    output logic [2:0] ALUctrl,   // ALU operation control
    output logic [1:0] IMMsrc,    // Immediate source selector
    output logic       PCsrc,      // PC source selector (for branches)
    output logic       ResultSrc,
    output logic       MemWrite

);

    // Default values
    assign    RegWrite  = 1'b0;
    assign    ALUSrc    = 1'b0;
    assign    IMMsrc    = 2'b00;
    assign    PCsrc     = 1'b0;
    assign    ALUctrl   = 3'b000;
    assign    ResultSrc = 1'b0;
    assign    MemWrite  = 1'b0; 

    // Main control logic
    always_comb begin
        case (opcode)
            
            7'b011011: begin            //R_type

                case(funct3)

                    3'b000: begin           //Add , sub instructions
                        PCsrc = 0;
                        case(funct7)
                            7'b0000000: begin       //Add
                                ALUctrl = 3'b000;
                                RegWrite = 1;
                                ALUsrc = 0;
                                $display("add", op, " ", funct3);

                            end

                            7'b0100000: begin       //sub
                            ALUctrl = 3'b001;
                            RegWrite = 1;
                            ALUsrc = 0;
                            $display("sub", op, " ", funct3);
                            end
                        endcase
                    end

                    3'b001: begin           //sll instruction
                        PCsrc = 0;
                    end
                    
                    3'b010: begin           //slt instruction
                        PCsrc = 0;
                    end

                    3'b011: begin           //sltu instruction
                        PCsrc = 0;
                    end
                    
                    3'b100: begin           //xor instruction
                        PCsrc = 0;
                    end
                    
                    3'b101: begin           //srl , sra instructions
                        PCsrc = 0;
                        case(funct7)
                            7'b0000000: begin       //srl

                            end

                            7'b0100000: begin       //sra 

                            end
                        endcase
                    end
                    
                    3'b110: begin           //or instruction
                        PCsrc = 0;
                    end
                    
                    3'b111: begin           //and instruction
                        PCsrc = 0;
                    end
                endcase
            end

            7'b0010011: begin            //I1_type

            end

            7'b0000011: begin            //I2_type

            end

            7'b0100011: begin            //S_type

            end

            7'b1100011: begin            //B_type

            end

            7'b1101111: begin            //J_type

            end

            7'b1100111: begin            //I3_type

            end

            7'b0110111: begin            //U1_type

            end

            7'b0010111: begin            //U2_type

            end 

        endcase
    end


endmodule
