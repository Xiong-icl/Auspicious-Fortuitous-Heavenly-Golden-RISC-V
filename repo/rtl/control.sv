`include "define.sv"

module control (
    //Defining opcode, funct3 and funct7 like this makes it difficult to input full 32-bit instructions.
    /* verilator lint_off UNUSED */
    input logic [31:0] instruction,
    /* verilator lint_on UNUSED */
    output  logic        RegWrite,  // Register file write enable
    output  logic        ALUSrc,    // ALU source selector
    output  logic [4:0]  ALUCtrl,   // ALU operation control
    output  logic [2:0]  IMMSrc,    // Immediate source selector
    output  logic        MemWrite,  // Memory write enable
    output  logic        MemRead,
    output  logic [1:0]  ResultSrc,  // Result source selector
    output  logic        branch,
    output  logic [2:0]  MemCtrl,
    output  logic        jump,
    output  logic        JALROn
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
        // $display("instruction is: %b", instruction);
        // $display("RegWrite is: %b", RegWrite);
        // $display("ALUSrc is: %b", ALUSrc);
        // $display("ALUCtrl is: %b", ALUCtrl);
        // $display("IMMSrc is: %b", IMMSrc);
        // $display("MemWrite is: %b", MemWrite);
        // $display("ResultSrc is: %b", ResultSrc);
        // $display("branch is: %b", branch);
        // $display("opcode is: %b", opcode);
        // Setting all default values
        ALUCtrl = `ALU_ADD;
        RegWrite = 0;
        ALUSrc = 1;
        IMMSrc = 0;
        MemWrite = 0;
        MemRead = 0;
        ResultSrc = 0;
        branch = 0;
        jump = 0;
        JALROn = 0;

        case(opcode)

            //Register instructions
            7'b0110011: begin
                RegWrite = 1;
                ALUSrc   = 0;
                MemWrite = 0;
                ResultSrc = 0;
                
                // Decode ALU operation based on funct3 and funct7
                case(funct3)
                    3'b000: begin
                        case(funct7)
                            7'h00: begin 
                                ALUCtrl = `ALU_ADD;
                            end

                            7'h20: begin
                                ALUCtrl = `ALU_SUB;
                            end

                            default: $display ("Add/Sub faulty");
                        endcase
                    end

                    3'b100: begin
                        ALUCtrl = `ALU_XOR;
                    end

                    3'b110: begin
                        ALUCtrl = `ALU_OR;
                    end

                    3'b111: begin
                        ALUCtrl = `ALU_AND;
                    end

                    3'b001: begin
                        ALUCtrl = `ALU_LSL;
                    end
                    
                    3'b101: begin

                        case(funct7)
                            7'h00: begin
                                ALUCtrl = `ALU_LSR;
                            end

                            7'h20: begin
                                ALUCtrl = `ALU_ASR;
                            end

                            default: $display ("LSR/ASR faulty");
                        endcase
                    end

                    3'b010: begin
                        ALUCtrl = `ALU_SLT;
                    end

                    3'b011: begin
                        ALUCtrl = `ALU_SLTU;
                    end

                    default: $display("R_TYPE instructions do not work");
                endcase
            end

            //Immediate instructions
            //Since immediate instructions are similar to register instructions to the ALU, use the same definitions
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1;  
                IMMSrc = `SIGN_EXTEND_I;
                
                case(funct3)
                    3'b000: begin
                        ALUCtrl = `ALU_ADD; // add instruction
                    end

                    3'b100: begin
                        ALUCtrl = `ALU_XOR; // xor instruction
                    end

                    3'b110: begin
                        ALUCtrl = `ALU_OR; // or instruction
                    end

                    3'b111: begin
                        ALUCtrl = `ALU_AND; // and instruction
                    end

                    3'b001: begin 
                        ALUCtrl = `ALU_LSL;
                    end

                    3'b101: begin 
                        case(funct7) 
                            7'h00: begin
                                ALUCtrl = `ALU_LSR;
                            end

                            7'h20: begin
                                ALUCtrl = `ALU_ASR;
                            end
                            default: $display("LSR and ASR IMM faulty");
                        endcase
                    end

                    3'b010: begin 
                        ALUCtrl = `ALU_SLT;
                    end

                    3'b011: begin 
                        ALUCtrl = `ALU_SLTU;
                    end

                    default: $display("I_TYPE instructions do not work");
                endcase
            end

            //I_TYPE Load instructions
            7'b0000011: begin
                RegWrite = 1;
                IMMSrc = `SIGN_EXTEND_I;
                ALUSrc = 1;
                MemWrite = 0;
                ResultSrc = 1;
                MemRead = 1;
                
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
            7'b0100011: begin
                RegWrite = 0;
                ALUSrc = 1;
                ALUCtrl = `ALU_ADD;
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

            //Branch instructions
            7'b1100011: begin
                RegWrite = 0;
                ALUSrc   = 0;
                IMMSrc   = `SIGN_EXTEND_B;
                branch   = 1;

                case(funct3)
                    3'b000: begin
                        ALUCtrl = `ALU_BEQ;      //Using SUB to find whether is EQ, BEQ
                    end
                    3'b001: begin
                        ALUCtrl = `ALU_BNE;      //Using SUB to find whether is EQ and inverting the condition for HIGH, BNE
                    end
                    3'b100: begin
                        ALUCtrl = `ALU_BLT;      //Using SLT and inverting the condition for HIGH, BLT
                    end
                    3'b101: begin
                        ALUCtrl = `ALU_BGE;      //Using SLT, BGE
                    end
                    3'b110: begin
                        ALUCtrl = `ALU_BLTU;     //Using SLT with Unsigned and inverting the condition for HIGH, BLTU
                    end
                    3'b111: begin
                        ALUCtrl = `ALU_BGEU;     //Using SLT with Unsigned, BGEU
                    end

                    default: $display("Warning: undefined B-type instruction");
                endcase
            end

            //Jump instructions
            //What does ResultSrc do here?
            7'b1101111: begin
                RegWrite = 1;
                ALUSrc   = 1;
                IMMSrc = `SIGN_EXTEND_J;
                jump = 1;
                ResultSrc = 2;
            end

            //JALR instructions
            7'b1100111: begin 
                RegWrite = 0;
                ALUSrc   = 1;
                IMMSrc = `SIGN_EXTEND_IJ;
                jump = 1;
                ResultSrc = 2;
                JALROn = 1;
            end

            //Upper immediate instructions
            7'b0110111: begin 
                RegWrite = 1;
                ALUSrc   = 1;
                IMMSrc = `SIGN_EXTEND_U;
                ALUCtrl = `ALU_LUI;
            end

            7'b0010111: begin 
                RegWrite = 1;
                ALUSrc   = 1;
            end
            default: ;
        endcase
    end
endmodule
