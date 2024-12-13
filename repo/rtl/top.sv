module top #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    /* verilator lint_off UNUSED */
    input logic rst,
    /* verilator lint_on UNUSED */
    /* verilator lint_off UNUSED */
    input logic trigger,
    /* verilator lint_on UNUSED */
    output  logic [DATA_WIDTH-1:0] a0
);

    //Program counter
    logic [DATA_WIDTH-1:0] PC_ImmOp_Add;
    logic [DATA_WIDTH-1:0] PC_Rs1_Add; 
    logic [31:0] next_PC;

    //ALU logic
    logic [DATA_WIDTH-1:0]    SUM;
    logic           ZeroE;                 // ALU operation control (add, subtract, etc.)

    //Control Unit logic
    logic [31:0]    instr;
    logic           RegWrite;
    logic           ALUSrc;
    logic [4:0]     ALUCtrl;
    logic [2:0]     IMMSrc;
    logic [2:0]     MemCtrl;
    logic           PCSrc;
    logic           MemWrite;
    logic           MemRead;
    logic [1:0]     ResultSrc;
    logic           branch;
    logic           jump;
    logic           JALROn;

    //Data Memory logic
    logic [31:0]    rd;

    //Top PC logic 
    logic [DATA_WIDTH-1:0]    ImmOp; 
    logic [DATA_WIDTH-1:0]    PC;


    //Define Register File Signals
    logic [4:0] AD1, AD2;      // Register addresses
    logic [DATA_WIDTH-1:0] RD1, RD2;     // Read and Write data for Register File

    //Register file instruction fields
    assign AD1  = InstrD[19:15];
    assign AD2  = InstrD[24:20];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD  = InstrD[11:7];

    logic[2:0] MemCtrlM;

    //F-D Pipeline
    logic [31:0] PCPlus4F;
    logic [31:0] InstrD;
    logic [31:0] PCPlus4D;
    logic [31:0] PCD;

    //D-E Pipeline
    logic                       RegWriteE;
    logic   [1:0]               ResultSrcE;
    logic                       MemWriteE;    
    logic                       JumpE;
    logic                       BranchE;
    logic   [4:0]               ALUControlE;
    logic                       ALUSrcE;
    logic   [DATA_WIDTH-1:0]    RD1E;
    logic   [DATA_WIDTH-1:0]    RD2E;
    logic   [31:0]              PCE;
    logic   [31:0]              PCPlus4E;
    logic   [4:0]               Rs1D;
    logic   [4:0]               Rs2D;
    logic   [4:0]               RdD;
    logic   [4:0]               Rs1E;
    logic   [4:0]               Rs2E;
    logic   [4:0]               RdE;
    logic   [31:0]              ImmExtE;
    logic   [2:0]               MemCtrlE;
    logic                       JALROnE;

    //E-M Pipeline
    logic                       RegWriteM;
    logic   [1:0]               ResultSrcM;
    logic                       MemWriteM;
    logic   [DATA_WIDTH-1:0]    ALUResultM;
    logic   [DATA_WIDTH-1:0]    WriteDataM;
    logic   [4:0]               RdM;
    logic   [DATA_WIDTH-1:0]    PCPlus4M;
    logic   [DATA_WIDTH-1:0]    SrcAE;
    logic   [DATA_WIDTH-1:0]    SrcBE;
    logic   [DATA_WIDTH-1:0]    PCTargetE;
    logic                       MemReadE;

    //M-W Pipeline
    logic                       RegWriteW;
    logic   [1:0]               ResultSrcW;
    logic   [31:0]              PCPlus4W;
    logic   [DATA_WIDTH-1:0]    WriteDataE;
    logic   [DATA_WIDTH-1:0]    ResultW;
    logic   [DATA_WIDTH-1:0]    ALUResultW;
    logic   [DATA_WIDTH-1:0]    ReadDataW;
    logic   [4:0]               RdW;
    
    //Hazard unit
    logic           stall;
    logic           flush;
    logic   [1:0]   ForwardAE;
    logic   [1:0]   ForwardBE;


    // Fetch-Decode pipeline stage
    pipeline_f_d new_pipeline_f_d (
        .clk(clk),//
        .stall(stall),// ??
        .flush(flush),// ??
        .InstrF(instr),//
        .PCF(PC),// 
        .PCPlus4F(PCPlus4F), //

        .InstrD(InstrD), //
        .PCD(PCD),//
        .PCPlus4D(PCPlus4D)//
    );

    instrmem new_instrmem (
        .A(PC),
        .RD(instr)
    );

    pc_immop_add new_immop_add (

        .PCE(PCE),         // Program Counter from Execute stage
        .ExtImmE(ImmExtE),     // Extended Immediate value
        .PC_ImmOp_Add(PC_ImmOp_Add)  // Computed branch address
    );

    rs1_add new_rs1_add (
        .RD1E(RD1E),         // Program Counter from Execute stage
        .ExtImmE(ImmExtE),     // Extended Immediate value
        .PC_Rs1_Add(PC_Rs1_Add)  // Computed branch address
    );
    
    mux pc_add_mux (
        .in0(PC_ImmOp_Add),
        .in1(PC_Rs1_Add),
        .sel(JALROnE),
        .out(PCTargetE)
    );

    assign PCPlus4F = PC + 4;

    mux pc_mux (
        .in0(PCPlus4F),
        .in1(PCTargetE),
        .sel(PCSrc),
        .out(next_PC)
    );

    program_counter new_pc (
        .clk(clk),          // Clock signal
        .stall(stall),
        .next_PC(next_PC),
        .PC(PC)    // Current PC value
    );

    // Decode-Execute pipeline stage
    // still need to add half the shit
    pipeline_d_e new_pipeline_d_e (
        .clk(clk),//
        .flush(flush),
        .stall(stall),
        .RegWriteD(RegWrite),//
        .ResultSrcD(ResultSrc),//
        .MemWriteD(MemWrite),//
        .MemReadD(MemRead),
        .JumpD(jump),//
        .BranchD(branch),//
        .ALUControlD(ALUCtrl),//
        .ALUSrcD(ALUSrc),//
        .ImmExtD(ImmOp),//
        .PCPlus4D(PCPlus4D),//
        .Rs1D(Rs1D),//
        .Rs2D(Rs2D),//
        .RD1(RD1),//
        .RD2(RD2),//
        .PCD(PCD),//
        .RdD(RdD),//
        .MemCtrlD(MemCtrl),

        .RegWriteE(RegWriteE),//
        .ResultSrcE(ResultSrcE),//
        .MemWriteE(MemWriteE),//
        .MemReadE(MemReadE),
        .JumpE(JumpE),//
        .BranchE(BranchE),//
        .ALUControlE(ALUControlE),//
        .ALUSrcE(ALUSrcE),//
        .RD1E(RD1E),//
        .RD2E(RD2E),//
        .PCE(PCE),//
        .Rs1E(Rs1E),//
        .Rs2E(Rs2E),//
        .RdE(RdE),//
        .ImmExtE(ImmExtE),//
        .PCPlus4E(PCPlus4E),//
        .MemCtrlE(MemCtrlE)
    );

    control_and new_control_and (
        .branch(BranchE),//
        .Zero(ZeroE),//
        .jump(JumpE),//
        .PCSrc(PCSrc)//
    );

    control new_control_unit (
        .instruction(InstrD),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUCtrl(ALUCtrl),
        .IMMSrc(IMMSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .MemCtrl(MemCtrl),
        .branch(branch),
        .jump(jump),
        .JALROn(JALROn)
    );

    // Register File instantiation (asynchronous read, synchronous write)
    reg_file new_regfile (
        .clk(clk),
        .WE3(RegWriteW),
        .AD1(AD1),
        .AD2(AD2),
        .AD3(RdW),
        .WD3(ResultW),
        .RD1(RD1), //ALUop1 before
        .RD2(RD2),
        .a0(a0)
    ); 

    // Sign Extend instantiation
    signextend new_sign_extend (
        .instr(InstrD),
        .IMMSrc(IMMSrc),
        .ImmOp(ImmOp)
    );


    // Execute-Memory pipeline stage
    pipeline_e_m new_pipeline_e_m (
        .clk(clk),//
        .RegWriteE(RegWriteE),//
        .ResultSrcE(ResultSrcE),//
        .MemWriteE(MemWriteE),//
        .ALUResultE(SUM),//
        .WriteDataE(WriteDataE),//
        .RdE(RdE),//
        .PCPlus4E(PCPlus4E),//
        .MemCtrlE(MemCtrlE),
        .JALROnD(JALROn),

        .RegWriteM(RegWriteM),//
        .ResultSrcM(ResultSrcM),//
        .MemWriteM(MemWriteM),//
        .ALUResultM(ALUResultM),//
        .WriteDataM(WriteDataM),//
        .RdM(RdM),//
        .MemCtrlM(MemCtrlM),
        .JALROnE(JALROnE),
        .PCPlus4M(PCPlus4M)//
    );

    // ALU instantiation
    alu new_alu (
        .ALUop1(SrcAE),
        .ALUop2(SrcBE),
        .ALUCtrl(ALUControlE),
        .EQ(ZeroE),
        .SUM(SUM)
    );

    mux src_BE_mux (
        .in0(WriteDataE),
        .in1(ImmExtE),
        .sel(ALUSrcE),

        .out(SrcBE)
    );

    mux2 forwardAE_mux (
        .in0_2(RD1E),
        .in1_2(ResultW), // later hazard
        .in2_2(ALUResultM),
        .sel_2(ForwardAE), // later hazard

        .out_2(SrcAE)
    );

    mux2 forwardBE_mux (
        .in0_2(RD2E),
        .in1_2(ResultW), // later hazard
        .in2_2(ALUResultM),
        .sel_2(ForwardBE), // later hazard

        .out_2(WriteDataE)
    );

    // Memory-Writeback pipeline stage
    pipeline_m_w new_pipeline_m_w (
        .clk(clk),//
        .ALUResultM(ALUResultM),//
        .RD(rd),//
        .RdM(RdM),//
        .PCPlus4M(PCPlus4M),//
        .RegWriteM(RegWriteM),//
        .ResultSrcM(ResultSrcM),//

        .ALUResultW(ALUResultW),//
        .ReadDataW(ReadDataW),//
        .RdW(RdW),//
        .PCPlus4W(PCPlus4W),//
        .RegWriteW(RegWriteW),//
        .ResultSrcW(ResultSrcW)//
    );

    data_memory new_data_memory (
        .clk (clk),
        .MemCtrl (MemCtrlM),
        .addr (ALUResultM),
        .we (MemWriteM),
        .wd (WriteDataM),
        .rd (rd)
    );

    //This is implemented in top_pc
    // branch_add branch_adder (
    //     .PCE(PCE),             // Connected to the Execute stage program counter
    //     .ExtImmE(ImmExtE),      // Connected to the Execute stage extended immediate
    //     .BranchAddrE(PCTargetE) // Output branch address
    // );

    mux2 new_write_back_mux (
        .in0_2(ALUResultW),
        .in1_2(ReadDataW),
        .in2_2(PCPlus4W),
        .sel_2(ResultSrcW),

        .out_2(ResultW)
    );

    hazard_unit new_hazard_unit (
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),//
        .Rs2E(Rs2E),//
        .RdE(RdE),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .MemRead(MemReadE),
        .ZeroE(ZeroE),
        .jump(JumpE),

        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .stall(stall),
        .flush(flush)
    );
  

endmodule
