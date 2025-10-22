`timescale 1ns/1ps
module tb_fig286;
    logic A, B, C, D;
    logic Y;

    fig286 dut(.A(A), .B(B), .C(C), .D(D), .Y(Y));

    // ? 0..15 ?????????
    integer i;
    initial begin
        {A,B,C,D} = 4'b0000;
        for (i = 0; i < 16; i++) begin
            {A,B,C,D} = i[3:0];
            #10;
        end
        #10 $finish;
    end

    // ????????
    initial begin
        $display(" time | A B C D | Y");
        $monitor("%4t | %b %b %b %b | %b", $time, A,B,C,D,Y);
    end
endmodule
