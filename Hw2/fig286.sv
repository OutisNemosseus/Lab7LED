
// Figure 2.86 truth table (A,B,C,D -> Y), including X outputs for don't-care rows
module fig286 (
    input  logic A, B, C, D,
    output logic Y
);
    always_comb begin
        unique case ({A,B,C,D})
            4'b0000: Y = 1'b0;
            4'b0001: Y = 1'b1;
            4'b0010: Y = 1'bx;  // don't care in table
            4'b0011: Y = 1'bx;

            4'b0100: Y = 1'b0;
            4'b0101: Y = 1'bx;
            4'b0110: Y = 1'bx;
            4'b0111: Y = 1'bx;

            4'b1000: Y = 1'b1;
            4'b1001: Y = 1'b0;
            4'b1010: Y = 1'b0;
            4'b1011: Y = 1'b1;

            4'b1100: Y = 1'b0;
            4'b1101: Y = 1'b1;
            4'b1110: Y = 1'bx;
            4'b1111: Y = 1'b1;
            default: Y = 1'bx;
        endcase
    end
endmodule
