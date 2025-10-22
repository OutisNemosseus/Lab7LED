// segment_mapper_direct.v
// 输入 7 个独立信号 Sa..Sg，输出总线 segments[6:0]（无取反，active-high）

module segment_mapper_direct (
    input  wire Sa,  // segment a
    input  wire Sb,  // segment b
    input  wire Sc,  // segment c
    input  wire Sd,  // segment d
    input  wire Se,  // segment e
    input  wire Sf,  // segment f
    input  wire Sg,  // segment g
    output wire [6:0] segments  // segments[0]=a ... segments[6]=g
);
    // 直接连接（无取反）
    assign segments[0] = Sa;  // a
    assign segments[1] = Sb;  // b
    assign segments[2] = Sc;  // c
    assign segments[3] = Sd;  // d
    assign segments[4] = Se;  // e
    assign segments[5] = Sf;  // f
    assign segments[6] = Sg;  // g
endmodule
