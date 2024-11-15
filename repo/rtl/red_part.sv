module red_part #(
    input logic clk,
    input logic alu_src,
    output logic [31:0] a0  // output of a0 register from Register File
);
 

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

endmodule