`timescale 1ns / 1ns

module part2(Clock, Reset_b, Data, Function, ALUout);
	input [3:0] Data;
	input [2:0] Function;
	input Clock, Reset_b;
	output [7:0] ALUout;
	//wire [7:0] w1;   //ALU to register use ALUout
	wire [3:0] w2;   //4 lsb to ALU
	ALU u0(.A(Data),.B(w2),.Function(Function),.ALUout(ALUout));
	register u1(.Clock(Clock),.Data(ALUout),.q(w2),.Reset_b(Reset_b));    //4 least sig bits of q to w2  .q[3:0](w2[3:0])
	
endmodule

//ALU
module ALU(A,B,Function,ALUout,enable,Clock,Reset_b);             //renaming from part3 to ALU
	input [3:0] A,B;
	input [2:0] Function;
	output reg [7:0] ALUout;
	output reg enable;
	wire [3:0] s_w;
	wire c_out_w, c;
	wire [4:0] d;
	assign d = A + B;
	//instantiate full adder
	fa4bit u0(.a(A), .b(B), .c_in(1'b0), .s(s_w), .c_out(c_out_w));
	assign c = {A,B};
	always @(*)
		begin
			enable = 1;
			ALUout = {8'b0};
			case(Function[2:0])
				3'b000: ALUout = {3'b0, c_out_w , s_w};    //case 0: A + B using adder from part 2
				3'b001: ALUout = {3'b0, d};			 //case 1: A+B
				3'b010: ALUout = {B[3],B[3],B[3],B[3], B};          //case 2: sign extention
				3'b011: ALUout = {B[3]|B[2]|B[1]|B[0]|A[3]|A[2]|A[1]|A[0]};          //case 3: Output 8’b00000001 if at least 1 of the 8 bits
				3'b100: ALUout = {B[3]&B[2]&B[1]&B[0]&A[3]&A[2]&A[1]&A[0]};          //case 4: Output 8’b00000001 if all of the 8 bits 
				3'b101: ALUout = B>>A;                                       //case 5: Left shift B by A bits using the Verilog shift operator
				3'b110: ALUout = A*B;													//case 6: A × B using the Verilog ‘*’ operator
				3'b111: enable = 0;												//case 7: Hold current value in the Register,
				default: ALUout = {8'b0};
			endcase
		end
endmodule


////8-bit register
//module register(Clock,Data,q,Reset_b,enable);
//	input Clock,Reset_b;
//	input enable;
//	input [7:0] Data;
//	output reg [7:0] q;
//	
//	always@(posedge Clock)
//		if(Reset_b == 1)
//			q<=0;
//		else if(enable == 1)
//			q<=Data;
//endmodule
			
//4-bit FA
module fa4bit(a, b, c_in, s, c_out);   //used to be called part2, changing it to fa4bit
	input [3:0] a, b;
	input c_in;
	output [3:0] s;
	output [3:0] c_out;
	
	
	FA u0(.a(a[0]), .b(b[0]), .c_in(c_in), .s(s[0]), .c_out(c_out[0]));
	FA u1(.a(a[1]), .b(b[1]), .c_in(c_out[0]), .s(s[1]), .c_out(c_out[1]));
	FA u2(.a(a[2]), .b(b[2]), .c_in(c_out[1]), .s(s[2]), .c_out(c_out[2]));
	FA u3(.a(a[3]), .b(b[3]), .c_in(c_out[2]), .s(s[3]), .c_out(c_out[3]));

endmodule

//FA
module FA(a, b, c_in, s, c_out);
	input a,b,c_in;
	output s, c_out;
	
	assign s = a^b^c_in;
	assign c_out = (a&b) | (c_in&a) | (c_in&b);
	
endmodule
