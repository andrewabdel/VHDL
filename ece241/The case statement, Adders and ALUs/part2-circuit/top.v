`timescale 1ns / 1ns


module top(SW,LEDR);
	input [8:0] SW;
	output [9:0] LEDR;
	//output [8:8] LEDR;         //is there a better way to do this??
	
	part2 u0(.a(SW[7:4]), .b(SW[3:0]), .c_in(SW[8]), .s(LEDR[3:0]), .c_out(LEDR[9]));
	
endmodule



module part2(a, b, c_in, s, c_out);
	input [3:0] a, b;
	input c_in;
	output [3:0] s;
	output c_out;
	wire w1, w2, w3;
	
	FA u0(.a(a[0]), .b(b[0]), .c_in(c_in), .s(s[0]), .c_out(w1));
	FA u1(.a(a[1]), .b(b[1]), .c_in(w1), .s(s[1]), .c_out(w2));
	FA u2(.a(a[2]), .b(b[2]), .c_in(w2), .s(s[2]), .c_out(w3));
	FA u3(.a(a[3]), .b(b[3]), .c_in(w3), .s(s[3]), .c_out(c_out));

endmodule


module FA(a, b, c_in, s, c_out);
	input a,b,c_in;
	output s, c_out;
	
	assign s = a^b^c_in;
	assign c_out = (a&b) | (c_in&a) | (c_in&b);
endmodule


	
