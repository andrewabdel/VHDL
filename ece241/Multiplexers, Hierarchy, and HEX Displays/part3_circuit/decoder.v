`timescale 1ns/1ns

//top level module
module decoder(SW,HEX0);
	input [3:0] SW;
	output [6:0] HEX0;
	
	//instatiate hex_decoder module
	//Question: can 
	hex_decoder u0(.c(SW),.display(HEX0));
	
endmodule


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
