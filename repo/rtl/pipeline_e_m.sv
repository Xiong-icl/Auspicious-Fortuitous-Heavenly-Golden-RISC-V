module pipeline_e_m #(
    parameter   DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic [DATA_WIDTH -1:0]   ALUResultE,  
    input logic [DATA_WIDTH -1:0]   WriteDataE,
    input logic [4:0]               RdE,
    input logic [DATA_WIDTH -1:0]   PCPlus4E,
    input logic         RegWriteE,
    input logic [1:0]   ResultSrcE,
    input logic         MemWriteE,
    input logic         MemReadE,
    input logic [2:0]   MemCtrlE,
    input logic         JALROnD,
    output logic [DATA_WIDTH -1:0]  ALUResultM,
    output logic [DATA_WIDTH -1:0]  WriteDataM,
    output logic [4:0]              RdM,
    output logic [DATA_WIDTH -1:0]  PCPlus4M,
    output logic        RegWriteM,
    output logic [1:0]  ResultSrcM,
    output logic        MemWriteM,
    output logic [2:0]  MemCtrlM,
    output logic        MemReadM,
    output logic         JALROnE
);


    always_ff @(posedge clk) begin
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        RdM <= RdE;
        PCPlus4M <= PCPlus4E;
        RegWriteM <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM <= MemWriteE;
        MemReadM <= MemReadE;
        MemCtrlM <= MemCtrlE;
        JALROnE <= JALROnD;
    end

endmodule
