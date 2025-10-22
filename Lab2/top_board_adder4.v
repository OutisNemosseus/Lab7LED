// top_board_adder4.v  (Verilog-2001)
module top_board_adder4(
    input  [9:0] SW,    // SW[3:0]=A, SW[7:4]=B, SW[8]=Cin
    output [9:0] LEDR
);
    wire [3:0] A = SW[3:0];
    wire [3:0] B = SW[7:4];
    wire       Cin = SW[8];

    wire [3:0] Z;
    wire       Cout;

    Adder4 U(.A(A), .B(B), .Cin(Cin), .Z(Z), .Cout(Cout));

    assign LEDR[3:0] = Z;
    assign LEDR[9]   = Cout;
    assign LEDR[8:4] = 5'b0;
endmodule
