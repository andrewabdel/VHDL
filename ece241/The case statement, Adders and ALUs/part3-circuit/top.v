`timescale 1ns / 1ns


module top(SW,KEY,LEDR,HEX);
	input [7:0] SW;
	input [2:0] KEY;

	output [7:0] LEDR;
	output [5:0] HEX;
	
	wire [7:0] c;
	
	//instantiate ALU
	part3 ALU_HEX(.A(SW[7:4]),.B(SW[3:0]),.Function(KEY[2:0]),.ALUout(c[7:0]));
	part3 ALU_BIN(.A(SW[7:4]),.B(SW[3:0]),.Function(KEY[2:0]),.ALUout(LEDR[7:0]));

	
	//instantiate hex decoder
	hex_decoder HEX0 (.c(SW[3:0]), .display(HEX[0]));
	hex_decoder HEX2 (.c(SW[7:4]), .display(HEX[2]));
	hex_decoder HEX4 (.c(c[3:0]), .display(HEX[4]));
	hex_decoder HEX5 (.c(c[7:4]), .display(HEX[5]));
	
	//hex1 and 3
	hex_decoder HEX1 (.c(4'b0), .display(HEX[1]));
	hex_decoder HEX3 (.c(4'b0), .display(HEX[3]));

endmodule


module part3(A,B,Function,ALUout);
	input [3:0] A,B;
	input [2:0] Function;
	output reg [7:0] ALUout;
	wire [3:0] s_w;
	wire c_out_w, c;
	//instantiate full adder
	part2 u0(.a(A), .b(B), .c_in(1'b0), .s(s_w), .c_out(c_out_w));
	assign c = {A,B};
	always @(*)
		begin
			case(Function[2:0])
				3'b000: ALUout = {3'b0, c_out_w , s_w};    //case 0: A + B using adder from part 2
				3'b001: ALUout = {4'b0, A + B};			 //case 1: A+B
				3'b010: ALUout = {B[3],B[3],B[3],B[3], B};          //case 2: sign extention
				3'b011: ALUout = {B[3]|B[2]|B[1]|B[0]|A[3]|A[2]|A[1]|A[0]};          //case 3: sign extention
				3'b100: ALUout = {B[3]&B[2]&B[1]&B[0]&A[3]&A[2]&A[1]&A[0]};          //case 4: sign extention
				3'b101: ALUout = {A, B};          //case 5: sign extention
				default: ALUout = {8'b0};
			endcase
		end
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


///////////////////////////////////////////////////DECODER////////////////////////

//top level module
//module decoder(SW,HEX0);
//	input [3:0] SW;
//	output [6:0] HEX0;
//	
//	//instatiate hex_decoder module
//	//Question: can 
//	hex_decoder u0(.c(SW),.display(HEX0));
//	
//endmodule


module hex_decoder(c, display);
	input [3:0] c;
	output [6:0] display;
	wire [15:0] m;
	
	//minterms (and gate at the first end of the wire to create minterms)
	assign m[0] = ~c[3] & ~c[2] & ~c[1] & ~c[0];
	assign m[1] = ~c[3] & ~c[2] & ~c[1] & c[0];
	assign m[2] = ~c[3] & ~c[2] & c[1] & ~c[0];
	assign m[3] = ~c[3] & ~c[2] & c[1] & c[0];
	assign m[4] = ~c[3] & c[2] & ~c[1] & ~c[0];
	assign m[5] = ~c[3] & c[2] & ~c[1] & c[0];
	assign m[6] = ~c[3] & c[2] & c[1] & ~c[0];
	assign m[7] = ~c[3] & c[2] & c[1] & c[0];
	assign m[8] = c[3] & ~c[2] & ~c[1] & ~c[0];
	assign m[9] = c[3] & ~c[2] & ~c[1] & c[0];
	assign m[10] = c[3] & ~c[2] & c[1] & ~c[0];
	assign m[11] = c[3] & ~c[2] & c[1] & c[0];
	assign m[12] = c[3] & c[2] & ~c[1] & ~c[0];
	assign m[13] = c[3] & c[2] & ~c[1] & c[0];
	assign m[14] = c[3] & c[2] & c[1] & ~c[0];
	assign m[15] = c[3] & c[2] & c[1] & c[0];
	
	//output (OR gate to sum up the correct minterms at the other end of the wires of m)
	assign display[0] = m[1] | m[4] | m[11] | m[13];
	assign display[1] = m[5] | m[6] | m[11] | m[12] | m[14] | m[15];
	assign display[2] = m[2] | m[12] | m[14] | m[15];
	assign display[3] = m[1] | m[4] | m[7] | m[10] | m[15];
	assign display[4] = m[1] | m[3] | m[4] | m[5] | m[7] | m[9];
	assign display[5] = m[1] | m[2] | m[3] | m[7] | m[13];
	assign display[6] = m[0] | m[1] | m[7] | m[12];

	
endmodule
///////////////////////////////////////////////////////////////////////