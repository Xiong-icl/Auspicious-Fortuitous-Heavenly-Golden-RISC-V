`include "define.sv"

module control (
    //Defining opcode, funct3 and funct7 like this makes it difficult to input full 32-bit instructions.
    input   logic [31:0] instruction,
    output  logic        RegWrite,  // Register file write enable
    output  logic        ALUSrc,    // ALU source selector
    output  logic [2:0]  ALUCtrl,   // ALU operation control
    output  logic [1:0]  IMMSrc,    // Immediate source selector
    output  logic [2:0]  MemCtrl,   // Memory operation control
    output  logic        PCSrc,     // PC source selector (for branches)
    output  logic        MemWrite,  // Memory write enable
    output  logic [1:0]  ResultSrc  // Result source selector
);

    logic [6:0] opcode;    // Opcode from instruction
    logic [2:0] funct3;    // funct3 field from instruction
    logic [6:0] funct7;    // funct7 field from instruction

    //Assigning variables based on 32-bit instruction
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Main control logic
    always_comb begin
        // Setting all default values
        ALUCtrl = `ALU_OPCODE_ADD;
        RegWrite = 0;
        ALUSrc = 0;
        ALUCtrl = 0;
        IMMSrc = 0;
        AddrMode = 0;
        PCSrc = `PC_NEXT;
        MemWrite = 0;
        ResultSrc = 0;

        case(opcode)

            //Register instructions
            `R_TYPE: begin
                RegWrite = 1;
                ALUSrc   = 0;
                MemWrite = 0;
                ResultSrc = 0;
                
                // Decode ALU operation based on funct3 and funct7
                case(funct3)
                    3'b000: begin
                        case(funct7)
                            7'h00: begin 
                                ALUCtrl = `ALU_OPCODE_ADD;
                            end

                            7'h20: begin
                                ALUCtrl = `ALU_OPCODE_SUB;
                            end

                            default: $display ("Add/Sub faulty");
                        endcase
                    end

                    3'b100: begin
                        ALUCtrl = `ALU_OPCODE_XOR;
                    end

                    3'b110: begin
                        ALUCtrl = `ALU_OPCODE_OR;
                    end

                    3'b111: begin
                        ALUCtrl = `ALU_OPCODE_AND;
                    end

                    3'b001: begin
                        ALUCtrl = `ALU_OPCODE_LSL;
                    end
                    
                    3'b101: begin

                        case(funct7)
                            7'h00: begin
                                ALUCtrl = `ALU_OPCODE_LSR;
                            end

                            7'h20: begin
                                ALUCtrl = `ALU_OPCODE_ASR;
                            end

                            default: $display ("LSR/ASR faulty");
                        endcase
                    end

                    3'b010: begin
                        ALUCtrl = `ALU_OPCODE_SLT;
                    end

                    3'b011: begin
                        ALUCtrl = `ALU_OPCODE_SLTU;
                    end

                    default: $display("R_TYPE instructions do not work");
                endcase
            end

            //Immediate instructions
            //Since immediate instructions are similar to register instructions to the ALU, use the same definitions
            `I_TYPE: begin
                RegWrite = 1;
                ALUSrc   = 1;  
                IMMSrc = `SIGN_EXTEND_I;
                
                case(funct3)
                    3'b000: begin
                        ALUCtrl = `ALU_OPCODE_ADD; // add instruction
                    end

                    3'b100: begin
                        ALUCtrl = `ALU_OPCODE_XOR; // xor instruction
                    end

                    3'b110: begin
                        ALUCtrl = `ALU_OPCODE_OR; // or instruction
                    end

                    3'b111: begin
                        ALUCtrl = `ALU_OPCODE_AND; // and instruction
                    end

                    3'b001: begin 
                        ALUCtrl = `ALU_OPCODE_LSL;
                    end

                    3'b101: begin 
                        case(funct7) 
                            7'h00: begin
                                ALUCtrl = `ALU_OPCODE_LSR;
                            end

                            7'h20: begin
                                ALUCtrl = `ALU_OPCODE_ASR;
                            end
                        endcase
                        
                    end

                    3'b010: begin 
                        ALUCtrl = `ALU_OPCODE_SLT;
                    end

                    3'b011: begin 
                        ALUCtrl = `ALU_OPCODE_SLTU;
                    end

                    default: $display("I_TYPE instructions do not work");
                endcase
            end

            //I_TYPE Load instructions
            `LOAD_TYPE: begin
                RegWrite = 1;
                IMMSrc = `SIGN_EXTEND_I;
                ALUSrc = 1;
                MemWrite = 0;
                ResultSrc = 1;
                
                case(funct3)
                    //lb
                    3'b000: begin 
                        MemCtrl = `MEM_B;
                    end

                    //lh
                    3'b001: begin 
                        MemCtrl = `MEM_H;
                    end

                    //lw
                    3'b010: begin 
                        MemCtrl = `MEM_W;
                    end

                    //lbu
                    3'b100: begin 
                        MemCtrl = `MEM_BU;
                    end

                    //lhu
                    3'b101: begin 
                        MemCtrl = `MEM_HU;
                    end

                    default: $display("Load instructions faulty");
                endcase
            end

            //Store instructions
            `S_TYPE: begin
                RegWrite = 0;
                ALUSrc = 1;
                ALUCtrl = `ALU_OPCODE_ADD;
                IMMSrc = `SIGN_EXTEND_S;
                MemWrite = 1;

                case(funct3)
                    3'b000: begin
                        MemCtrl = `MEM_B; // sb instruction
                    end

                    3'b001: begin
                        MemCtrl = `MEM_H; // sb instruction
                    end

                    3'b010: begin
                        MemCtrl = `MEM_W; // sw instruction
                    end
                    default: $display("Store instructions faulty");
                endcase
            end

            //Yet to implement/check B_TYPE and J_TYPE
            `B_TYPE: begin
                RegWrite = 0;
                ALUSrc   = 0;
                IMMSrc = `SIGN_EXTEND_B;

                case(funct3)
                    3'b000: begin
                        PCSrc = `PC_COND_BRANCH; // beq instruction
                        ALUCtrl = `ALU_OPCODE_SUB;
                    end
                    3'b001: begin
                        PCSrc = `PC_INV_COND_BRANCH; // bne instruction
                        ALUCtrl = `ALU_OPCODE_SUB;
                    end
                    3'b100: begin
                        PCSrc = `PC_INV_COND_BRANCH; // blt instruction
                        ALUCtrl = `ALU_OPCODE_SLT;
                    end
                    3'b101: begin
                        PCSrc = `PC_COND_BRANCH; // bge instruction
                        ALUCtrl = `ALU_OPCODE_SLT;
                    end
                    3'b110: begin
                        PCSrc = `PC_INV_COND_BRANCH; // bltu instruction
                        ALUCtrl = `ALU_OPCODE_SLTU;
                    end
                    3'b111: begin
                        PCSrc = `PC_COND_BRANCH; // bgeu instruction
                        ALUCtrl = `ALU_OPCODE_SLTU;
                    end

                    default: $display("Warning: undefined B-type instruction");
                endcase
            end

        endcase
    end

endmodule
