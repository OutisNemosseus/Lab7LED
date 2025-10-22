// extraCreditWithSub.v  (Verilog-2001)
// sub=0: Z = A + B
// sub=1: Z = A - B = A + (~B) + 1
module Adder4WithSub(
    input  [3:0] A,
    input  [3:0] B,
    input        sub,
    output [3:0] Z,
    output       Cout
);
    wire [3:0] B_eff = sub ? ~B : B;
    wire       Cin_eff = sub ? 1'b1 : 1'b0;

    Adder4 u_add(.A(A), .B(B_eff), .Cin(Cin_eff), .Z(Z), .Cout(Cout));
endmodule
