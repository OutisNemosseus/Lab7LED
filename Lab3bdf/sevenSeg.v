// Copyright (C) 2020  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
// CREATED		"Wed Oct 15 22:41:59 2025"

module sevenSeg(
	digit,
	segments
);


input wire	[3:0] digit;
output wire	[6:0] segments;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;





segment_e	b2v_inst(
	.digit(digit),
	.e(SYNTHESIZED_WIRE_4));


segment_mapper_direct	b2v_inst1(
	.Sa(SYNTHESIZED_WIRE_0),
	.Sb(SYNTHESIZED_WIRE_1),
	.Sc(SYNTHESIZED_WIRE_2),
	.Sd(SYNTHESIZED_WIRE_3),
	.Se(SYNTHESIZED_WIRE_4),
	.Sf(SYNTHESIZED_WIRE_5),
	.Sg(SYNTHESIZED_WIRE_6),
	.segments(segments));


segment_f	b2v_inst2(
	.digit(digit),
	.f(SYNTHESIZED_WIRE_5));


segment_g	b2v_inst3(
	.digit(digit),
	.g(SYNTHESIZED_WIRE_6));


segment_d	b2v_inst4(
	.digit(digit),
	.d(SYNTHESIZED_WIRE_3));


segment_c	b2v_inst5(
	.digit(digit),
	.c(SYNTHESIZED_WIRE_2));


segment_b	b2v_inst6(
	.digit(digit),
	.b(SYNTHESIZED_WIRE_1));


segment_a	b2v_inst7(
	.digit(digit),
	.a(SYNTHESIZED_WIRE_0));


endmodule
