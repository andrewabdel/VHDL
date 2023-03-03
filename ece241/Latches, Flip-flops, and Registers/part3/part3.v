`timescale 1ns / 1ns

module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset;
	input [1:0] ParallelLoadn, RotateRight, ASRight;
	input [7:0] Data_IN;
	output [7:0] Q;
	wire ASwire;
	
	//mux2to1 ASR(.x(Q[7]), .y(Q[0]), .sel(ASRight), .m(ASwire));
	
	muxFF b7(.LoadLeft(RotateRight), .D(Data_IN[7]), .loadn(ParallelLoadn), .right(Q[6]), .left(Q[0]), .clock(clock), .reset(reset), .Q(Q[7]));
	muxFF b6(.LoadLeft(RotateRight), .D(Data_IN[6]), .loadn(ParallelLoadn), .right(Q[5]), .left(Q[7]), .clock(clock), .reset(reset), .Q(Q[6]));
	muxFF b5(.LoadLeft(RotateRight), .D(Data_IN[5]), .loadn(ParallelLoadn), .right(Q[4]), .left(Q[6]), .clock(clock), .reset(reset), .Q(Q[5]));
	muxFF b4(.LoadLeft(RotateRight), .D(Data_IN[4]), .loadn(ParallelLoadn), .right(Q[3]), .left(Q[5]), .clock(clock), .reset(reset), .Q(Q[4]));
	muxFF b3(.LoadLeft(RotateRight), .D(Data_IN[3]), .loadn(ParallelLoadn), .right(Q[2]), .left(Q[4]), .clock(clock), .reset(reset), .Q(Q[3]));
	muxFF b2(.LoadLeft(RotateRight), .D(Data_IN[2]), .loadn(ParallelLoadn), .right(Q[1]), .left(Q[3]), .clock(clock), .reset(reset), .Q(Q[2]));
	muxFF b1(.LoadLeft(RotateRight), .D(Data_IN[1]), .loadn(ParallelLoadn), .right(Q[0]), .left(Q[2]), .clock(clock), .reset(reset), .Q(Q[1]));
	muxFF b0(.LoadLeft(RotateRight), .D(Data_IN[0]), .loadn(ParallelLoadn), .right(Q[7]), .left(Q[1]), .clock(clock), .reset(reset), .Q(Q[0]));
	
endmodule
	
	
	
//	always @ (posedge clock) begin
//		if (!reset) 
//			Q <= 0;
//		else if(ParallelLoadn == 0 & RotateRight == 1)
//			Q <= DATA_IN;
//		else
//			begin
//				Q[7] <= Q[0];
//				Q[6] <= Q[7];
//				Q[5] <= Q[6];
//				Q[4] <= Q[5];
//				Q[3] <= Q[4];
//				Q[2] <= Q[3];
//				Q[1] <= Q[2];
//				Q[0] <= Q[1];
//			end
////				Q[7] <= DATA_IN[7];
////				Q[6] <= DATA_IN[6];
////				Q[5] <= DATA_IN[5];
////				Q[4] <= DATA_IN[4];
////				Q[3] <= DATA_IN[3];
////				Q[2] <= DATA_IN[2];
////				Q[1] <= DATA_IN[1];
////				Q[0] <= DATA_IN[0];
////			end
////		else if (ParallelLoadn == 1 & RotateRight == 1 & ASRight == 0)
////			begin
////				Q[7] <= Q[0];
////				Q[6] <= Q[7];
////				Q[5] <= Q[6];
////				Q[4] <= Q[5];
////				Q[3] <= Q[4];
////				Q[2] <= Q[3];
////				Q[1] <= Q[2];
////				Q[0] <= Q[1];
////			end
////		else if(ParallelLoadn == 1 & RotateRight == 1 & ASRight == 1)
////			begin
////				Q[7] <= Q[7];
////				Q[6] <= Q[7];
////				Q[5] <= Q[6];
////				Q[4] <= Q[5];
////				Q[3] <= Q[4];
////				Q[2] <= Q[3];
////				Q[1] <= Q[2];
////				Q[0] <= Q[1];
////			end
////		else if(ParallelLoadn == 1 & RotateRight == 0)
////			begin
////				Q[7] <= Q[6];
////				Q[6] <= Q[5];
////				Q[5] <= Q[4];
////				Q[4] <= Q[3];
////				Q[3] <= Q[2];
////				Q[2] <= Q[1];
////				Q[1] <= Q[0];
////				Q[0] <= Q[7];
////			end
//	end
//endmodule
		
			
	
//	
//	always @ (*) begin
//		if (ParallelLoadn == 0) 
//		begin
//			always @ (posedge clock) begin
//				if (!reset) begin
//					Q <= 0;
//				end
//				else
//				
//			end
//		end
//			
//		 begin
//			always @ (posedge clock) 
//			begin
//				if (!reset) begin
//					Q <= 0;
//				end
//				else
//				begin
//					Q[7] <= Q[0];
//					Q[6] <= Q[7];
//					Q[5] <= Q[6];
//					Q[4] <= Q[5];
//					Q[3] <= Q[4];
//					Q[2] <= Q[3];
//					Q[1] <= Q[2];
//					Q[0] <= Q[1];
//				end
//			end
//		end
//		
//		else if(ParallelLoadn == 1 & RotateRight == 1 & ASRight == 1) begin
//			always @ (posedge clock) 
//				begin
//					if (!reset) begin
//						Q <= 0;
//					end
//					else
//					
//				end
//		end
//		
//		 begin
//			always @ (posedge clock) 
//			begin
//				if (!reset) begin
//					Q <= 0;
//				end
//				else
//				
//			end
//		end
//	
//	end
//	
//endmodule

module muxFF(LoadLeft, D, loadn, right, left, clock, reset, Q);
	input LoadLeft, D, loadn, right, left, clock, reset;
	output Q;
	
	wire Dinput, w;
	
	mux2to1 M1(.x(right), .y(left), .sel(LoadLeft), .m(w));
	mux2to1 M2(.x(D), .y(w), .sel(loadn), .m(Dinput));
	
	FF f1(.d(Dinput), .clock(clock), .reset(reset), .q(Q));
endmodule


module FF(d, clock, reset, q);
	input d, clock, reset;
	output reg q;
	
	always @ (posedge clock)
	begin
		if (reset == 1'b0)
			q <= 0;
		else
			q <= d;
	end
endmodule



module mux2to1(x, y, sel, m);
	input x, y, sel;
	output m;
	
	assign m = (~sel&x) | (sel&y);
endmodule

