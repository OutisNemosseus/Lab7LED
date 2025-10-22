// full_adder.v  (Verilog-2001)
module FullAdder(
    input  A,
    input  B,
    input  Cin,
    output Sum,
    output Cout
);
    // Sum = A'B'Cin + A'BCin' + AB'Cin' + ABCin
    assign Sum  = (~A & ~B &  Cin) |
                  (~A &  B & ~Cin) |
                  ( A & ~B & ~Cin) |
                  ( A &  B &  Cin);

    // Cout = AB + ACin + BCin
    assign Cout = (A & B) | (A & Cin) | (B & Cin);
endmodule
