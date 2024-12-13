# Soong En Wong's RISC-V RV321 Processor (Personal Statement)
## Personal Details:
- Name: Soong En Wong
- CID: 02321231
- Github Username: soongenwong
## Contributions:
1. Instruction Memory
2. Sign Extend
3. Control Unit
4. Top
5. Pipeline Stages
6. Two-way set associative cache

## Summary: 
I contributed to the development of a pipelined RISC-V RV32I processor, focusing on six critical components. My primary responsibilities included:

- Designing and implementing the Instruction Memory module for efficient instruction fetching and storage
- Creating the Sign Extension unit to handle immediate values and branch offsets
- Developing the Control Unit to generate appropriate control signals for instruction execution
- Integrating processor components in the Top module to ensure proper interconnection
- Implementing the five pipeline stages (IF, ID, EX, MEM, WB) to enhance processor performance
- Designing a two-way set associative cache to improve memory access times

Throughout this project, I applied key computer architecture concepts including pipelining, memory hierarchy, and digital design principles. I utilized SystemVerilog for implementation and verification, ensuring each component met the required specifications through comprehensive testing.

This experience enhanced my learning capacity to pick up a new programming language in a relatively short amount of time, and improved my ability to work cohesively as a team to achieve a desirable result. 

Additional Info: The commit history that says "3 files for green section" was just the first commit that i have made to the main. Further updates and changes were made to different branches that i have added throughout the project. 

!["Single Cycle"](/images/single_cycle.png)

## 1. Instruction Memory

I designed and implemented the instruction memory module, a crucial component responsible for storing and fetching instructions in the RISC-V processor. Key features of my implementation include:

- Parameterized design allowing flexible configuration of address width (32-bit), data width (8-bit), and instruction width (32-bit)
- Memory organization using byte-addressable architecture, with instructions stored across four consecutive bytes
- Implementation of word-aligned access enforcement through assertion checking
- Efficient instruction fetching using concatenation of four bytes to form 32-bit RISC-V instructions
- Support for hexadecimal program loading through $readmemh for easy program modification

The module includes error checking to ensure proper word-aligned memory access, which is crucial for maintaining processor integrity. I implemented the memory as a byte-addressable array, following RISC-V's little-endian memory organization, where instructions are stored across four consecutive memory locations.

Technical implementation details:

- Used SystemVerilog arrays to create the memory structure
- Implemented assertion statements for runtime error checking
- Utilized concatenation operations for proper byte ordering
- Included debugging support through system tasks for memory verification

```
module instrmem #(
    parameter ADDRESS_WIDTH = 32,
              DATA_WIDTH = 8,
              INSTR_WIDTH = 32
) (
    input  logic [ADDRESS_WIDTH-1:0] A, // address input
    output logic [INSTR_WIDTH-1:0] RD   // instruction output
);

    logic [DATA_WIDTH-1:0] array [0:2**12-1]; // memory array

    initial begin
        $display("Loading data into data memory...");
        $readmemh("../rtl/program.hex", array);
    end
    
    assign RD = {array[A + 3], array[A + 2], array[A + 1], array[A]};

    initial begin
        $display("RD is", RD);
    end
    
    always @(A) begin
        assert (A[1:0] == 2'b00) else
            $error("Instruction fetch from non-word-aligned address");
    end

endmodule
```

## 2. Sign Extend

I implemented the Sign Extension module, a vital component that handles immediate value generation for different RISC-V instruction formats. This module performs crucial data manipulation for instruction execution. Key aspects of my implementation include:

Support for all RISC-V immediate formats:

- I-type (loads and ALU immediate operations)
- S-type (store instructions)
- B-type (branch instructions)
- U-type (LUI and AUIPC instructions)
- J-type (jump instructions)
- Special format for handling register fields

Key features:

