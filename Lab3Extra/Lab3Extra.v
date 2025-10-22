// top_add4_to_7seg.v
// 将 Adder4 的和与进位分别显示在两块七段数码管（十六进制）上。
// 端口命名与你作业说明一致：segments[0]=a ... segments[6]=g（active-low）

module Lab3Extra (
    input  wire [3:0] A,           // 可以连到四个拨码开关
    input  wire [3:0] B,           // 同上
    input  wire       Cin,         // 进位输入（按键/开关）
    output wire [6:0] segments_sum,   // 显示 Z（HEX）
    output wire [6:0] segments_cout   // 显示 Cout（0 或 1 的 HEX）
);
    // -------- 核心加法器 --------
    wire [3:0] Z;
    wire       Cout;

    Adder4 u_add (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Z(Z),
        .Cout(Cout)
    );

    // -------- 七段解码（HEX） --------
    // 第一块：显示 4-bit 和（Z）
    sevenSeg u_hex_sum (
        .digit(Z),              // 直接把 Z[3:0] 当成 16 进制输入
        .segments(segments_sum) // active-low 输出到数码管
    );

    // 第二块：显示 Cout（0 或 1）
    // 把 Cout 扩展成 4-bit：{0,0,0,Cout}，这样七段就显示 "0" 或 "1"
    wire [3:0] digit_cout = {3'b000, Cout};

    sevenSeg u_hex_cout (
        .digit(digit_cout),
        .segments(segments_cout)
    );

endmodule
