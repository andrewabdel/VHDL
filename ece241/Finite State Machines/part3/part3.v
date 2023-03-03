`timescale 1ns/1ns
//Sw[7:0] data_in

//KEY[0] synchronous reset when pressed
//KEY[1] go signal

//LEDR displays result
//HEX0 & HEX1 also displays result
module part3(Clock, Resetn, Go, Divisor, Dividend, Quotient, Remainder, ResultValid, dividend, regA);
	 input Clock, Resetn, Go;
	 input [3:0] Divisor, Dividend;
	 output [3:0] Quotient, Remainder;
	 output ResultValid;
	 //wires 
	 wire w_divisor_load, w_mux_sel, w_regA_load, w_dividend_load ;
	 wire w_ALU_sel;
	 wire w_shift_enable, w_sub_enable,w_quotient_load, w_remainder_load;
	 wire w_regA_reset, w_dividend_reset;
	 output [4:0] regA;
	 output [3:0] dividend;
	 
	 //instantiate modules
	 //control
		control u0(
			.clk(Clock),
			.resetn(Resetn),
			.go(Go),
			.divisor_load(w_divisor_load), .mux_sel(w_mux_sel), .regA_load(w_regA_load), .dividend_load(w_dividend_load), 
			.ALU_sel(w_ALU_sel),
			.shift_enable(w_shift_enable), .sub_enable(w_sub_enable), .result_valid(ResultValid), .quotient_load(w_quotient_load), .remainder_load(w_remainder_load),
			.regA_reset(w_regA_reset), .dividend_reset(w_dividend_reset)
			
		);
 
	 //datapath
		datapath u1(
		.divisor_in(Divisor), .dividend_in(Dividend),
		.divisor_load(w_divisor_load), .mux_sel(w_mux_sel), .regA_load(w_regA_load), .dividend_load(w_dividend_load), 
		.ALU_sel(w_ALU_sel),
		//.sig_to_control(),
		//.sig_response(),
		.clock(Clock),
		.resetn(Resetn),
		.shift_enable(w_shift_enable), .sub_enable(w_sub_enable),
		.quotient(Quotient), 
		.remainder(Remainder),
		.quotient_load(w_quotient_load),
		.remainder_load(w_remainder_load),
		.regA(regA),
		.dividend(dividend),
		.regA_reset(w_regA_reset), .dividend_reset(w_dividend_reset)
		);
	 
endmodule 

module datapath(
	input [3:0] divisor_in, dividend_in,
	input divisor_load, mux_sel, regA_load, dividend_load, 
	input ALU_sel,
	output reg sig_to_control,
	input sig_response,
	input clock,
	input resetn,
	input shift_enable, sub_enable,
	output reg [3:0] quotient, 
	output reg [4:0] remainder,
	input quotient_load,
	input remainder_load,
	output	reg [4:0] regA,
	output reg [3:0] dividend,
	input regA_reset,
	input dividend_reset
	);
	
	//registers

	//register for divisor
	reg [3:0] divisor;
	          
	
	//output of shift alu
	reg [4:0] regA_shifted;
	reg [3:0] dividend_shifted;
	
	//ALU subtract
	reg [4:0] sub_result;
	
	//last alu
	reg [4:0] ALU_regA_out;          
	reg [3:0] ALU_dividend_out; 
	
	
	
	//loading logic
	// Registers a, b, c, x with respective input logic, add one mux for x
    always@(posedge clock) begin
        if(!resetn) begin
            divisor <= 4'b0;
            regA <= 5'b0;
            dividend <= 4'b0;
				quotient <= 0;
				remainder <=0;
        end
        else begin
            if(divisor_load)
                divisor <= divisor_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
				if(quotient_load)
					quotient <= ALU_dividend_out;
            if(regA_load)
                regA <= ALU_regA_out; // 
				if(remainder_load)
					 remainder <= ALU_regA_out;
            if(dividend_load)
                dividend <= mux_sel ? ALU_dividend_out : dividend_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
				//reset registers 
				if(regA_reset)
					regA <= 0;
				if(dividend_reset)
					dividend <= 0;
        end
    end
	
	//shift ALU
	always @(*) begin
	if (shift_enable) begin
		regA_shifted[4] =  regA[3];
		regA_shifted[3] =  regA[2];
		regA_shifted[2] =  regA[1];
		regA_shifted[1] =  regA[0];
		regA_shifted[0] =  dividend[3];
		dividend_shifted[3] = dividend[2];
		dividend_shifted[2] = dividend[1];
		dividend_shifted[1] = dividend[0];
		dividend_shifted[0] = 0;
		end
	else begin
	regA_shifted = 0;
	dividend_shifted =0;
	
	end
		//nothing
	end
	
	//ALU subtract
	always @(*) begin
		if (sub_enable) begin
			sub_result = regA_shifted - divisor;
			sig_to_control = sub_result[4];
		end
		else begin
			sub_result = 0;
			sig_to_control = 0 ;
		
		end
		
	end
	
	//last ALU
	always @(*)begin
		case(sig_to_control)
			1: begin
						ALU_regA_out = divisor + sub_result;
						ALU_dividend_out = dividend_shifted;
					end
			0: begin
						ALU_regA_out = sub_result;
						ALU_dividend_out = dividend_shifted;
						ALU_dividend_out[0] = 1;
					end
		endcase
	end
	
	//quotient and remainder registers
//	always @ (posedge clock)
//		if(quotient_load)
//			quotient <= dividend;
//		else 
//			quotient <= 1;
//	always @ (posedge clock)
//		if(remainder_load)
//			remainder <= regA;
	
	
endmodule



module control(
    input clk,
    input resetn,
    input go,

	output reg divisor_load, mux_sel, regA_load, dividend_load, 
	output reg ALU_sel,
	output reg shift_enable, sub_enable, result_valid, quotient_load, remainder_load, regA_reset, dividend_reset
    );

    reg [5:0] current_state, next_state;

    localparam  S_LOAD          = 5'd0,
                S_LOAD_WAIT     = 5'd1,
                S_LOAD_B        = 5'd2,
                S_CYCLE_0       = 5'd3,
                S_CYCLE_1       = 5'd4,
                S_CYCLE_2       = 5'd5,
					 S_CYCLE_3       = 5'd6,
					 S_CYCLE_3_WAIT  = 5'd7;

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
                S_LOAD: next_state = go ? S_LOAD_WAIT : S_LOAD; // Loop in current state until value is input
                S_LOAD_WAIT: next_state = go ? S_LOAD_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
                S_CYCLE_0: next_state = S_CYCLE_1;
					 S_CYCLE_1: next_state = S_CYCLE_2;
					 S_CYCLE_2: next_state = S_CYCLE_3;
					 S_CYCLE_3: next_state = S_CYCLE_3_WAIT;
                S_CYCLE_3_WAIT: next_state = S_LOAD; // we will be done our two operations, start over after
            default:     next_state = S_LOAD;
        endcase
    end // state_table

	 
//		 //ADDITIONAL always block for initially setting resetvalid to 0 
//		always @(*) begin
//			if(!resetn)
//				result_valid = 1'b0;				
//		end

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
			divisor_load = 0;
			mux_sel = 0;
			regA_load = 0;
			dividend_load = 0;
			ALU_sel = 0;
			shift_enable = 0;
			sub_enable = 0;
			remainder_load = 0;
			quotient_load =0;
			regA_reset = 0; 
			dividend_reset =0;
			//result_valid = 0;
		  
		  //to reset result_valid to 0 at start
		  if(!resetn)begin
			   result_valid = 1'b0;	
			end
			
        case (current_state)
            S_LOAD: begin
                divisor_load = 1;
					 mux_sel =0;
					 dividend_load = 1;
					 shift_enable = 0;
					 sub_enable = 0;
                end
            S_LOAD_WAIT: begin
                result_valid = 0;
                end				 
            S_CYCLE_0: begin // Do B <- B * X
                divisor_load = 0; // store result back into B
                dividend_load = 1; // Select register X
                regA_load = 1; // Also select register B
                mux_sel = 1; // Do multiply operation
					 shift_enable = 1;
					 sub_enable = 1;
            end
            S_CYCLE_1: begin // Do B <- B * X
                divisor_load = 0; // store result back into B
                dividend_load = 1; // Select register X
                regA_load = 1; // Also select register B
                mux_sel = 1; // Do multiply operation
					 shift_enable = 1;
					 sub_enable = 1;
            end				
            S_CYCLE_2: begin // Do B <- B * X
                divisor_load = 0; // store result back into B
                dividend_load = 1; // Select register X
                regA_load = 1; // Also select register B
                mux_sel = 1; // Do multiply operation
					 shift_enable = 1;
					 sub_enable = 1;
					 //quotient_load = 1;
					 //remainder_load = 1;
            end
            S_CYCLE_3: begin // Do B <- B * X
                divisor_load = 0; // store result back into B
                dividend_load = 1; // Select register X
                regA_load = 1; // Also select register B
                mux_sel = 1; // Do multiply operation
					 shift_enable = 1;
					 sub_enable = 1;
					 quotient_load = 1;
					 remainder_load = 1;
					 regA_reset = 1;
					 dividend_reset =1;
            end							
            S_CYCLE_3_WAIT: begin // Do A <- A* X * X
					result_valid = 1; //delay by a clock cycle
					//quotient_load = 1;
					//remainder_load = 1;
            end	
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD;
        else
            current_state <= next_state;
    end // state_FFS
endmodule




module part2(Clock, Resetn, Go, DataIn, DataResult, ResultValid);
    input Clock;
    input Resetn;
    input Go;
    input [7:0] DataIn;
    output [7:0] DataResult;
    output ResultValid;

    // lots of wires to connect our datapath and control
    wire ld_a, ld_b, ld_c, ld_x, ld_r;
    wire ld_alu_out;
    wire [1:0]  alu_select_a, alu_select_b;
    wire alu_op;

    control C0(
        .clk(Clock),
        .resetn(Resetn),

        .go(Go),

        .ld_alu_out(ld_alu_out),
        .ld_x(ld_x),
        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c),
        .ld_r(ld_r),

        .alu_select_a(alu_select_a),
        .alu_select_b(alu_select_b),
        .alu_op(alu_op),
        .result_valid(ResultValid)
    );

    datapath D0(
        .clk(Clock),
        .resetn(Resetn),

        .ld_alu_out(ld_alu_out),
        .ld_x(ld_x),
        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c),
        .ld_r(ld_r),

        .alu_select_a(alu_select_a),
        .alu_select_b(alu_select_b),
        .alu_op(alu_op),

        .data_in(DataIn),
        .data_result(DataResult)
    );

 endmodule




module datapath1(
    input clk,
    input resetn,
    input [7:0] data_in,
    input ld_alu_out,
    input ld_x, ld_a, ld_b, ld_c,
    input ld_r,
    input alu_op,
    input [1:0] alu_select_a, alu_select_b,
    output reg [7:0] data_result
    );

    // input registers
    reg [7:0] a, b, c, x;

    // output of the alu
    reg [7:0] alu_out;
    // alu input muxes
    reg [7:0] alu_a, alu_b;

    // Registers a, b, c, x with respective input logic, add one mux for x
    always@(posedge clk) begin
        if(!resetn) begin
            a <= 8'b0;
            b <= 8'b0;
            c <= 8'b0;
            x <= 8'b0;
        end
        else begin
            if(ld_a)
                a <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_b)
                b <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_x)
                x <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_c)
                c <= data_in;
        end
    end

    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            data_result <= 8'b0;
        end
        else
            if(ld_r)
                data_result <= alu_out;
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            2'd0:
                alu_a = a;
            2'd1:
                alu_a = b;
            2'd2:
                alu_a = c;
            2'd3:
                alu_a = x;
            default: alu_a = 8'b0;
        endcase

        case (alu_select_b)
            2'd0:
                alu_b = a;
            2'd1:
                alu_b = b;
            2'd2:
                alu_b = c;
            2'd3:
                alu_b = x;
            default: alu_b = 8'b0;
        endcase
    end

    // The ALU
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            1: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
            default: alu_out = 8'b0;
        endcase
    end

endmodule
