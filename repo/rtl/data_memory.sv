
module data_memory #(
    parameter DATA_WIDTH = 32,  // Width of data
    parameter ADDR_WIDTH = 32,    // Width of address
    parameter MEM_WIDTH = 8      // Width of memory
) (
    input  logic                  clk,        
    input  logic [ADDR_WIDTH-1:0] addr,       // Address
    input  logic                  we,         // Write Enable
    input   logic   [2:0]               MemCtrl,
    input   logic                       MemRead,
    input  logic [DATA_WIDTH-1:0] wd,         // Write Data
    output logic [DATA_WIDTH-1:0] rd,          // Read Data
    output  logic                 ready

);

    // 0x00000000 - 0x0001FFFF data array == 128 KB memory & 17-bit addressing
    logic [MEM_WIDTH-1:0] array [2**17:0]; // Each word is 8 bits / 1 byte

    //Loading memory from data.hex into data_memory
    initial begin
        $display("Loading data into data memory...");
        $readmemh("data.hex", array);
    end




    // Asynchronous read logic based on funct3
    always_latch begin 
        if(MemRead || we) begin 
            ready = 1;
        end
        else begin 
            ready = 0;
        end
        if(MemRead) begin
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
    end




    // Synchronous write
    always_ff @(posedge clk) begin
        if (we & (MemCtrl == 3'b000)) begin 
            array[addr] <= wd[7:0]; // Lowest byte
        end 
        else if (we) begin
            array[addr]   <= wd[7:0];       // Lower byte
            array[addr+1] <= wd[15:8];      // Second byte
            array[addr+2] <= wd[23:16];     // Third byte
            array[addr+3] <= wd[31:24];     // Upper byte
        end
    end

endmodule
