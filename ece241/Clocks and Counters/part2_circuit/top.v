`timescale 1ns/1ns

module top(SW,HEX0, CLOCK_50);
	input [9:0] SW;
	input CLOCK_50;
	output [6:0] HEX0;
	wire w;
	//instantiate module and hex_decoder
	part2 u0(.ClockIn(CLOCK_50), .Reset(SW[9]), .Speed(SW[1:0]), .CounterValue(w));
	hex_decoder u1(.c(w), .display(HEX0));

endmodule 


module part2(ClockIn, Reset, Speed, CounterValue);
	input ClockIn, Reset;
	input [1:0] Speed;
	output [3:0] CounterValue;   //hex needs 4 bits
	wire w;
	
	//instantiate RateDivider and hexCounter
	RateDivider u0(.clock(ClockIn), .speed(Speed), .reset(Reset), .out(w));
	hexCounter u1(.clock(ClockIn), .enable(w), .reset(Reset), .hexnum(CounterValue));
	
endmodule

module RateDivider(clock, speed, reset, out);
	input clock, reset; 
	//if using FPGA with 50mHz, max cout needs 28 bits
	input [1:0] speed; 
	reg [27:0] count;
	reg [27:0] Q;
	output out;
	
	//determine count from speed (mux)
	always @(*)
		begin
			case(speed)
				2'b00 : count = 28'd0;	  
				2'b01 : count = 28'd49999999;
				2'b10 : count = 28'd99999999;
				2'b11 : count = 28'd199999999;
				default : count = 28'd0;
			endcase
		end
		
	//counter that checks against count number
	//down counter
	always @(posedge clock)
		begin
			if(reset == 1)
				Q <= 0;
			//else if(load == 1)
				//Q <= count;
			else if(Q == 0)
				Q <= count;
			else 
				Q <= Q-1;
		end
		
	assign out = (Q == 0) ? 1 : 0;
endmodule

module hexCounter(clock, enable, reset, hexnum);
	input clock, enable, reset;
	output reg [3:0] hexnum;
	
	always@(posedge clock)
		begin
			if(reset == 1)
				hexnum <= 0;
			else if(enable == 1)
				hexnum <= hexnum + 1;	
		end
	
endmodule

//hex decoder
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

