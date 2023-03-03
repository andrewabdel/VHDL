`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[2:0] data inputs
//SW[9] select signals

//LEDR[0] output display

//top level module

module mux(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;

    mux2to1 u0(
        .x(SW[0]),
        .y(SW[1]),
        .s(SW[9]),
        .m(LEDR[0])
        );
endmodule


//six inverters
module v7404 (pin1, pin3, pin5, pin9, pin11, pin13, pin2, pin4, pin6, pin8,
pin10, pin12);
	input pin1, pin3, pin5, pin9, pin11, pin13;
	output pin2, pin4, pin6, pin8, pin10, pin12;
	
	//pin assignments
	assign pin2 = !pin1;
	assign pin4 = !pin3;
	assign pin6 = !pin5;
	assign pin8 = !pin9;
	assign pin10 = !pin11;
	assign pin12 = !pin13;
	
endmodule

//four 2-input AND gates
module v7408 (pin1, pin3, pin5, pin9, pin11, pin13, pin2, pin4, pin6, pin8,
pin10, pin12);
	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	
	//pin assignments
	assign pin3 = pin1 & pin2;
	assign pin6 = pin4 & pin5;
	assign pin8 = pin9 & pin10;
	assign pin11 = pin12 & pin13;
	
endmodule

//four 2-input OR gates
module v7432 (pin1, pin3, pin5, pin9, pin11, pin13, pin2, pin4, pin6, pin8,
pin10, pin12);
	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	
	//pin assignments
	assign pin3 = pin1 | pin2;
	assign pin6 = pin4 | pin5;
	assign pin8 = pin9 | pin10;
	assign pin11 = pin12 | pin13;
	
endmodule

module mux2to1(x, y, s, m);
	
	input x,y,s;
	output m;
	//create wires
	wire w1, w2, w3;

	//instantiate 7404 (not gate)
	v7404 u0(.pin1(s), .pin2(w1));
	
	//instantiate 7408 (and gate)
	v7408 u1(.pin1(w1), .pin2(x), .pin3(w2), .pin4(s), .pin5(y), .pin6(w3));
	
	//instatiate 7432 (or gate)
	v7432 u2(.pin1(w2), .pin2(w3), .pin3(m));
	
	
endmodule
