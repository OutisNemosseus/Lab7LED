// Q = (~A & ~B & ~C) | (~A & ~B & C) | (~A & B & ~C) | (A & ~B & ~C)
module two_false_detector (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Q
);
    assign Q = (~A & ~B & ~C) |
               (~A & ~B &  C) |
               (~A &  B & ~C) |
               ( A & ~B & ~C);
    // Equivalent simplified form:
    // assign Q = (~A & ~B) | (~A & ~C) | (~B & ~C);
endmodule
