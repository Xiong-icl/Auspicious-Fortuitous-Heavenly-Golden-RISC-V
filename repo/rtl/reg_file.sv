module reg_file#(
    parameter ADDRESS_WIDTH = 5,
    DATA_WIDTH = 32
)(
    input logic     clk,
    input logic     WE3, // write enable
    input logic     [ADDRESS_WIDTH-1:0] AD1, //address 1
    input logic     [ADDRESS_WIDTH-1:0] AD2, //address 2
    input logic     [ADDRESS_WIDTH-1:0] AD3, //address 3
    input logic     [DATA_WIDTH -1:0]   WD3, // write data(new sum from alu)
    output logic    [DATA_WIDTH -1:0]   RD1, // data output 1
    output logic    [DATA_WIDTH -1:0]   RD2, // data output 2
    output logic    [DATA_WIDTH -1:0]   a0   // 
);
    logic [31:0] regs[31:0];
 // Asynchronous Read Ports
    assign RD1 = regs[AD1];
    assign RD2 = regs[AD2];
    assign a0  = regs[AD3];

    // Synchronous Write Port
    always_ff @(posedge clk) begin
        if (WE3) 
            a0 <= WD3;
    end
endmodule
