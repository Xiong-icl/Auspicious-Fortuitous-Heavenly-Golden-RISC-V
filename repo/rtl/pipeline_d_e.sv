module pipeline_d_e #(
    parameter   DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic                     flush,
    input logic                     stall,
    input logic [DATA_WIDTH -1:0]   RD1,  
    input logic [DATA_WIDTH -1:0]   RD2, 
    input logic [DATA_WIDTH -1:0]   PCD,  
    input logic [4:0]               RdD,  
    input logic [DATA_WIDTH -1:0]   ImmExtD,
    input logic [DATA_WIDTH -1:0]   PCPlus4D,
    input logic                     RegWriteD,
    input logic [1:0]               ResultSrcD,  
    input logic                     MemWriteD,
    input logic                     JumpD,            
    input logic                     BranchD,
    input logic [4:0]               ALUControlD,  
    input logic                     ALUSrcD,
    input logic                     MemReadD,
    input logic [2:0]               MemCtrlD,
    input logic [19:15]             Rs1D,
    input logic [24:20]             Rs2D,

    output logic [DATA_WIDTH -1:0]  RD1E,
    output logic [DATA_WIDTH -1:0]  RD2E,
    output logic [DATA_WIDTH -1:0]  PCE,
    output logic [4:0]              RdE,
    output logic [DATA_WIDTH -1:0]  ImmExtE,
    output logic [DATA_WIDTH -1:0]  PCPlus4E,
    output logic                    RegWriteE,
    output logic [1:0]              ResultSrcE,
    output logic                    MemReadE,
    output logic                    MemWriteE,
    output logic                    JumpE,
    output logic                    BranchE,
    output logic [4:0]              ALUControlE,
    output logic                    ALUSrcE,
    output logic [2:0]              MemCtrlE,
    output logic [19:15]            Rs1E,
    output logic [24:20]            Rs2E
);

    always_ff @(posedge clk) begin

        //Write enabled when neither flush nor stall is on
        if(!flush && !stall) begin
            MemWriteE <= MemWriteD;
            JumpE <= JumpD;
            BranchE <= BranchD;
            RegWriteE <= RegWriteD;
            RD1E <= RD1;
            RD2E <= RD2;
            PCE <= PCD;
            RdE <= RdD;
            ImmExtE <= ImmExtD;
            PCPlus4E <= PCPlus4D;
            MemReadE <= MemReadD; 
            ResultSrcE <= ResultSrcD;
            ALUControlE <= ALUControlD;
            ALUSrcE <= ALUSrcD;
            MemCtrlE <= MemCtrlD;
            Rs1E <= Rs1D;
            Rs2E <= Rs2D;
            
        end
        else begin 
            MemWriteE <= 0;
            JumpE <= 0;
            BranchE <= 0;
            RegWriteE <= 0;
            RD1E <= 0;
            RD2E <= 0;
            PCE <= 0;
            RdE <= 0;
            ImmExtE <= 0;
            PCPlus4E <= 0;
            MemReadE <= 0; 
            ResultSrcE <= 0;
            ALUControlE <= 0;
            ALUSrcE <= 0;
            MemCtrlE <= 0;
            Rs1E <= 0;
            Rs2E <= 0;
        end
    end

endmodule
