`timescale 1ms / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:15:38 03/11/2021 
// Design Name: 
// Module Name:    parking_meter 
// Project Name: 
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
module parking_meter(
    input add1,
    input add2,
    input add3,
    input add4,
    input rst1,
    input rst2,
    input clk,
    input rst,
    output reg [6:0] led_seg,
    output reg a4,
    output reg a3,
    output reg a2,
    output reg a1,
    output [3:0] val4,
    output [3:0] val3,
    output [3:0] val2,
    output [3:0] val1
    );
	 
	 // declare states
	 parameter INIT = 2'd0;
	 parameter TIME_LESS_THAN_180 = 2'd1;
	 parameter TIME_MORE_THAN_180 = 2'd2;
	 
	 reg [3:0] current_state;
	 reg [3:0] next_state;
	 
	 // intermediates
	 reg [13:0] new_meter_time;
	 reg [13:0] meter_time;
	 reg count_down;
	 wire [1:0] an_sel;
	 wire [6:0] clk_1Hz;
	 
	 // always block to catch any signals
	 always @(*)
		if (rst1)
			new_meter_time <= 16;
		else if (rst2)
			new_meter_time <= 150;
		else if ((meter_time >= 9939 && add1) ||
			 (meter_time >= 9879 && add2) ||
			 (meter_time >= 9819 && add3) ||
			 (meter_time >= 9699 && add4))
			new_meter_time <= 9999;
		else if (add1)
			new_meter_time <= meter_time + 60;
		else if (add2)
			new_meter_time <= meter_time + 120;
		else if (add3)
			new_meter_time <= meter_time + 180;
		else if (add4)
			new_meter_time <= meter_time + 300;
		else
			new_meter_time <= meter_time;
	 
	 // always block to decrement at a 1Hz clock
	 count_to_100 clock_1Hz(.clk_in(clk),.rst(rst),.counter(clk_1Hz));
	 always @(clk_1Hz)
		if (rst)
			count_down <= 0;
		else if (clk_1Hz == 0)
			count_down <= 1;
		else 
			count_down <= 0;
	 
	 // always block to update meter time
	 always @(posedge clk)
		if (rst)
			meter_time <= 0;
		else if (meter_time != new_meter_time && count_down && meter_time > 0)
			meter_time <= new_meter_time - 1;
		else if (meter_time != new_meter_time)
			meter_time <= new_meter_time;
		else if (count_down && meter_time > 0)
			meter_time <= meter_time - 1;
		else
			meter_time <= meter_time;
			
	 // always block for state updates: sequential - triggered by clock
	 always@(posedge clk) current_state <= next_state;
	 
	 // always block to decide next_state : combinational- triggered by state/input 
	 always @(*)
		if (rst) 
         		next_state = INIT;
	   	else case(current_state)
			INIT:
				begin
				if (rst1 || rst2)
					next_state = TIME_LESS_THAN_180;
				else if (meter_time == 0)
					next_state = INIT;
				else if (meter_time <= 180)
					next_state = TIME_LESS_THAN_180;
				else
					next_state = TIME_MORE_THAN_180;
				end
			TIME_LESS_THAN_180:
				begin
				if (rst1 || rst2 || meter_time <= 180)
					next_state = TIME_LESS_THAN_180;
				else
					next_state = TIME_MORE_THAN_180;
				end
			TIME_MORE_THAN_180:
				begin
				if (rst1 || rst2 || meter_time <= 180)
					next_state = TIME_LESS_THAN_180;
				else
					next_state = TIME_MORE_THAN_180;
				end
			default:
				next_state = INIT;
		endcase
		
		//always block to decide outputs : triggered by state/inputs; can be comb/seq.
		bcd_converter convert(.decimal(meter_time), .bcd4(val4), .bcd3(val3), .bcd2(val2), .bcd1(val1));
		count_to_4 anode_sel(.clk_in(clk), .rst(rst), .counter(an_sel));
		always @(*)
			case(current_state)
				INIT:
					begin
					if (clk_1Hz < 50) // flash for half a second
						begin
						a4 = 0;
						a3 = 0;
						a2 = 0;
						a1 = 0;
						led_seg = display_led(val4); // doesn't matter which value as they are all 0
						end
					else
						begin
						a4 = 1;
						a3 = 1;
						a2 = 1;
						a1 = 1;
						end
					end
				TIME_LESS_THAN_180:
					begin
					a4 = 1;
					a3 = 1;
					a2 = 1;
					a1 = 1;
					
					// turn anodes on for even numbers only
					if (meter_time % 2 == 0)
						begin
						case(an_sel)
							0: 
								begin
								a4 = 0;
								led_seg = display_led(val4);
								end
							1: 
								begin
								a3 = 0;
								led_seg = display_led(val3);
								end
							2:
								begin
								a2 = 0;
								led_seg = display_led(val2);
								end
							3:
								begin
								a1 = 0;
								led_seg = display_led(val1);
								end
						endcase
						end
					end
				TIME_MORE_THAN_180:
					begin
					a4 = 1;
					a3 = 1;
					a2 = 1;
					a1 = 1;
					
					// switch anodes
					case(an_sel)
						0: 
							begin
							a4 = 0;
							led_seg = display_led(val4);
							end
						1: 
							begin
							a3 = 0;
							led_seg = display_led(val3);
							end
						2:
							begin
							a2 = 0;
							led_seg = display_led(val2);
							end
						3:
							begin
							a1 = 0;
							led_seg = display_led(val1);
							end
						endcase
					end
			endcase
			
		function [6:0] display_led( input [4:1] bcd);
			begin
				case(bcd)
					0: display_led = 7'b1000000;
					1: display_led = 7'b1111001;
					2: display_led = 7'b0100100;
					3: display_led = 7'b0000110;
					4: display_led = 7'b0011001;
					5: display_led = 7'b0010010;
					6: display_led = 7'b0000010;
					7: display_led = 7'b1111000;
					8: display_led = 7'b0000000;
					9: display_led = 7'b0010000;
					default: display_led = 7'b1000000;
				endcase
			end
		endfunction 
endmodule

module bcd_converter(
	input [13:0] decimal,
	output [3:0] bcd4,
	output [3:0] bcd3,
	output [3:0] bcd2,
	output [3:0] bcd1
	);
	
	assign bcd4 = (decimal / 1000) % 10;
	assign bcd3 = (decimal / 100) % 10;
	assign bcd2 = (decimal / 10) % 10;
	assign bcd1 = decimal % 10;
	
endmodule

module count_to_100(
	input clk_in,
	input rst,
	output reg [6:0] counter
	);
	
	always @(posedge clk_in)
		if (rst)
			counter <= 0;
		else if (counter == 99) // reset at 100
			counter <= 0;
		else
			counter <= counter + 1;
endmodule

module count_to_4(
	input clk_in,
	input rst,
	output reg [1:0] counter
	);
	
	always @(posedge clk_in)
	if (rst)
		counter <= 0;
	else
		counter <= counter + 1;
endmodule 
