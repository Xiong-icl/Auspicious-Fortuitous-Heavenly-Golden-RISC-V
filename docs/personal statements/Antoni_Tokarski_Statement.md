# RISC-V RV32I Processor Coursework
## Statement of Contributions
### Antoni Tokarski

Github commits under: root, Antonio's

Most of my commits are under 'root' as they were made through the terminal and I had not signed into my github account locally.


## Overview

Most of my work involved writing system verilog modules, I also became involved with the debuging of the cpu towards the end of the project.

## Contributions

- [Program Counter](#program-counter)
- [Data Memory](#data-memory)
- [Pipelining](#pipelining)
- [Finite State Machine](#two-way-set-associative-cache--fsm)
- [Two-way Set Associative Cache](#two-way-set-associative-cache--fsm)
- [PDF & F1 Lights Debugging](#debugging)
- [Additional Comments](#misc)

## Program Counter

I created the program counter module, it was then systematically updated as the coursework continued. The only major design choice was changing it so that it it utilised the mux module instead of its own internal logic and later splitting it up into sub-modules, which would later be combined into top_pc.

### Original implementation of the PC which was later abstracted to top_pc 
'''
module program_counter (
    input logic clk,          // Clock signal
    input logic rst,          // Reset signal 
    input logic [31:0] ImmOp, // Immediate operand for branch branch_PC
    input logic PCSrc,        // Choice between branch and incremented PC
    output logic [31:0] PC    // Current PC value
);

// Internal signals
logic [31:0] inc_PC;    // PC + 4
logic [31:0] branch_PC; // PC + ImmOp
logic [31:0] next_PC;   // The one we choose


assign inc_PC = PC + 4; // Normal increment
assign branch_PC = PC + ImmOp; // Branch increment
assign next_PC = (PCSrc) ? branch_PC : inc_PC; // The one we feed to PC Reg

// PC Register
always_ff @(posedge clk or posedge rst)
    if (rst) PC <= 32'b0; // Reset
    else PC <= next_PC; // Update


endmodule
'''


## Data Memory

I wrote the data memory module once we began working on the real cpu after lab 4. Over the course of the project it went through several improvements. It began with only word access but this was later expanded to all 5 access types availible. At a certain point there was also internal stall logic introduced to help with the cache but this was later scrapped as it turned out to be unnessecary due to the nature of system verilog.

### data memory before cache
'''
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
'''
'''
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
'''

### The unused latency logic
'''
    // Simulated latency logic
     logic [1:0] latency_counter; // Latency counter to simulate delay
    // Initialize latency counter and ready signal
     initial begin
         ready = 1; // Ready by default
         latency_counter = 0;
     end
    // Memory operation request (either read or write)
     logic read_request;
     assign read_request = !we; // Any non-write operation is considered a read
    // Reads are instantaneous, writes take 1 clock cycle to complete
    // Latency and ready signal management
     always_ff @(posedge clk) begin
         if (we) begin
             // Write operation
             if (latency_counter == 0) begin
                 latency_counter <= 2'd1; // Simulate a delay of 1 clock cycle for writes
                 ready <= 0; // Not ready during the delay
             end else if (latency_counter > 0) begin
                 latency_counter <= latency_counter - 1; // Decrement counter
             end else begin
                 latency_counter <= 0; // Reset counter after delay
                 ready <= 1; // Ready when delay completes
             end
         end else if (read_request) begin
             // Read operation is instantaneous
             latency_counter <= 0; // Ensure counter is reset
             ready <= 1; // Always ready for reads
         end else begin
             ready <= 1; // Default to ready if no operation is in progress
         end
     end
'''


## Pipelining

I wrote the memory-writeback pipeline module but as it turned out that all the modules shared an extremly similar structure we decided to have them standardized by Antoni Steglinski. I was also responsible for the initial implementation of the top module for the pipelined cpu but as I was not fully aware of the hazard unit's functioning as well as some other details of the cpu's functioning it was finalized by Xiong Yi Loh.

The implementation was based almost in its entirety on the diagrams we were provided in class:

![implementation](/images/pipelinepc.png)


## Two-Way Set Associative Cache & FSM

The initial structure of the cache was done by Soong En Wong however it was my job to make it fully functional. I added things such as the dirty bit logic and the ready signal to facilitate better cohesion between the data memory and cache. I also wrote the first implementation of the Finite State Machine that our cache uses to track fetch operations. My implementation was then formalized and made much more clear by Xiong Yi Loh who introduced me to the more efficient implementation of the state machine present in the final version of the cpu.

![2waycache](/images/2waycache.png)

<details>

<summary>Original Cache Implementation</summary>

'''
module data_mem_cache #(
        parameter ADDR_WIDTH = 32,
        parameter DATA_WIDTH = 32
    ) (
        input  logic clk,
        input  logic write_en,
        input  logic read_en,
        input  logic [2:0] addr_mode,
        input  logic [ADDR_WIDTH-1:0] addr,
        input  logic [DATA_WIDTH-1:0] write_data,
        output logic hit,
        output logic stall,
        output logic ready,
        output logic [DATA_WIDTH-1:0] out
    );
    typedef struct packed {
        logic valid;
        logic dirty;  // Indicates if the data has been written but not propagated to memory
        logic [26:0] tag;
        logic [31:0] data;
        logic lru;
    } cache_line;
    cache_line cache [2][4];  // 2 ways, 4 sets
    logic [DATA_WIDTH-1:0] read_data;
    logic [26:0] tag;
    logic [1:0] set;
    logic way_select;         // Determines which way to use for replacement
    logic fetch_in_progress;  // Indicates an ongoing memory fetch
    logic write_back_in_progress; // Indicates a dirty write-back is ongoing
    logic memory_ready;       // Signals when fetched or written data is valid
    logic [1:0] invalid_way;  // Tracks an invalid way in the set, if any
    logic [ADDR_WIDTH-1:0] evicted_addr; // Address for dirty-line write-back
    initial begin
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 4; j++) begin
                cache[i][j].valid = 0;
                cache[i][j].dirty = 0;
                cache[i][j].lru = 0;
                cache[i][j].tag = 27'b0;
                cache[i][j].data = 32'b0;
            end
        end
        fetch_in_progress = 0;
        write_back_in_progress = 0;
        memory_ready = 0;
    end
    // State tracking for stalls and ready signals
    assign stall = fetch_in_progress || write_back_in_progress;
    assign ready = !(fetch_in_progress || write_back_in_progress);
    // Address decoding
    always_comb begin
        way_select = 0; // Default value to avoid latch inference warning
        tag = addr[31:5];
        set = addr[4:3];
        // Check for cache hit in both ways
        if (cache[0][set].valid && cache[0][set].tag == tag) begin
            hit = 1;
            way_select = 0;
            out = cache[0][set].data;
        end else if (cache[1][set].valid && cache[1][set].tag == tag) begin
            hit = 1;
            way_select = 1;
            out = cache[1][set].data;
        end else begin
            hit = 0;
            out = 0;
        end
    end
    // Cache read/write and miss handling logic
    always_ff @(posedge clk) begin
        if (write_en && !fetch_in_progress && !write_back_in_progress) begin
            // Write to cache and propagate to memory
            if (hit) begin
                // Update cache data
                cache[way_select][set].data <= write_data;
                cache[way_select][set].dirty <= 1; // Mark as modified
                // Update LRU
                cache[way_select][set].lru <= 0;
                cache[~way_select][set].lru <= 1;
            end else begin
                // Miss: Select invalid way or use LRU
                if (!cache[0][set].valid) begin
                    way_select = 0;
                end else if (!cache[1][set].valid) begin
                    way_select = 1;
                end else begin
                    way_select = cache[0][set].lru;
                end
                // Handle dirty write-back if necessary
                if (cache[way_select][set].dirty) begin
                    write_back_in_progress <= 1;
                    evicted_addr <= {cache[way_select][set].tag, set, 3'b000};
                    memory_ready <= 0; // Await write-back completion
                end else begin
                    fetch_in_progress <= 1; // Stall until memory fetch is complete
                    memory_ready <= 0;  // Awaiting data validity
                end
            end
        end else if (read_en && !fetch_in_progress && !write_back_in_progress) begin
            if (!hit) begin
                // Miss: Select invalid way or use LRU
                if (!cache[0][set].valid) begin
                    way_select = 0;
                end else if (!cache[1][set].valid) begin
                    way_select = 1;
                end else begin
                    way_select = cache[0][set].lru;
                end
                // Handle dirty write-back if necessary
                if (cache[way_select][set].dirty) begin
                    write_back_in_progress <= 1;
                    evicted_addr <= {cache[way_select][set].tag, set, 3'b000};
                    memory_ready <= 0; // Await write-back completion
                end else begin
                    fetch_in_progress <= 1;
                    memory_ready <= 0;
                end
            end else begin
                // Read hit: Update LRU
                cache[way_select][set].lru <= 0;
                cache[~way_select][set].lru <= 1;
            end
        end
        // Handle write-back completion
        if (memory_ready && write_back_in_progress) begin
            write_back_in_progress <= 0;
            // Start fetching the required data after dirty write-back
            fetch_in_progress <= 1;
            memory_ready <= 0;
        end
        // Handle data fetch completion
        if (memory_ready && fetch_in_progress) begin
            // Update cache line
            cache[way_select][set].valid <= 1;
            cache[way_select][set].tag <= tag;
            cache[way_select][set].data <= read_data;
            cache[way_select][set].dirty <= 0;
            // Reset fetch state
            fetch_in_progress <= 0;
            // Update LRU
            cache[way_select][set].lru <= 0;
            cache[~way_select][set].lru <= 1;
        end
    end
    // Memory module interface for dirty-line write-back or data fetch
    data_memory data_mem_inst (
        .clk(clk),
        .funct3(addr_mode),
        .addr(write_back_in_progress ? evicted_addr : addr),
        .wd(write_back_in_progress ? cache[way_select][set].data : write_data),
        .we(write_back_in_progress || (write_en && !hit)), // Write to memory on dirty eviction or write miss
        .rd(read_data),
        .ready(memory_ready)
    );
endmodule
'''

</details>


## Debugging

Towards the end of the project I focused my efforts on helping debug the the pipelined and cached versions of the cpu. It was mostly minor fixes in some of the of the simulation and sv modules.


## Misc.

### Reflections on my Work
Overall I believe this project to have been a good experience both in terms of developing my technical skills and teamwork. If I had the chance to do somthing differently perhaps it would be to do more reaserch before engaging in writing some of the more complicated parts of the cpu. I would also have liked to engage more with the testing side of the project as even though debugging is very tedious it provides one with a greater understanding of the overall project.

### The Team
I just wanted to thank everyone for their contributions this project wouldn't have been possible without you guys. Major thanks to Xiong Yi Loh you put in an amazing amount of effort and this project would not have been doable without your work.


