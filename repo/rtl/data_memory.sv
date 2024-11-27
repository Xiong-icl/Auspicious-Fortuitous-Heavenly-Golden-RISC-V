module data_memory #(
    parameter DATA_WIDTH = 32,  // Width of data
    parameter ADDR_WIDTH = 17    // Width of address
    parameter MEM_WIDTH = 8      // Width of memory
) (
    input  logic                  clk,        
    input  logic [ADDR_WIDTH-1:0] addr,       // Address
    input  logic                  we,         // Write Enable
    input  logic [DATA_WIDTH-1:0] wd,         // Write Data
    output logic [DATA_WIDTH-1:0] rd          // Read Data
);

    // 0x00000000 - 0x0001FFFF data array == 128 KB memory & 17-bit addressing
    logic [MEM_WIDTH-1:0] array [0:2**17-1]; // Each word is 8 bits / 1 byte

    // Asynchronous read: 4 consecutive 8-bit locations combine into a 32-bit word
    assign rd = {array[addr+3], array[addr+2], array[addr+1], array[addr]};

    // Synchronous write: Writes a 32-bit word to a word
    always_ff @(posedge clk) begin
        if (we) begin
            array[addr]   <= wd[7:0];       // Lower byte
            array[addr+1] <= wd[15:8];      // Second byte
            array[addr+2] <= wd[23:16];     // Third byte
            array[addr+3] <= wd[31:24];     // Upper byte
        end
    end
endmodule

