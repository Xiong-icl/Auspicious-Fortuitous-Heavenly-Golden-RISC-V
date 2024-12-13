module top_pc (
    input  logic            clk,          // Clock signal
    input  logic            rst,          // Reset signal
    input  logic [31:0]     ImmOp,        // Immediate operand for branch
    input  logic [31:0]     PCTargetE, // Branch/jump target from Execute stage
    input  logic            JALROn,
    input  logic [31:0]     RD1E,
    input  logic            PCSrc,        // Choice between branch and incremented PC
    input  logic [31:0]     PCE,
    output logic [31:0]     inc_PC,        // PCPlus4
    output logic [31:0]     PC            // Current PC value
);

    // Internal signals
    logic [31:0] branch_PC; // PC + ImmOp
    logic [31:0] rs1_PC;
    logic [31:0] next_PC;   // Output from mux
    logic [31:0] pctarget_result;

    // Assignments
    always_comb begin 
        inc_PC = PC + 4; // Normal increment
        branch_PC = PCE + ImmOp; // Use the branch/jump target calculated in the Execute stage
        rs1_PC = RD1E + ImmOp;
    end

    program_counter pc (
        .clk(clk),
        .next_PC(next_PC),
        .PC(PC)
    );

    //Mux is in E block
    mux new_immop_mux (
        .in0(branch_PC),
        .in1(rs1_PC),
        .sel(JALROn),
        .out(pctarget_result)
    );

    mux #(.DATA_WIDTH(32)) pc_mux (
        .in0(inc_PC),           // Incremented PC
        .in1(pctarget_result),  // Branch PC
        .sel(PCSrc),            // Select signal
        .out(next_PC)       
    );



endmodule

