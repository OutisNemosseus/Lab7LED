
// ===========================================
// Boolean Expressions Implementation in Verilog
// ===========================================

// 1) Y = A + B
module expr1 (
    input  wire A, B,
    output wire Y
);
    assign Y = A | B;
endmodule

// 2) Y = (A+B)C' + A'C
module expr2 (
    input  wire A, B, C,
    output wire Y
);
    assign Y = ((A | B) & ~C) | ((~A) & C);
endmodule

// 3) Y = AB + A'B'C
module expr3 (
    input  wire A, B, C,
    output wire Y
);
    assign Y = (A & B) | ((~A) & (~B) & C);
endmodule

// 4) Y = A'C + B'D'
module expr4 (
    input  wire A, B, C, D,
    output wire Y
);
    assign Y = ((~A) & C) | ((~B) & (~D));
endmodule

// 5) Y = A B' + A' B C + A' C D
// Equivalent: Y = A B' + A' C (B + D)
module expr5 (
    input  wire A, B, C, D,
    output wire Y
);
    assign Y = (A & ~B) | ((~A) & B & C) | ((~A) & C & D);
endmodule
