`timescale 1ms / 1us

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:30:08 03/11/2021
// Design Name:   parking_meter
// Module Name:   C:/Users/myLaptop/Project4/testbench_105375663.v
// Project Name:  Project4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: parking_meter
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
	reg add1;
	reg add2;
	reg add3;
	reg add4;
	reg rst1;
	reg rst2;
	reg clk;
	reg rst;

	// Outputs
	wire [6:0] led_seg;
	wire a4;
	wire a3;
	wire a2;
	wire a1;
	wire [3:0] val4;
	wire [3:0] val3;
	wire [3:0] val2;
	wire [3:0] val1;
	
	integer i;

	// Instantiate the Unit Under Test (UUT)
	parking_meter uut ( 
		.add1(add1), 
		.add2(add2), 
		.add3(add3), 
		.add4(add4), 
		.rst1(rst1), 
		.rst2(rst2), 
		.clk(clk), 
		.rst(rst), 
		.led_seg(led_seg), 
		.a4(a4), 
		.a3(a3), 
		.a2(a2), 
		.a1(a1), 
		.val4(val4), 
		.val3(val3), 
		.val2(val2), 
		.val1(val1)
	);

	initial begin
		// Initialize Inputs
		add1 = 0;
		add2 = 0;
		add3 = 0;
		add4 = 0;
		rst1 = 0;
		rst2 = 0;
		clk = 1;
		rst = 1;
		
		// reset and check that in the INIT state, 0 flashes every half a second
		#10 rst = 0;
		#1990 add1 = 1;
		
		// use all the coins and see if they add correctly
		// also see if led displays only even time every other second
		#10 add1 = 0; add2 = 1;
		#10 add2 = 0; add3 = 1;
		#10 add3 = 0; add4 = 1;
		#10 add4 = 0; rst1 = 1;
		#10 rst1 = 0; rst2 = 1;
		#10 rst2 = 0;
		
		// add time to more then 180 and see if the time is always displayed
		// also check if time is decrementing
		#3940 add4 = 1;
		#10 add4 = 0;
		
		// meter_time will cap at 9999
		for(i = 0; i < 35; i = i + 1) 
			begin
			#10 add4 = 1;
			#10 add4 = 0;
			end
		#10 add1 = 1;
		#10 add1 = 0;
		#10 add2 = 1;
		#10 add2 = 0;
		#10 add3 = 1;
		#10 add3 = 0;
		
		// going to TIME_MORE_THAN_180 when rst2 goes high in TIME_MORE_THAN_180 state
		#10 rst2 = 1;
		#10 rst2 = 0;
		
		// rst interrupt, should go back to INIT immediately
		#3000 rst = 1;
		#10 rst = 0;
		
		// going to TIME_LESS_THAN_180 when rst1 goes high in INIT state
		#2000 rst1 = 1;
		#10 rst1 = 0; 
		
		// coin insert is less than a full clock cycle
		#2000 add2 = 1;
		#5 add2 = 0;
		
		// add signal detected during same time that meter_time needs to go down
		#1985 add1 = 1;
		#10 add1 = 0;
		
		#3000 $finish;
	end
	
	always #5 clk <= ~clk;
      
endmodule

