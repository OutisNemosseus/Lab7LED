// Seven-segment HEX decoder (active-low), ports per your schematic spec.
// Inputs : digit[0]..digit[3]   (digit[0] = LSB, digit[3] = MSB)
// Outputs: segments[0]..segments[6]  (0=a, 1=b, ..., 6=g), active-low

module sevenSeg (
    input  wire [3:0] digit,      // {digit[3],digit[2],digit[1],digit[0]}
    output wire [6:0] segments    // segments[0]=a ... segments[6]=g (active-low)
);
    wire D3 = digit[3];
    wire D2 = digit[2];
    wire D1 = digit[1];
    wire D0 = digit[0];

    // Your SOP forms (Sx = active-high "lit"), then invert to active-low outputs.
    wire Sa = (~D2 & ~D0)
            | (~D3 &  D2 &  D0)
            | ( D3 & ~D0)
            | ( D3 & ~D2 & ~D1)
            | (~D3 &  D1)
            | ( D2 &  D1);

    wire Sb = (~D3 &  D1 &  D0)
            | (~D2 & ~D0)
            | ( D3 & ~D1 &  D0)
            | (~D3 & ~D1 & ~D0)
            | (~D2 & ~D1);

    wire Sc = (~D2 & ~D1)
            | (~D1 &  D0)
            | (~D2 &  D0)
            | (~D3 &  D0)
            | (~D3 & ~D1);

    wire Sd = ( D2 & ~D1 &  D0)
            | ( D3 & ~D1)
            | (~D2 &  D1 &  D0)
            | (~D3 & ~D2 & ~D0)
            | ( D2 &  D1 & ~D0);

    wire Se = ( D3 &  D1)
            | (~D2 & ~D0)
            | ( D3 &  D2)
            | ( D1 & ~D0);

    wire Sf = ( D3 &  D2 &  D1)
            | ( D3 & ~D0)
            | (~D3 &  D2 & ~D1)
            | ( D3 & ~D2 & ~D1)
            | (~D1 & ~D0)
            | ( D2 & ~D0);

    wire Sg = ( D3 &  D1)
            | (~D2 &  D1)
            | (~D3 &  D2 & ~D1)
            | ( D3 & ~D2)
            | (~D3 &  D2 & ~D0);

    // Map: segments[0]=a ... segments[6]=g, active-low: x = ~Sx
    assign segments[0] = ~Sa;  // a
    assign segments[1] = ~Sb;  // b
    assign segments[2] = ~Sc;  // c
    assign segments[3] = ~Sd;  // d
    assign segments[4] = ~Se;  // e
    assign segments[5] = ~Sf;  // f
    assign segments[6] = ~Sg;  // g
endmodule
