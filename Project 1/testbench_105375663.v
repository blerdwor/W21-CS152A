`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:20:18 01/23/2021
// Design Name:   FPCVT
// Module Name:   /home/ise/Desktop/Project1/testbench_105375663.v
// Project Name:  Project1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FPCVT
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
	reg [12:0] D;

	// Outputs
	wire S;
	wire [2:0] E;
	wire [4:0] F;
	
	// additional wires
	wire [12:0] pos;
	wire [4:0] sig;
	wire [2:0] exp;
	wire sixth_bit;

	// Instantiate the Unit Under Test (UUT)
	FPCVT uut (
		.D(D), 
		.S(S), 
		.E(E), 
		.F(F)
	);
	
	convert_to_signMag c1(
		.d(D),
		.sign(S),
		.pos(pos)
	);

// here from earlier testing because my convert_to_float mod wasn't working
// 	convert_to_floatPoint f1(
// 		.num(pos), 
// 		.exp(exp), 
// 		.sig(sig), 
// 		.sixth_bit(sixth_bit)
// 	);

	initial begin
		#2000;
	end
	
	initial begin
 		// Initialize Inputs
		D = 13'b0_0000_0000_0000; // 0
		
		// here from earlier testing because my convert_to_float mod wasn't working
		// $monitor("num=%d=%13b sig=%5b exp=%3b sixth_bit=%1b",
      // 	         num, num, sig, exp, sixth_bit);
       
		// monitor FPCVT
      $monitor("D=%13b P=%13b S=%1b E=%3b F=%5b",
		          D, pos, S, E, F);
					 
		// Add stimulus here
		#100; D = 13'b1_1111_1111_1111; // -1 
		#100; D = 13'b0_1111_1111_1111; // 4095
		#100; D = 13'b1_0000_0000_0000; // -4096
		#100; D = 13'b0_0000_0000_0010; // 2, 8+ leading 0's
		#100; D = 13'b1_1111_1111_1110; // -2; 8+ leading 0's
		#100; D = 13'b1_1111_1001_1000; // -104, regular negative number
		#100; D = 13'b0_0000_0111_1000; // 50, regular positive number
		#100; D = 13'b0_0001_1010_0110; // 422, rounds to 416
		#100; D = 13'b0_0000_0110_1100; // 108, don't round the significand
		#100; D = 13'b0_0000_0110_1110; // 110, round the significand
		#100; D = 13'b0_0000_1111_1101; // 253, significand overflows and round significand
		#100; D = 13'b0_1111_1100_0000; // 4032, exponent and significand overflow
		#100;
		
		$finish;
	end

endmodule