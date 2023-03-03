`timescale 1ns / 1ns

module top(SW, LEDR);
    input [9:0] SW;
    output [0:0]LEDR;
	 part1 u0(.MuxSelect(SW[9:7]), .Input(SW[6:0]), .Out(LEDR[0]));
endmodule


module part1(MuxSelect, Input, Out);
	input [6:0] Input;
	input [2:0] MuxSelect;
	output reg [2:0] Out;
	
	always@(*)
		begin
			case(MuxSelect[2:0])
				3'b000: Out = Input[0];
				3'b001: Out = Input[1];
				3'b010: Out = Input[2];
				3'b011: Out = Input[3];
				3'b100: Out = Input[4];
				3'b101: Out = Input[5];
				3'b110: Out = Input[6];
				default: Out = 3'b000;
			endcase
		end
		
endmodule
	
	
