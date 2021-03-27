`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Belle Lerdworatawee
// 
// Create Date:    02:27:59 02/27/2021 
// Design Name: 
// Module Name:    vending_machine 
// Project Name: 	 Project3
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vending_machine( 
    input CLK,
    input RESET,
    input RELOAD,
    input CARD_IN,
    input [3:0] ITEM_CODE,
    input KEY_PRESS,
    input VALID_TRAN,
    input DOOR_OPEN,
    output reg VEND,
    output reg INVALID_SEL,
    output reg [2:0] COST,
    output reg FAILED_TRAN
    );
	 
	 // declare states
	 parameter IDLE = 4'd0;
	 parameter GET_CODE1 = 4'd1;
	 parameter GET_CODE2 = 4'd2;
	 parameter CHECK_CODE_CARD = 4'd3;
	 parameter WAIT_DOOR_OPEN = 4'd4;
	 parameter WAIT_DOOR_CLOSE = 4'd5;
	 parameter BAD_CARD = 4'd6;
	 parameter BAD_CODE = 4'd7;
	 parameter RLD = 4'd8;
	 parameter RST = 4'd9;
	 
	 reg [3:0] current_state;
	 reg [3:0] next_state;
	 
	 reg [3:0] item_counter[19:0];
  	 reg [5:0] item_code1;
  	 reg [5:0] item_code2;
	 reg [5:0] item_code_dec;
	 reg start_timer;
	 reg start_timer2;
	 reg [2:0] timer;
	 reg [2:0] timer2;
	 reg count;
	 reg bad_code; 
  	 reg timeout;
	 reg key_in;
	 reg valid;
	 
	 integer i;
	 	 
	 // always block for state updates: sequential - triggered by clock
	 always@(posedge CLK) current_state <= next_state;
	 
	 // always block to time 5 cycles for GET_CODE1 and CHECK_CODE_CARD
	 always @ (posedge CLK)
    		begin
		if (start_timer)
			timer <= timer + 1'b1;
		else
			timer <= 3'b0;		
	 	end
	 
	 // always block to time 5 cycles for GET_CODE2 and WAIT_DOOR_OPEN
	 always @ (posedge CLK)
    		begin
		if (start_timer2)
			timer2 <= timer2 + 1'b1;
		else
			timer2 <= 3'b0;		
	 	end
		
	 // always block to decide next_state : combinational- triggered by state/input 
	 always @(*)
		if (RESET) 
         		next_state = RST;
	   	else case(current_state)
			IDLE: 
				begin
				if (RELOAD)
					next_state = RLD;
				else if (CARD_IN)
					next_state = GET_CODE1;
				end
			GET_CODE1: 
				begin
            			if (timeout == 1'd1) 
					next_state = IDLE;
            			else if (key_in == 1'b1)
					next_state = GET_CODE2;
				end
			GET_CODE2: 
				begin
				if (timeout == 1'd1) 
					next_state = IDLE;
				else if (key_in == 1'b1)
					next_state = CHECK_CODE_CARD;
				end
			CHECK_CODE_CARD: 
				begin
				if (bad_code == 1'b1)
					next_state = BAD_CODE;
            			else if (timeout == 1'b1)
					next_state = BAD_CARD;
				else if (valid)
					next_state = WAIT_DOOR_OPEN;
				end	
			WAIT_DOOR_OPEN:
				begin
				if (timeout == 1'b1)
					next_state = IDLE;
				else if (DOOR_OPEN)
					next_state = WAIT_DOOR_CLOSE;
				end
			WAIT_DOOR_CLOSE: 
				begin
				if (~DOOR_OPEN)
					next_state = IDLE;
				end
			default: 
				begin
				next_state = IDLE;
				end
			endcase
		
		//always block to decide outputs : triggered by state/inputs; can be comb/seq.
		always @(*)
			case(current_state)
				IDLE: 
					begin
					item_code1 = 5'd20;
					item_code2 = 5'd20;
					item_code_dec = 5'b0;
					bad_code = 1'b0;
					start_timer = 1'b0;
					start_timer2 = 1'b0;
					timeout = 1'b0;
					key_in = 1'b0;
					valid = 1'b0;
					
					VEND = 1'b0;
					INVALID_SEL = 1'b0;
					COST = 4'b0;
					FAILED_TRAN = 1'b0;
               				end
				GET_CODE1: 
					begin
					start_timer = 1'b1;
					start_timer2 = 1'b0;
					timeout = 1'b0;
					key_in = 1'b0;
					
					if (timer == 3'd4) 
						timeout = 1'b1;
					else if (KEY_PRESS)
						begin
						key_in = 1'b1;
						start_timer = 1'b0;
						if (ITEM_CODE == 4'b1)
							item_code1 = 5'd10;
						else if (ITEM_CODE == 4'b0)
							item_code1 = 5'd0;
						else
							item_code1 = 5'd20;
						end
					end
				GET_CODE2:  
					begin
					start_timer2 = 1'b1;
					start_timer = 1'b0;
					timeout = 1'b0;
					key_in = 1'b0;
					
					if (timer2 == 3'd4) 
						timeout = 1'b1;
					else if (KEY_PRESS)
						begin
						key_in = 1'b1;
						start_timer2 = 1'b0;
						item_code2 = {1'b0, ITEM_CODE};
						end
					end
				CHECK_CODE_CARD:
					begin
					start_timer = 1'b1;
					start_timer2 = 1'b0;
					timeout = 1'b0;
					item_code_dec = item_code1 + item_code2;
					
					// checks if code is valid or if there are 0 snacks
					// also checks if timer expired
					if (item_code_dec > 5'd19) 
						bad_code = 1'b1;
					else if (item_counter[item_code_dec] == 1'b0)
						bad_code = 1'b1;
					else if (timer == 3'd4)
						timeout = 1'b1;
					else 
						begin
						if (item_code_dec < 4)
							COST = 4'd1;
						else if (item_code_dec < 8)
							COST = 4'd2;
						else if (item_code_dec < 12)
							COST = 4'd3;
						else if (item_code_dec < 16)
							COST = 4'd4;
						else if (item_code_dec < 18)
							COST = 4'd5;
						else if (item_code_dec < 20)
							COST = 4'd6;
                      
						if (VALID_TRAN) 
							begin
							item_counter[item_code_dec] = item_counter[item_code_dec] - 1'b1;
							start_timer = 1'b0;
							valid = 1'b1;
							end
						end
					end
				BAD_CARD:
					FAILED_TRAN = 1'b1;
				BAD_CODE: 
					INVALID_SEL = 1'b1;
				WAIT_DOOR_OPEN: 
					begin
					VEND = 1'b1;
					timeout = 1'b0;
					start_timer2 = 1'b1;
					start_timer = 1'b0;
					if (timer2 == 3'd4) 
						timeout = 1'b1; 
					end
				RLD: 
					begin
					/*set all snack counters to 10*/
					for (i = 0; i < 20; i=i+1)
						item_counter[i] = 4'd10;
					VEND = 1'b0;
					INVALID_SEL = 1'b0;
					COST = 4'b0;
					FAILED_TRAN = 1'b0;
					end
				RST: 
					begin
					/*set all item counters and outputs set to 0*/
					for (i = 0; i < 20; i=i+1)
						item_counter[i] = 4'd0;
					VEND = 1'b0;
					INVALID_SEL = 1'b0;
					COST = 4'b0;
					FAILED_TRAN = 1'b0;
					end
				default: 
					begin
					VEND = 1'b0;
					INVALID_SEL = 1'b0;
					COST = 4'b0;
					FAILED_TRAN = 1'b0;
					end
			endcase
endmodule
