module adder4 (
    input  [3:0] A, B,
    input        Cin,
    output [4:0] S
);
    assign S = A + B + Cin;
endmodule
