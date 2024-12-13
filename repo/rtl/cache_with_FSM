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
