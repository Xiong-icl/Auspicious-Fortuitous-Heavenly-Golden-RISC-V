module mux2 #(
    DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0]  in0_2,
    input   logic [DATA_WIDTH-1:0]  in1_2,
    input   logic [DATA_WIDTH-1:0]  in2_2,
    input   logic [1:0]             sel_2,
    output  logic [DATA_WIDTH-1:0]  out_2
);
    always_comb begin 
        case(sel_2) 
            0: out_2 = in0_2;
            1: out_2 = in1_2;
            2: out_2 = in2_2;
        endcase
    end
endmodule
