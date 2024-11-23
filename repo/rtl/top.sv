module top #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0
);
    logic [31:0] ImmOp; // Immediate operand for branch branch_PC
    logic PCsrc;        // Choice between branch and incremented PC
    logic [31:0] PC;    // Current PC value
    

    // Define Register File Signals
    logic [4:0] rs1, rs2, rd;       // Register addresses
    logic [31:0] rd1_data, rd2_data, wr_data, alu_out; // Read and Write data for Register File
    logic we;                       // Write enable

    //ALU logic
    logic alu_src;                  // ALU source selection
    logic [31:0] alu_op2;           // ALU operand 2 (could be immediate or register value)
    logic alu_ctrl;                 // ALU operation control (add, subtract, etc.)

    //PC logic 
    logic EQ;
    logic [31:0] imm;

    //MUX logic
    logic [DATA_WIDTH-1:0]  in0;
    logic [DATA_WIDTH-1:0]  in1;
    logic                   sel;
    logic [DATA_WIDTH-1:0]  out;

    //Control Unit logic
    logic [31:0] instr;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Extract instruction fields
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];


    // Register File instantiation (asynchronous read, synchronous write)
    reg_file new_regfile (
        .clk(clk),
        .WE3(we),
        .AD1(rs1),
        .AD2(rs2),
        .AD3(rd),
        .WD3(wr_data),
        .RD1(rd1_data),
        .RD2(rd2_data),
        .a0(a0)
    );

    //This technically does the job of the mux, but we should not include this as an non-mux instruction
    assign alu_op2 = (alu_src) ? imm : rd2_data;

    // ALU instantiation
    alu new_alu (
        .ALUop1(rd1_data),
        .ALUop2(alu_op2),
        .ALUctrl(alu_ctrl),
        .EQ(EQ),
        .SUM(alu_out)
    );

    //Use this instead
    // mux mux_alu (
    //     .in0(rd2_data),
    //     .in1(ImmOp),
    //     .sel(alu_src),
    //     .out(alu_op2)
    // );

    //Program Counter instantiation
    program_counter new_pc (
        .clk(clk),
        .rst(rst),
        .ImmOp(ImmOp), // Immediate operand for branch branch_PC
        .PCsrc(PCsrc),        // Choice between branch and incremented PC
        .PC(PC)    // Current PC value
    );

//Needs modification, not linked with ALU yet
/*
    // Instruction Memory instantiation
    instrmem instruction_memory (
        .pc(pc),
        .instruction(instr)
    );

    // Control Unit instantiation
    control control_unit (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUctrl(ALUctrl),
        .ALUsrc(ALUsrc),
        .IMMsrc(IMMsrc),
        .PCsrc(PCsrc)
    );

    // Sign Extend instantiation
    signextend sign_extend (
        .instruction(instr),
        .IMMsrc(IMMsrc),
        .ImmOp(ImmOp)
    );
*/
endmodule
