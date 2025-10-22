// top_board_adder4.v
// SW[3:0]=A, SW[7:4]=B, SW[8]=Cin
// segments[6:0] -> a..g (active-low), segments[7] -> dp (active-low) 显示Cout
module top_board_adder4(
    input  [9:0] SW,
    output [7:0] segments   // segments[6:0]=a..g, segments[7]=dp
);
    // 拨码开关到加法器
    wire [3:0] A   = SW[3:0];
    wire [3:0] B   = SW[7:4];
    wire       Cin = SW[8];

    // 加法结果
    wire [3:0] Z;
    wire       Cout;

    // 你的四位加法器（已定义为输出 Z）
    Adder4 U_adder4 (
        .A(A), .B(B), .Cin(Cin),
        .Z(Z), .Cout(Cout)
    );

    // 七段译码（只用来驱动 a..g 显示 Z 的 16 进制）
    wire [6:0] seg_sum;  // a..g (active-low)
    sevenSeg U_hex_sum (
        .digit(Z),          // 输入 0~15
        .segments(seg_sum)  // 输出 a..g (active-low)
    );

    // 拼成 8 根段线：a..g + dp
    // 若段线为主动低：Cout=1 时点亮 dp，则 dp = ~Cout
    assign segments[6:0] = seg_sum;     // 显示 Z
    assign segments[7]   = ~Cout;       // 用小数点显示 Cout

endmodule
