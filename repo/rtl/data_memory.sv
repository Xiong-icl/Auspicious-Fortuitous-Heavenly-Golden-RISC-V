module data_memory #(
    parameter DATA_WIDTH = 32,  // Width of data
    parameter ADDR_WIDTH = 32,    // Width of address
    parameter MEM_WIDTH = 8      // Width of memory
) (
    input  logic                  clk,
    input logic [2:0]             MemCtrl,        
    input  logic [ADDR_WIDTH-1:0] addr,       // Address
    input  logic                  we,         // Write Enable
    input  logic [DATA_WIDTH-1:0] wd,         // Write Data
    output logic [DATA_WIDTH-1:0] rd          // Read Data
);



    // 0x00000000 - 0x0001FFFF data array == 128 KB memory & 17-bit addressing
    logic [MEM_WIDTH-1:0] array [2**17:0]; // Each word is 8 bits / 1 byte

    //Loading memory from data.hex into data_memory
    initial begin
        $display("Loading data into data memory...");
        $readmemh("data.hex", array, 65536);
    end

    // Asynchronous read: 4 consecutive 8-bit locations combine into a 32-bit word
    always_ff @* begin 

        // $display("Memory Read Addresses and Values:");
        // $display("Address Byte 0: 00010000, Value: %h", array[18'h10000]);
        // $display("Address Byte 1: 00010001, Value: %h", array[18'h10001]);
        // $display("MemCtrl: %b", MemCtrl);
        if(MemCtrl == 3'b000) begin 

            rd = {{24{array[addr][7]}}, array[addr]}; 
        end
        if(MemCtrl == 3'b011) begin 

            rd = {24'b0, array[addr[17:0]]};
        end
        else begin 
            rd = {array[addr+3], array[addr+2], array[addr+1], array[addr]};
        end
    end

    // always_ff @* begin 
    //     $display("Memory Address:");
    //     $display("Address Byte 0: 10000, Value: %h", array [18'h10000]);
    //     $display("Address Byte 1: 10001, Value: %h", array [18'h10001]);
    // end

    // Synchronous write: Writes a 32-bit word to a word
    always_ff @(posedge clk)
        if (we & (MemCtrl == 3'b000)) begin 
            array[addr] <= wd[7:0]; // Lowest byte
        end 
        else if (we) begin
            array[addr]   <= wd[7:0];       // Lower byte
            array[addr+1] <= wd[15:8];      // Second byte
            array[addr+2] <= wd[23:16];     // Third byte
            array[addr+3] <= wd[31:24];     // Upper byte
        end
endmodule
