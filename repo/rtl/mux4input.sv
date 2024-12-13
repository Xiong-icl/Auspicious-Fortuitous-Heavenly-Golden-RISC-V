module mux4input #(
    DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0]  in0_4,
    input   logic [DATA_WIDTH-1:0]  in1_4,
    input   logic [DATA_WIDTH-1:0]  in2_4,
    input   logic [DATA_WIDTH-1:0]  in3_4,
    input   logic [2:0]             sel_4,
    output  logic [DATA_WIDTH-1:0]  out_4
);
    always_comb begin 
        case(sel4) 
            0: out_4 = in0_4;
            1: out_4 = in1_4;
            2: out_4 = in2_4;
            3: out_4 = in3_4;
        endcase
    end
endmodule
