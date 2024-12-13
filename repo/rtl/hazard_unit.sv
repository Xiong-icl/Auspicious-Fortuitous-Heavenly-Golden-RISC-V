module hazard_unit# (
)(
    //inputs
    input   logic   [19:15] Rs1E,
    input   logic   [24:20] Rs2E,
    input   logic   [19:15] Rs1D,
    input   logic   [24:20] Rs2D,
    input   logic   [11:7]  RdE,
    input   logic   [11:7]  RdM,
    input   logic   [11:7]  RdW,
    input   logic           RegWriteM,
    input   logic           RegWriteW,
    input   logic           MemRead,
    input   logic           ZeroE,         //I think you forgot to add that input
    input   logic           jump,

    //outputs
    output  logic    [1:0]  ForwardAE,
    output  logic    [1:0]  ForwardBE,
    output  logic           stall,
    output  logic           flush
);


    always_comb begin 

        ForwardAE   = 0;
        ForwardBE   = 0;
        stall       = 0;
        flush       = 0;

        //Data hazard

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

        //Control hazard

        //Stalling
        //When an instruction calls for a MemRead from an instruction that has not finished processing, stall
        if(((Rs1D == RdE) || (Rs2D == RdE))  && MemRead) begin 
            stall = 1;
        end
        else begin 
            stall = 0;
        end

        //Flush whenever branch is called
        if(ZeroE || jump) begin 
            flush = 1;
        end
        else begin 
            flush = 0;
        end

    end
endmodule
