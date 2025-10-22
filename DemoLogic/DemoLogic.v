module DemoLogic (
    input wire A,
    input wire B,
    input wire C,
    output wire Z
);

    wire x1;
    wire o1;

    assign x1 = A ^ B;    // XOR gate
    assign o1 = B | C;    // OR gate
    assign Z  = x1 & o1;  // AND gate

endmodule

