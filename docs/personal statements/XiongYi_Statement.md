# RISC-V Instruction Set Architecture Personal Statement

Name: Xiong Yi Loh <br>
Github commits under: root, XiongYi

## Contribution Summary

 - [Overview](#overview)
 - [Control Unit](#control-unit)
 - [PC top layer](#pc-top-layer)
 - [Testbenches](#testbenches)
 - [Integrating and Debugging Single Cycle CPU](#integrating-and-debugging-single-cycle-cpu)
 - [Hazard Unit](#hazard-unit)
 - [Integrating and Debugging Pipeline](#integrating-and-debugging-pipeline)
 - [FSM and Cache Unit](#fsm-and-cache-unit)
 - [Cache Unit](#cache-unit)
 - [Integrating and Debugging Cache](#integrating-and-debugging-cache)
 - [Repo Master](#repo-master)
 - [Final Words](#final-words)

## Overview

I was the team leader and main tester for all unit modules and for each stage of the CPU (Single Cycle, Pipeline, Cache). My job involved writing any necessary units, writing testbenches, integrating the modules for each stage and debugging them until tests 1-4 in verify.cpp passed. I was also the repo master for the Github used and managed the commits and branches used by the team.

## Control Unit

The initial Control Unit for lab 4 was created by Soong En, but it was heavily modified to implement all the instructions in the instruction set. A new control_and unit was created to implement the branch and jump flags into a mux to choose PC inputs. New additions include:
1. Creating a definition file to increase readability when coding.
2. Implementing the full instruction set past Lab 4, including Load, Store, Branch and Jump instructions.
3. A control_and unit that implements the AND gate with Zero and Branch flags as well as the OR gate with Jump.

```
module control_and (
    input   logic       branch,
    input   logic       Zero,
    input   logic       jump,
    output  logic       PCSrc
);
    assign PCSrc = ((branch & Zero) | jump);

endmodule
```

!["Control Gates"](/images/PCSrc.png)

Relevant commits: [Initial Control Unit for Lab 4](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/cd02e06df650a9b238abde7820a39861824d01be), [All instructions implemented in Control Unit](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/7eb5c417d0c036f5585c648d99a74179b4baa8bf), [Fixing JALR instruction](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/14313496c8e29850c8b290a78c772f24215c7313)

## PC top layer

The PC top layer was necessary for the JALR instruction, where I chose to implement by setting a JALR flag to choose between the PC + ImmOp and the rs1 + ImmOp. This provided the necessary abstraction to reduce the amount of modules within the top layer when debugging the single cycle cpu.

```
    always_comb begin 
        inc_PC = PC + 4; // Normal increment
        branch_PC = PC + ImmOp; // Branch increment
        rs1_PC = rs1 + ImmOp;
    end

    mux new_immop_mux (
        .in0(branch_PC),
        .in1(rs1_PC),
        .sel(JALROn),
        .out(pctarget_result)
    );

    mux #(.DATA_WIDTH(32)) pc_mux (
        .in0(inc_PC),           // Incremented PC
        .in1(pctarget_result),  // Branch PC
        .sel(PCSrc),            // Select signal
        .out(next_PC)       
    );
```

!["JALR Mux"](/images/JALR_mux.png)

Relevant commits: [Creating top_pc](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/3d891cda968b66b5138553494730b6c1e18bd82d#diff-fbc3fdf340d79c531fdf1e9b3b6a9c232ec6dea53b84ba27f8a3c8c1aa5e1643), [Implementing JALR in top_pc](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/14313496c8e29850c8b290a78c772f24215c7313#diff-fbc3fdf340d79c531fdf1e9b3b6a9c232ec6dea53b84ba27f8a3c8c1aa5e1643)

## Testbenches

The testbenches provided a good baseline to debug specific modules using unit tests when making the single cycle cpu. However, I found that it was more time-efficient to move straight to debugging the overall top.sv during pipeline because of the complexity of the pipeline connecting between modules. However, some of the tests were not updated to spend less time debugging testbenches and focus on debugging pipeline and cache modules.

Relevant commits: [Making Control Testbench](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/4c0194e63362b14d44dd4dfa46dbce4938bb4b28), [Fixing Testbenches](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/fe603b6fa84637ffcbc57aa4c36f4478f70a5df5)

## Integrating and Debugging Single Cycle CPU

The single cycle cpu was probably the hardest to debug, with problems such as the negative edge write for the register file and the correct wiring for the jump instructions.

!["Single Cycle CPU"](/images/single_cycle.png)

Many modules were given to me individually, so the top.sv integration was my job.

Relevant commits: [Debugging single cycle cpu](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/73a36203a2ab0bd10232b4e5f15aacfaf55b1abe), [Debugging verify.cpp tests](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/14313496c8e29850c8b290a78c772f24215c7313)

## Hazard Unit

The hazard unit was relatively straightforward. Generally following the diagram as to how signals connected worked fine, and I included both forwarding against data hazards as well as flush and stall instructions to protect against control hazards. Since the control unit was now pipelined, I broke the previous PC top layer into individual bits to ensure that all flags were pipelined and had correct outputs.

![Hazard Unit](/images/hazard_unit.png)

```
    //If RegWriteMemory is High, RdM is not 0 and Rs1E = RdM, forward execute-memory from ALUResultM
    if(RegWriteM && (RdM != 0) && (Rs1E == RdM)) begin
        ForwardAE = 2'b10;
    end
    //If RegWriteWriteback is High, RdW is not 0 and Rs1E = RdM, forward memory-writeback from ResultW
    else if(RegWriteW && (RdW != 0) && (Rs1E == RdW)) begin
        ForwardAE = 2'b01;
    end
    //No forward
    else begin 
        ForwardAE = 0;
    end

    //If RegWriteMemory is High, RdM is not 0 and Rs2E = RdM, forward execute-memory from ALUResultM
    if(RegWriteM && (RdM != 0) && (Rs2E == RdM)) begin
        ForwardBE = 2'b10;
    end
    //If RegWriteWriteback is High, RdW is not 0 and Rs2E = RdM, forward memory-writeback from ResultW
    else if(RegWriteW && (RdW != 0) && (Rs2E == RdW)) begin
        ForwardBE = 2'b01;
    end
    //No forward
    else begin 
        ForwardBE = 0;
    end
```

Stalling and flushing were also important parts of the pipeline, implemented here as well.

```
    //Stalling
    //When an instruction calls for a MemRead from an instruction that has not finished processing, stall
    if(((Rs1D == RdE) || (Rs2D == RdE))  && MemRead) begin 
        stall = 1;
    end
    else begin 
        stall = 0;
    end

    //Flush whenever EQ flag is detected or jump is called
    if(ZeroE || jump) begin 
        flush = 1;
    end
    else begin 
        flush = 0;
    end
```

Relevant commits: [Creating hazard unit](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/3be35c174ce5adc6eb24c6d923f8f0bc347df01d), [Updated pipeline modules with stall/flush and readability](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/e97c7f99d5daca7b85ebdc0102eb6c8fa4295604)

## Integrating and Debugging Pipeline

Pipeline was particularly difficult to integrate due to the amount of different signals and wires used by each person that contributed to the pipeline. The lack of communication in naming conventions and how stalls and flushes were interpreted led to more time spent integrating than expected.

Relevant commits: [Pipelining top.sv](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/9f3c4f2592f6be843f6f1d250d37206a229f2b99), [Finally fixed pipeline](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/cb990f97c47f873cbe0370ee6b942802027e2fa3)

## FSM and Cache Unit

To control the cache to set proper reads and writes, a finite state machine was implemented in the cache unit.

![Finite State Machine](/images/fsm.jpg)

Checks the valid and tags to set Compare tag:
```
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
```
Way select helps choose which of the 2 way cache to read/write to.

Finite state machine
```
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
```

![Cache](/images/2waycache.png)

The short explanation for this state machine is that the Idle state happens when a Hit is detected, Allocate state happens when a Miss happens and Dirty bit is 0 and Write-Back state happens when a Miss happens and Dirty bit is 1. Allocate state reads a new block from memory into cache, whereas Write-Back writes an old block into memory into cache, both of which go into Compare Tag and Idle when they hit. Compare Tag is used to compare the Valid and Tag signals and output the Hit and Dirty flags.

CacheStall was initially used to stall the cache, but the finite state machine was sufficient to stall the cache instruction so that stalling was unnecessary.

Relevant commits: [Added and Fixed Cache](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/b40be4e080272b42a8b4af3f2811cf5676dd5142)

## Integrating and Debugging Cache

Debugging cache was not difficult once the finite state machine was implemented, and the only confusion I had was with the CacheStall and if it was necessary or not.

![Cache Signals](/images/cachesignals.png)

Relevant commits: [Fixing Cache](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/8a1dd9c76d715717b2a5268d4f38d67cd6c8a0f5)

## Repo Master

As repo master, I set certain ground rules for how the Github should look like to avoid unnecessary pushes to main and to localise the work within branches, avoiding overlapping work. Some documents I made were to ensure clarity of our work within the team and to serve as future reference to avoid confusion.

Relevant commits: [Educating on Git Protocols](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/7abbe607aabf828b1d6d087a6c4dfa003c69e9a4), [Pipeline Allocation](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/commit/3c3f767f5c27f15cfdd2ae723dc1c50dcacf4bec)

## Final Words

I would like to thank Ryan and Petr for giving me the confidence to push for all the extended goals as well as guidance on how to manage the workload throughout the project. I would also like to credit Aurel Ersek, who helped me throughout many nights to discuss difference approaches and debug whenever I was alone in the library.