module sevenSeg_top (
    input  wire [3:0] digit,
    output wire [6:0] segments
);
    segment_a u_a (.digit(digit), .a(segments[0]));
    segment_b u_b (.digit(digit), .b(segments[1]));
    segment_c u_c (.digit(digit), .c(segments[2]));
    segment_d u_d (.digit(digit), .d(segments[3]));
    segment_e u_e (.digit(digit), .e(segments[4]));
    segment_f u_f (.digit(digit), .f(segments[5]));
    segment_g u_g (.digit(digit), .g(segments[6]));
endmodule
