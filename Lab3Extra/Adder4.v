//=========================================================
// 4-bit Ripple Carry Adder
//=========================================================
// Uses 4 instances of FullAdder (from full_adder.v)
// Inputs : A[3:0], B[3:0], Cin
// Outputs: Z[3:0], Cout
//=========================================================
module Adder4(
    input  [3:0] A,     // 4-bit input A
    input  [3:0] B,     // 4-bit input B
    input        Cin,   // Carry input
    output [3:0] Z,     // 4-bit sum output (renamed from Sum)
    output       Cout   // Final carry output
);

    // Internal carry wires
    wire c1, c2, c3;

    // Instantiate four 1-bit full adders
    FullAdder FA0 (.A(A[0]), .B(B[0]), .Cin(Cin),  .Sum(Z[0]), .Cout(c1));
    FullAdder FA1 (.A(A[1]), .B(B[1]), .Cin(c1),   .Sum(Z[1]), .Cout(c2));
    FullAdder FA2 (.A(A[2]), .B(B[2]), .Cin(c2),   .Sum(Z[2]), .Cout(c3));
    FullAdder FA3 (.A(A[3]), .B(B[3]), .Cin(c3),   .Sum(Z[3]), .Cout(Cout));

endmodule
