module pipeline_f_d #(
    parameter   DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic                     stall,
    input logic                     flush,
    input logic [DATA_WIDTH -1:0]   InstrF,  
    input logic [DATA_WIDTH -1:0]   PCF,  
    input logic [DATA_WIDTH -1:0]   PCPlus4F, 
    output logic[DATA_WIDTH -1:0]   InstrD,
    output logic[DATA_WIDTH -1:0]   PCD,
    output logic[DATA_WIDTH -1:0]   PCPlus4D
);

    always_ff @(posedge clk) begin
        if(flush) begin
            InstrD <= 0;
            PCD <= 0;
            PCPlus4D <= 0;
        end
        else if(!stall) begin
            InstrD <= InstrF;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end

endmodule
