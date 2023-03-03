`timescale 1ns/1ns

module part3(ClockIn, Resetn, Start, Letter, DotDashOut, NewBitOut,Q);
	input ClockIn, Resetn, Start, NewBitOut;
	input [2:0] Letter;
	output DotDashOut;
	wire w1;
	wire [11:0] w2;
	output [11:0] Q;
	
	//instantiate modules
	rateDivider u0(.clock(ClockIn),.resetn(Resetn),.out(w1));
	lookup u1(.letter(Letter), .out(w2));
	reg12bit u2(.D(w2),.W(1'b0),.Q(Q),.clock(ClockIn),.resetn(Resetn),.start(Start),.enable(w1),.shift_out(DotDashOut), .NewBitOut(NewBitOut)); //we leave Q uninitialized
	
endmodule


//asynch active low reset
//needs enable???
module rateDivider(clock,resetn,out);
	input clock, resetn;
	output out;
	reg [7:0] q;
	wire [7:0] count;
	assign count = 8'd249;
	
	always @(negedge resetn, posedge clock)
		begin
			if(resetn == 0)
				q <= 0;
			else if(q == 0)
				q <= count;
			else
				q <= q - 1;
		end
		
	assign out = (q == 0)? 1 : 0;
	
endmodule

//lut
module lookup(letter, out);
	input [2:0] letter;
	output reg [11:0] out;
	
//	always @(*)
//		begin
//			case(letter)
//				3'b000 : out = 12'b000000101110;  //A
//				3'b001 : out = 12'b001110101010;  //B
//				3'b010 : out = 12'b111010111010;  //C
//				3'b011 : out = 12'b000011101010;  //D
//				3'b100 : out = 12'b000000000010;  //E
//				3'b101 : out = 12'b001010111010;  //F
//				3'b110 : out = 12'b001110111010;  //G
//				3'b111 : out = 12'b000010101010;  //H
//				endcase
//		end
	always @(*)
		begin
			case(letter)
				3'b000 : out = 12'b000000011101;  //A
				3'b001 : out = 12'b000101010111;  //B
				3'b010 : out = 12'b010111010111;  //C
				3'b011 : out = 12'b000001010111;  //D
				3'b100 : out = 12'b000000000001;  //E
				3'b101 : out = 12'b000101110101;  //F
				3'b110 : out = 12'b000101110111;  //G
				3'b111 : out = 12'b000001010101;  //H
				endcase
		end
	
endmodule

//12-bit shift register
module reg12bit(D,W,Q,clock,resetn,start,enable,shift_out,NewBitOut,feedback_sig);
	input [11:0] D;
	input W,clock,resetn,start,enable;
	output reg [11:0] Q;
	output reg shift_out;
	reg load;
	reg [3:0] count;
	output reg NewBitOut;
	output reg feedback_sig;

	
	//create memory for the start bit and make this control load
//	always @(posedge start)
//		begin
//			if(start == 1)
//				load <= 1;
////			else if(load == 1)
////				load <= 0;
//		end
	
	//assign W = 0; //constantly 0  can't do this, just set a 0 to this when instantiating
	always @ (negedge resetn, posedge clock /*,posedge start*/)
		begin
			if(resetn == 0)
				begin
					Q <= 0;
					feedback_sig <= 0;
				end
			else if(start == 1)
				begin
				load <= 1;
				feedback_sig <= 1;
				//count <= 12;
				end
			else if(load == 1)
				begin
					Q <= D;
					load <= 0;
					feedback_sig <= 0;
				end
			else if(enable)
				//shift
				begin
					Q[11] <= W;
					Q[10] <= Q[11];
					Q[9] <= Q[10];
					Q[8] <= Q[9];
					Q[7] <= Q[8];
					Q[6] <= Q[7];
					Q[5] <= Q[6];
					Q[4] <= Q[5];
					Q[3] <= Q[4];
					Q[2] <= Q[3];
					Q[1] <= Q[2];
					Q[0] <= Q[1];
					shift_out <= Q[0];
					feedback_sig <= 0;
					//count <= count -1;
				end		
		end		
	
	always @ (negedge resetn, posedge clock)
		begin	
			if(resetn == 0)
				count <= 0;
			else if(start == 1)
				count <= 4'd12;
			else if(enable && count !== 0)
				begin
					count <= count -1;
					NewBitOut <= enable;
				end
			else
				NewBitOut <= 0;

			//else if(count !== 0)
			//	begin
			//		NewBitOut <= enable;
			//	end
		end
		
		
endmodule
