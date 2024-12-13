module reg_file #(
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
    output logic    [DATA_WIDTH -1:0]   a0
);
    logic [31:0] regs[31:0];
    
    //Should I define a0 like this?
    assign a0 = regs[10];

    always_comb begin
        RD1 = regs[AD1];
        RD2 = regs[AD2];
    end

    // Synchronous Write Port
    always_ff @(negedge clk) begin
        //Checking if both AD3 and WE3 are both 0
        if (WE3 & AD3 != 5'b0)
            //Assigning a0 as both blocking and nonblocking assignments, should be regs[AD3]
            regs[AD3] <= WD3;
    end

    always_ff @ (negedge clk) begin
        //     // $display("register 0: %d", ram_array[0]);
        //     // $display("t0: %d", ram_array[5]);
           // $display("t1: %d, t2: %d, a0: %d, a1: %d", regs[6], regs[7], regs[10], regs[11]);
        //     // $display("s1: %d", ram_array[8]);
            // $display("a0: %d", regs[10]);
            // $display("a1: %d", regs[11]);
        //     // $display("a2: %d", ram_array[12]);
        //     // $display("a3: %d", ram_array[13]);
        //     // $display("a4: %d", ram_array[14]);
        //     // $display("a5: %d", ram_array[15]);
        //     // $display("a6: %d", ram_array[16]);
    end
    
endmodule
