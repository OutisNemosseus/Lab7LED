// Q = (¬A∧¬B∧¬C) ∨ (¬A∧¬B∧C) ∨ (¬A∧B∧¬C) ∨ (A∧¬B∧¬C)
module detector (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Q
);
    // Direct SOP from your expression:
    assign Q = (~A & ~B & ~C)
             | (~A & ~B &  C)
             | (~A &  B & ~C)
             | ( A & ~B & ~C);

    // Equivalent minimized form (optional):
    // assign Q = (~A & ~B) | (~A & ~C) | (~B & ~C);
endmodule
