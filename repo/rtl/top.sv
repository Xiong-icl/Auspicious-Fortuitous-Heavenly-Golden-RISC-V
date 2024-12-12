module top #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output  logic [DATA_WIDTH-1:0] a0
);

    //ALU logic
    logic [DATA_WIDTH-1:0]    ALUop1;
    logic [DATA_WIDTH-1:0]    ALUop2;
    logic [DATA_WIDTH-1:0]    SUM;
    logic           EQ;                 // ALU operation control (add, subtract, etc.)

    //Control Unit logic
    logic [31:0]    instr;
    logic           RegWrite;
    logic           ALUSrc;
    logic [4:0]     ALUCtrl;
    logic [2:0]     IMMSrc;
    logic [2:0]     MemCtrl;
    logic           PCSrc;
    logic           MemWrite;
    logic [1:0]     ResultSrc;
    logic           branch;
    logic           jump;
    logic           JALROn;

    //Data Memory logic
    logic [31:0]    rd;
    //For mux_data_mem logic
    logic [31:0]    Result;
    logic [2:0]     funct3;

    assign funct3 = instr[14:12];

    // //MUX logic
    // logic [DATA_WIDTH-1:0]  in0;
    // logic [DATA_WIDTH-1:0]  in1;
    // logic                   sel;
    // logic [DATA_WIDTH-1:0]  out;

    //Top PC logic 
    logic [DATA_WIDTH-1:0]    ImmOp; 
    logic [DATA_WIDTH-1:0]    PC;

    //Define Register File Signals
    logic [4:0] AD1, AD2, AD3;      // Register addresses
    logic [DATA_WIDTH-1:0] RD2;     // Read and Write data for Register File

    //Register file instruction fields
    assign AD1 = instr[19:15];
    assign AD2 = instr[24:20];
    assign AD3 = instr[11:7];

    //For mux at data memory
    logic [31:0] inc_PC;

    instrmem new_instrmem (
        .A(PC),
        .RD(instr)
    );

    control new_control_unit (
        .instruction(instr),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUCtrl(ALUCtrl),
        .IMMSrc(IMMSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .MemCtrl(MemCtrl),
        .branch(branch),
        .jump(jump),
        .JALROn(JALROn)
    );

    control_and new_control_and (
        .branch(branch),
        .Zero(EQ),
        .jump(jump),
        .PCSrc(PCSrc)
    );

    mux new_alu_mux (

        .in0(RD2),
        .in1(ImmOp),
        .sel(ALUSrc),
        .out(ALUop2)
    );

    // ALU instantiation
    alu new_alu (
        .ALUop1(ALUop1),
        .ALUop2(ALUop2),
        .ALUCtrl(ALUCtrl),
        .EQ(EQ),
        .SUM(SUM)
    );

    data_memory new_data_memory (
        .clk (clk),
        .addr (SUM),
        .we (MemWrite),
        .funct3(funct3),
        .wd (RD2),
        .rd (rd)
    );

    assign inc_PC = PC + 4;
    mux2 mux_data_mem (
        .in0_2(SUM),
        .in1_2(rd),
        .in2_2(inc_PC),
        .sel_2(ResultSrc),
        .out_2(Result)
    );

    //Program Counter instantiation
    top_pc new_pc (
        .clk(clk),
        .rst(rst),
        .ImmOp(ImmOp), // Immediate operand for branch branch_PC
        .PCSrc(PCSrc),        // Choice between branch and incremented PC
        .rs1(ALUop1),
        .JALROn(JALROn),
        .PC(PC)    // Current PC value
    );

    // Register File instantiation (asynchronous read, synchronous write)
    reg_file new_regfile (
        .clk(clk),
        .WE3(RegWrite),
        .AD1(AD1),
        .AD2(AD2),
        .AD3(AD3),
        .WD3(Result),
        .RD1(ALUop1),
        .RD2(RD2),
        .a0(a0)
    ); 

    // Sign Extend instantiation
    signextend new_sign_extend (
        .instr(instr),
        .IMMSrc(IMMSrc),
        .ImmOp(ImmOp)
    );

    // always_ff@(posedge clk) begin
    //     $display("Opcode: %b", instr[6:0]);
    //     $display("SUM is: %h", SUM);
    //     $display("rd is: %h", rd);
    //     $display("AD1 is: %d, AD2 is: %d, AD3 is: %d", AD1, AD2, AD3);
    //     $display("RD1 is: %h, RD2 is: %h, WD3 is: %h", ALUop1, RD2, Result);
    //     $display("RegWrite is: %b", RegWrite);
    //     $display("rs1 is: %h", ALUop1);
    //     $display("a0 is: %d", a0);
    //     $display(" ");
    // end   

endmodule