- Combinational logic design using always_comb for immediate response
- 3-bit IMMSrc control signal to select between different immediate formats
- Proper sign extension for signed values to maintain arithmetic correctness
- Default case handling for error prevention
- Bit manipulation for various instruction formats following RISC-V specifications

```
`include "define.sv"
module signextend (
    /* verilator lint_off UNUSED */
    input logic [31:0] instr,
    /* verilator lint_on UNUSED */
    input  logic [2:0]  IMMSrc,    // Immediate format selector
    output logic [31:0] ImmOp      // Sign-extended immediate output
);

    always_comb begin
        case(IMMSrc)
            // I-type: Load, ALU immediate
            3'b000: begin
                ImmOp = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type: Store
            3'b001: begin
                ImmOp = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: Branch
            3'b010: begin
                ImmOp = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // U-type: LUI, AUIPC
            3'b011: begin
                ImmOp = {instr[31:12], 12'b0};
            end

            // J-type: JAL
            3'b100: begin
                ImmOp = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            3'b101: begin 
                ImmOp = {{27'b0}, instr[24:20]};
            end

            // Default case
            default: begin
                ImmOp = 32'b0;
            end
        endcase
    end

endmodule
```

## 3. Control Unit

I developed the initial Control Unit for our Single Cycle CPU but it was further modified by Xiong Yi to integrate the different modules that we have on our RTL.

Technical Implementation Features:

- Efficient instruction decoding using opcode, funct3, and funct7 fields
- Comprehensive case structure for instruction handling
- Default signal initialization for safety
- Error checking and reporting functionality
- Modular design with clear signal organization

## 4. Top

For our top.sv file, i was in charged of putting together the different modules of System Verilog files, pipeline files and 2-way set associative cache file that I have written into the final top.sv file to be implemented. 

![pipeline](/images/pipelinepc.png)

## 5. Pipeline Stages

We implemented the five classic RISC-V pipeline stages, enhancing processor performance through parallel instruction execution. 
Key Pipeline Stages:

- Instruction Fetch (IF): Instruction retrieval from memory/cache
- Instruction Decode (ID): Instruction decoding and register read
- Execute (EX): ALU operations and address calculations
- Memory (MEM): Data memory access operations
- Write Back (WB): Result writing to register file

!["Cache"](/images/2waycache.png)

## 6. Two-way set associative cache

I implemented a two-way set associative cache, enhancing memory access performance. My teammates, Antoni Tokarski and Xiong Yi, implemented the FSM control. 

Cache Architecture:

- Two-way set associative design with 4 sets
- FSM-controlled cache operations
- LRU (Least Recently Used) replacement policy
- Support for dirty bit handling and write-back policy

Cache Structure:

- Valid and dirty bit tracking
- 28-bit tag, 32-bit data storage
- LRU bit for replacement decisions
- Structured cache line organization using SystemVerilog structs

```
module cache_with_FSM #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic we,
    input  logic MemRead,
    input  logic [2:0] MemCtrl,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] wd,
    // output logic CacheStall,
    output logic [DATA_WIDTH-1:0] out
);

// Cache line structure
typedef struct packed {
    logic valid;            
    logic dirty;
    logic [27:0] tag;
    logic [31:0] data;
    logic lru;
} cache_line;

// Cache storage: 2 ways, 4 sets
cache_line cache [2][4];

// FSM state encoding
typedef enum logic [1:0] { Idle, Compare, Allocate, WriteBack } fsm_state_t;
fsm_state_t current_state, next_state;

// Signals and registers
logic [DATA_WIDTH-1:0] read_data;       // Memory data read
logic [27:0] tag;                       // Address tag
logic [1:0] set;                        // Cache set index
logic way_select;                       // Way selection signal (2-way set associative cache)
logic fetch_in_progress;                // Fetch flag from memory
logic write_back_in_progress;           // Write-back flag
logic memory_ready;                     // Memory ready flag
logic hit;                              // Cache hit flag
logic [ADDR_WIDTH-1:0] evicted_addr;    // Address for eviction

// Address decoding and hit detection
always_comb begin
    tag = addr[31:4];
    set = addr[3:2];
    hit = 0;
    way_select = 0;
    out = 0;

    // Check both ways for a hit
    if (cache[0][set].valid && cache[0][set].tag == tag) begin
        hit = 1;
        way_select = 0;
        out = cache[0][set].data;
    end else if (cache[1][set].valid && cache[1][set].tag == tag) begin
        hit = 1;
        way_select = 1;
        out = cache[1][set].data;
    end
    else begin 
        hit = 0;
        out = read_data;
    end
end



// FSM and cache control logic
always_ff @(posedge clk) begin
    current_state <= next_state;

    case (current_state)
        Idle: begin
            if (MemRead || we) begin
                next_state <= Compare;
            end else begin
                next_state <= Idle;
            end
        end

        Compare: begin
            if (hit) begin
                if (we) begin
                    // Update cache with new data and set dirty bit
                    cache[way_select][set].data <= wd;
                    cache[way_select][set].dirty <= 1;
                    cache[way_select][set].lru <= 0;
                    cache[~way_select][set].lru <= 1; // Set other way as least recently used
                    next_state <= Idle;
                end
            end else if (!hit && cache[way_select][set].dirty) begin
                // Transition to WriteBack state for dirty block
                next_state <= WriteBack;
                write_back_in_progress <= 1;
                evicted_addr <= {cache[way_select][set].tag, set, 2'b00};
            end else begin
                // Transition to Allocate state for clean block
                next_state <= Allocate;
                fetch_in_progress <= 1;
            end
        end

        Allocate: begin
            if (memory_ready) begin
                // Allocate new block in cache
                cache[way_select][set].valid <= 1;
                cache[way_select][set].tag <= tag;
                cache[way_select][set].data <= read_data;
                cache[way_select][set].dirty <= 0;
                fetch_in_progress <= 0;
                next_state <= Compare;
            end
            else begin 
                next_state <= current_state;
            end
        end

        WriteBack: begin
            if (memory_ready) begin
                // Complete write-back operation
                write_back_in_progress <= 0;
                fetch_in_progress <= 1; // Start fetching new block
                next_state <= Allocate;
            end
            else begin 
                next_state <= current_state;
            end
        end

        default: begin
            next_state <= Idle; // Fallback to Idle
        end
    endcase
    // CacheStall = fetch_in_progress || write_back_in_progress || (we && !hit);
end

// Memory module interface
data_memory new_data_memory (
    .clk(clk),
    .MemCtrl(MemCtrl),
    .addr(write_back_in_progress ? evicted_addr : addr),
    .wd(write_back_in_progress ? cache[way_select][set].data : wd),
    .we(write_back_in_progress || (we && !hit)),
    .MemRead(fetch_in_progress),
    .rd(read_data),
    .ready(memory_ready)
);

endmodule
```

## Reflection 

I have learnt a lot from this experience of building a full RV 321 design with pipeline and cache, in terms of technical knowledge and working together as a team. From writing System Verilog modules on the RTL to ensuring that the modules pass the tests on the testbenches, every code section on this project has to work well together. It taught me the importance of paying attention to the smallest of details to minimise the errors that we enocunter when building long and complex projects. 

In terms of technical growth, i gained a deep understanding of processor architecture and system integration challenges. For professional development, I learnt project planning and problem solving in complex systems. 

## What I would have done differently

If given a second opportunity to work on this project, it would be important to learn the material well beforehand (from textbooks and documents) and divide the work between team members at the beginning of the project. This ensures that every member knows the technical aspects well and which sections they are in charged of at the start. 

Overall, I am grateful for this learning opportunity and particularly appreciate my teammates' dedication and support. This experience has provided a strong foundation for future projects and reinforced the importance of both technical excellence and effective teamwork.

