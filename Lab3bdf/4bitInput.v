// fourbit_passthrough_named.v

module fourbit_passthrough_named (
    input  wire D3,
    input  wire D2,
    input  wire D1,
    input  wire D0,
    output wire D3_out,
    output wire D2_out,
    output wire D1_out,
    output wire D0_out
);
    assign D3_out = D3;
    assign D2_out = D2;
    assign D1_out = D1;
    assign D0_out = D0;
endmodule
