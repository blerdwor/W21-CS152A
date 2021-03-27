`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:03:31 01/31/2021
// Design Name:   clock_gen
// Module Name:   /home/ise/Desktop/Project2/testbench_105375663.v
// Project Name:  Project2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: clock_gen
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench_105375663;

	// Inputs
	reg clk_in;
	reg rst;

	// Outputs
	wire clk_div_2;
	wire clk_div_4;
	wire clk_div_8;
	wire clk_div_16;
	wire clk_div_28;
	wire clk_div_5;
	wire [7:0] toggle_counter;
	
	// for additional testing
	wire clk_div_32;
	wire clk_33_duty_pos;
	wire clk_33_duty_neg;
	wire clk_or;
	wire clk_div_100;
	wire clk_div_200;
	// wire [3:0] a;
	wire [6:0] b;

	// Instantiate the Unit Under Test (UUT)
	clock_gen uut (
		.clk_in(clk_in), 
		.rst(rst), 
		.clk_div_2(clk_div_2), 
		.clk_div_4(clk_div_4), 
		.clk_div_8(clk_div_8), 
		.clk_div_16(clk_div_16), 
		.clk_div_28(clk_div_28), 
		.clk_div_5(clk_div_5), 
		.toggle_counter(toggle_counter)
	);
	
	clock_div_thirty_two uut_32(
		.clk_in(clk_in), 
		.rst(rst), 
		.clk_div_32(clk_div_32)
	);
	
	/*counter4Bit uut_count (
		.clk(clk_in),
		.rst(rst),
		.a(a)
	);*/
	
	clock_33_duty uut_clk33(
		.clk_in(clk_in), 
		.rst(rst), 
		.clk_33_duty_pos(clk_33_duty_pos),
		.clk_33_duty_neg(clk_33_duty_neg),
		.clk_or(clk_or)
	);
	
	clock_div_100 uut_clk100(
		.clk_in(clk_in), 
		.rst(rst), 
		.clk_div_100(clk_div_100),
		.clk_div_200(clk_div_200),
		.a(b)
	);

	initial begin
		// Initialize Inputs
		clk_in <= 1;
		rst <= 1;

		// add stimulus
		#10; rst <= 0;
		
		# 1000;
		$finish;
	end
	
	// generate 100 MHz clock
	always #5 clk_in = ~clk_in; 

endmodule

