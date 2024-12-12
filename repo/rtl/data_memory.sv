
module data_memory #(
    parameter DATA_WIDTH = 32,  // Width of data
    parameter ADDR_WIDTH = 32,    // Width of address
    parameter MEM_WIDTH = 8      // Width of memory
) (
    input  logic                  clk,        
    input  logic [ADDR_WIDTH-1:0] addr,       // Address
    input  logic                  we,         // Write Enable
    input  logic [2:0]            funct3,     // Memory access type
    input  logic [DATA_WIDTH-1:0] wd,         // Write Data
    output logic [DATA_WIDTH-1:0] rd          // Read Data
);

    // 0x00000000 - 0x0001FFFF data array == 128 KB memory & 17-bit addressing
    logic [MEM_WIDTH-1:0] array [0:2**17-1]; // Each word is 8 bits / 1 byte

    //Loading memory from data.hex into data_memory
    initial begin
        $display("Loading data into data memory...");
        $readmemh("data.hex", array, 65536);
    end


    // This separates the actual memory access logic (inside always_comb) from the external output rd
    logic [DATA_WIDTH-1:0] rd_temp;

    // Asynchronous read logic based on funct3
    always_comb begin
        case (funct3)
            3'b000: // Byte access : sign-extended
                rd_temp = {{24{array[addr][7]}}, array[addr]}; 
            3'b001: // Half-word access : sign-extended
                rd_temp = {{16{array[addr+1][7]}}, array[addr+1], array[addr]};
            3'b010: // Word access
                rd_temp = {array[addr+3], array[addr+2], array[addr+1], array[addr]};
            3'b100: // Byte access : zero-extended
                rd_temp = {24'b0, array[addr]};
            3'b101: // Half-word access : zero-extended
                rd_temp = {16'b0, array[addr+1], array[addr]};
            default: 
                rd_temp = 32'b0; // Default to zero if funct3 is invalid
        endcase
    end

    // In Verilog, the assign statement and procedural blocks like always_comb cannot directly drive the same signal
    assign rd = rd_temp;



    // Synchronous write
    always_ff @(posedge clk) begin
        if (we) begin
            case (funct3)
                3'b000: // Byte access
                    array[addr] <= wd[7:0]; // Lowest byte
                
                3'b001: // Half-word access
                begin
                    array[addr]     <= wd[7:0];   // Lower byte
                    array[addr+1]   <= wd[15:8]; // Upper byte
                end

                3'b010: // Word access
                begin
                    array[addr]     <= wd[7:0];    // Byte 0
                    array[addr+1]   <= wd[15:8];   // Byte 1
                    array[addr+2]   <= wd[23:16];  // Byte 2
                    array[addr+3]   <= wd[31:24];  // Byte 3
                end

                default: // Default to no operation or log an error
                    $display("Unsupported access type: funct3 = %b", funct3);
            endcase
        end
    end

endmodule
