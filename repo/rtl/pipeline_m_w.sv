module pipeline_m_w #(
    parameter   DATA_WIDTH = 32
)(
    input logic clk,
    input logic [DATA_WIDTH -1:0]  ALUResultM,  
    input logic [DATA_WIDTH -1:0]  RD,
    input logic [11:7]             RdM,
    input logic [DATA_WIDTH -1:0]  PCPlus4M,
    input logic RegWriteM,
    input logic [1:0] ResultSrcM,

    output logic[DATA_WIDTH -1:0] ALUResultW,
    output logic[DATA_WIDTH -1:0] ReadDataW,
    output logic [11:7]           RdW,
    output logic[DATA_WIDTH -1:0] PCPlus4W,
    output logic RegWriteW,
    output logic [1:0]ResultSrcW
);


    always_ff @(posedge clk) begin
        ALUResultW <= ALUResultM;
        ReadDataW <= RD;
        RdW <= RdM;
        PCPlus4W <= PCPlus4M;
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
    end

endmodule
