module top #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0
);
    logic alu_src;
    logic [31:0] ImmOp; // Immediate operand for branch branch_PC
    logic PCsrc;        // Choice between branch and incremented PC
    logic [31:0] PC;    // Current PC value
    assign a0 = 32'd5;
    

    // Define Register File Signals
    logic [4:0] rs1, rs2, rd;       // Register addresses
    logic [31:0] rd1_data, rd2_data, wr_data; // Read and Write data for Register File
    logic we;                       // Write enable

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

    assign alu_op2 = (alu_src) ? imm : rd2_data;

    // ALU instantiation
    alu new_alu (
        .ALUop1(rd1_data),
        .ALUop2(alu_op2),
        .ALUctrl(alu_ctrl),
        .EQ(EQ),
        .SUM(alu_out)
    );

    PC new_pc (
        .clk(clk),
        .rst (rst),
        .ImmOp (ImmOp), // Immediate operand for branch branch_PC
        .PCsrc (PCsrc),        // Choice between branch and incremented PC
        .PC (PC)    // Current PC value

    );

endmodule
