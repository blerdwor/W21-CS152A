`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   05:44:06 02/27/2021
// Design Name:   vending_machine
// Module Name:   /home/ise/Desktop/ProjectThree/testbench_105375663.v
// Project Name:  Project3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vending_machine
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
	reg CLK;
	reg RESET;
	reg RELOAD;
	reg CARD_IN;
	reg [3:0] ITEM_CODE;
	reg KEY_PRESS;
	reg VALID_TRAN;
	reg DOOR_OPEN;

	// Outputs
	wire VEND;
	wire INVALID_SEL;
	wire [2:0] COST;
	wire FAILED_TRAN;

	// Instantiate the Unit Under Test (UUT)
	vending_machine uut (
		.CLK(CLK), 
		.RESET(RESET), 
		.RELOAD(RELOAD), 
		.CARD_IN(CARD_IN), 
		.ITEM_CODE(ITEM_CODE), 
		.KEY_PRESS(KEY_PRESS), 
		.VALID_TRAN(VALID_TRAN), 
		.DOOR_OPEN(DOOR_OPEN), 
		.VEND(VEND), 
		.INVALID_SEL(INVALID_SEL), 
		.COST(COST), 
		.FAILED_TRAN(FAILED_TRAN)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RESET = 1;
		RELOAD = 0;
		CARD_IN = 0;
		ITEM_CODE = 0;
		KEY_PRESS = 0;
		VALID_TRAN = 0;
		DOOR_OPEN = 0;

		// Successful transaction
		#10
		RESET = 0;
		RELOAD = 1;
		#25
		RELOAD = 0;
		KEY_PRESS = 1;
		ITEM_CODE = 4'd1;
		VALID_TRAN = 1;
		DOOR_OPEN = 1;
		CARD_IN = 1;
		#25
		ITEM_CODE = 4'd3;
		#20
		DOOR_OPEN = 0;
		CARD_IN = 0;
		
		// Successful transaction 2
		#10
		ITEM_CODE = 4'd0;
		DOOR_OPEN = 1;
		CARD_IN = 1;
		#35
		ITEM_CODE = 4'd6;
		#20
		DOOR_OPEN = 0;
		CARD_IN = 0;
		
 		// timeout on code1 
		#10
		KEY_PRESS = 0;
		CARD_IN = 1;
		#60 
		CARD_IN = 0;
		
		// timeout on code2
		#10
		KEY_PRESS = 1;
		ITEM_CODE = 4'd0;
		CARD_IN = 1;
		#10 
		KEY_PRESS = 0;
		CARD_IN = 0;
		
		// no valid_tran signal
		#65
		VALID_TRAN = 0;
		CARD_IN = 1;
		KEY_PRESS = 1;
		ITEM_CODE = 1'b0000;
		#30
		CARD_IN = 0;
		
		// code is invalid (22 is too high)
		#100
		CARD_IN = 1;
		ITEM_CODE = 4'd11;
		VALID_TRAN = 1;
		
		// reload goes high while not in idle
		#20
		RELOAD = 1;
		CARD_IN = 0;
		
		// card_in goes high while reload
		#40
		RELOAD = 0;
		CARD_IN = 1;
		
		// door doesn't open for 5 cycles
		ITEM_CODE = 4'd1;
		DOOR_OPEN = 0;
		
		// reset while waiting for door to close
		// also shows invalid selection when there are 0 snacks
		#100
		DOOR_OPEN = 1;
		#150
		RESET = 1;
		#10 
		RESET = 0;
		
		// finish
		#100 $finish;
	end
	
	// generate 100 MHz clock
	always #5 CLK = ~CLK;
	
endmodule