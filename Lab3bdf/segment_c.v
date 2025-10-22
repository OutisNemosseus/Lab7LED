module segment_c (
    input  wire [3:0] digit,
    output wire c
);
    wire D3 = digit[3];
    wire D2 = digit[2];
    wire D1 = digit[1];
    wire D0 = digit[0];

    wire Sc = (~D2 & ~D1)
            | (~D1 &  D0)
            | (~D2 &  D0)
            | (~D3 &  D0)
            | (~D3 & ~D1);

    assign c = ~Sc;
endmodule
