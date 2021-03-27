`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Belle Lerdworatawee
// 
// Create Date:    21:25:33 01/31/2021 
// Design Name: 
// Module Name:    clock_gen 
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
module clock_gen(
    input clk_in,
    input rst,
    output clk_div_2,
    output clk_div_4,
    output clk_div_8,
    output clk_div_16,
    output clk_div_28,
    output clk_div_5,
    output [7:0] toggle_counter
    );
	 
	 clock_div_two task_one(
		.clk_in    (clk_in),
		.rst       (rst),
		.clk_div_2 (clk_div_2),
		.clk_div_4 (clk_div_4),
		.clk_div_8 (clk_div_8),
		.clk_div_16(clk_div_16)
	 );
	 
	 clock_div_twenty_eight task_two(
		.clk_in    (clk_in),
		.rst       (rst),
		.clk_div_28(clk_div_28)
	 );
	 
	 clock_div_five task_three(
		.clk_in   (clk_in),
		.rst      (rst),
		.clk_div_5(clk_div_5)
	 );
	 
	 clock_strobe task_four(
		.clk_in         (clk_in),
		.rst            (rst),
		.toggle_counter (toggle_counter)
	 );
	 
endmodule

// Task 1

module counter4Bit(
    input clk,
    input rst,
    output reg[3:0] a
    );
    
    always @(posedge clk)
	    begin
		if(rst)
		    a <= 4'd0;
		else
		    a <= a + 1'b1;
	    end
endmodule

module clock_div_two(
	input clk_in, 
	input rst, 
	output clk_div_2,
	output clk_div_4,
	output clk_div_8,
	output clk_div_16
	);
	
	wire [3:0] a;
	
	// initializing a 4-bit counter
	counter4Bit c1(
		.clk(clk_in),
		.rst(rst),
		.a(a)
	);
	 
	assign clk_div_2 = a[0];
	assign clk_div_4 = a[1];
	assign clk_div_8 = a[2];
	assign clk_div_16 = a[3];
endmodule

// Task 2

module clock_div_thirty_two(
	input clk_in, 
	input rst, 
	output reg clk_div_32
	);
	
	reg [3:0] a;
	
	always @(posedge clk_in) 
		begin
		if (rst) 
			begin
			a <= 4'd0;
			clk_div_32 <= 1'b0;
			end
		else if (a == 4'd15) 
			begin
			a <= a + 1'b1;
			clk_div_32 <= ~clk_div_32;
			end
		else
			a <= a + 1'b1;
    		end
endmodule

module clock_div_twenty_eight(
	input clk_in, 
	input rst, 
	output reg clk_div_28
	);
	
	reg [3:0] a;
	
	always @(posedge clk_in) 
		begin
		if(rst) 
			begin
			a <= 4'd0;
			clk_div_28 <= 1'b0;
			end
		else if(a == 4'd13) 
			begin
			a <= 4'd0;
			clk_div_28 <= ~clk_div_28;
			end
		else
			a <= a + 1'b1;
    end
endmodule

// Task 3

module clock_33_duty(
	input clk_in,
	input rst,
	output reg clk_33_duty_pos,
	output reg clk_33_duty_neg,
	output clk_or
	);
	
	// counters
	reg [1:0] a;
	reg [1:0] b;
	
	// positive edge triggered
	always @(posedge clk_in) 
		begin
		if(rst) 
			begin
          		a <= 2'd0;
			clk_33_duty_pos <= 1'b0;
			end
		else if (a == 2'b01) 
			begin // flip up at 1
			a <= a + 1'b1;
			clk_33_duty_pos <= ~clk_33_duty_pos;
			end
		else if (a == 2'b10) 
			begin // reset at 2
			a <= 2'd0;
			clk_33_duty_pos <= ~clk_33_duty_pos;
			end
		else
          		a <= a + 1'b1;
   		end
	
	// negative edge triggered
	always @(negedge clk_in) 
		begin
		if(rst) 
			begin
          		b <= 2'd0;
			clk_33_duty_neg <= 1'b0;
			end
		else if (b == 2'b01) 
			begin // flip up at 1
			b <= b + 1'b1;
			clk_33_duty_neg <= ~clk_33_duty_neg;
			end
		else if (b == 2'b10) 
			begin // reset at 2
			b <= 2'd0;
			clk_33_duty_neg <= ~clk_33_duty_neg;
			end
		else
          		b <= b + 1'b1;
   		end
	
	assign clk_or = clk_33_duty_pos || clk_33_duty_neg;	
endmodule

module clock_div_five(
	input clk_in,
	input rst,
	output clk_div_5
	);
	
	reg clk_40_duty_pos;
	reg clk_40_duty_neg;
	reg [2:0] a;
	reg [2:0] b;
	
	// positive edge triggered
	always @(posedge clk_in) 
		begin
		if(rst) 
			begin
          		a <= 3'd0;
			clk_40_duty_pos <= 1'b0;
			end
		else if (a == 3'b010) 
			begin // flip at 2
			a <= a + 1'b1;
			clk_40_duty_pos <= ~clk_40_duty_pos;
			end
		else if (a == 3'b100) 
			begin // reset at 4
			a <= 3'd0;
			clk_40_duty_pos <= ~clk_40_duty_pos;
			end
		else
          		a <= a + 1'b1;
   		end
	
	// negative edge triggered
	always @(negedge clk_in) 
		begin
		if (rst) 
			begin
          		b <= 3'd0;
			clk_40_duty_neg <= 1'b0;
			end
		else if (b == 3'b010) 
			begin // flip at 2
			b <= b + 1'b1;
			clk_40_duty_neg <= ~clk_40_duty_neg;
			end
		else if (b == 3'b100) 
			begin // reset at 4
			b <= 3'd0;
			clk_40_duty_neg <= ~clk_40_duty_neg;
			end
		else
          		b <= b + 1'b1;
   		end
	
	assign clk_div_5 = clk_40_duty_pos || clk_40_duty_neg;	
endmodule

// Task 4

module clock_div_100 (
	input clk_in,
	input rst,
	output reg clk_div_100,
	output reg clk_div_200,
	reg [6:0] a
	);
	
	// 100 block
	always @(posedge clk_in) 
		begin
		if (rst) 
			begin
			a <= 7'd0;
			clk_div_100 <= 1'b0;
			clk_div_200 <= 1'b0;
			end
		else if (a == 7'd98) 
			begin // flip up at 98
			a <= a + 1'b1;
			clk_div_100 <= ~clk_div_100;
			end
		else if (a == 7'd99) 
			begin // reset at 99
			a <= 7'd0;
			clk_div_100 <= ~clk_div_100;
			end
		else
			a <= a + 1'b1;
			
		if (clk_div_100 == 1'b1) // for 200 clock
			clk_div_200 <= ~clk_div_200;
		end
endmodule

module clock_strobe(
	input clk_in,
	input rst,
	output reg [7:0] toggle_counter
	);
	
	reg [1:0] strobe;
	
	always @(posedge clk_in) 
		begin
		if (rst) 
			begin
			strobe <= 2'd0;
			toggle_counter <= 7'd0;
			end
		else if (strobe == 2'd3) 
			begin // subtract 5 on strobe
			strobe <= strobe + 1'b1;
			toggle_counter <= toggle_counter - 7'd5;
			end
		else 
			begin
			strobe <= strobe + 1'b1;
			toggle_counter <= toggle_counter + 7'd2;
			end
		end
endmodule
