`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Belle Lerdworatawee
// 
// Create Date:    17:35:26 01/20/2021 
// Design Name: 
// Module Name:    FPCVT 
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
module FPCVT(
    input [12:0] D,
    output S,
    output [2:0] E,
    output [4:0] F
    );
	wire [12:0] num;
	wire [2:0] exp;
	wire [4:0] sig;
	wire sixth_bit;
	
	convert_to_signMag c1(
		.d(D), .sign(S), .pos(num)
		); // handles S
	
	convert_to_floatPoint f1(
		.num(num), .exp(exp), .sig(sig), .sixth_bit(sixth_bit)
		);
		
	round r1(
		.exp(exp), .sig(sig), .sixth_bit(sixth_bit), .E(E), .F(F)
		); // handles E and F
	
endmodule

module convert_to_signMag(
	input [12:0] d,
	output sign,
	output reg [12:0] pos
	);
	
	assign sign = d[12]; // sign just passes through 
	
	// convert negative numbers to positive
	// handle most negative number in special way 
	always @(d) begin
		if (d == 13'b1_0000_0000_0000)
			pos = 13'b0_1111_1111_1111;
		else if (d[12] == 1)
			pos = -d;
		else
			pos = d;
	end
	
endmodule

module convert_to_floatPoint(
	input [12:0] num,
	output reg [2:0] exp,
	output reg [4:0] sig,
	output reg sixth_bit
	);
	
	reg [12:0] temp;
	
	// priority encoder to count leading 0's
	always @(num) begin
		temp = 13'bx;
		casex(num[12:0])  
			13'b0_1xxx_xxxx_xxxx : begin // 1 leading 0 = exp 7
											exp = 3'b111;
											temp = num >> 6;
											sig = temp[5:1];
											sixth_bit = temp[0];
										  end
			13'b0_01xx_xxxx_xxxx: begin 
											exp = 3'b110;	// 2 " = exp 6
											temp = num >> 5;
											sig = temp[5:1];
											sixth_bit = temp[0];
										 end	
			13'b0_001x_xxxx_xxxx: begin 
											exp = 3'b101;	// 3 " = exp 5
											temp = num >> 4;
											sig = temp[5:1];
											sixth_bit = temp[0];
										 end	
			13'b0_0001_xxxx_xxxx: begin
											exp = 3'b100;	// 4 " = exp 4
											temp = num >> 3;
											sig = temp[5:1];
											sixth_bit = temp[0];
										 end	
			13'b0_0000_1xxx_xxxx: begin 
											exp = 3'b011;	// 5 " = exp 3
											temp = num >> 2;
											sig = temp[5:1];
											sixth_bit = temp[0];
										 end 	
			13'b0_0000_01xx_xxxx: begin 
											exp = 3'b010;	// 6 " = exp 2
											temp = num >> 1;
											sig = temp[5:1];
											sixth_bit = temp[0];
										 end	
			13'b0_0000_001x_xxxx: begin 
											exp = 3'b001;	// 7 " = exp 1
			                        sig = num[5:1];
											sixth_bit = num[0];
			                      end
			default: begin 
							exp = 3'b000;	// 8+ " = exp 0 
							sig = num[4:0];
							sixth_bit = 0;
						end
		endcase
	end
	
endmodule

module round(
    input [2:0] exp,
    input [4:0] sig,
    input [0:0] sixth_bit,
    output reg [2:0] E,
    output reg [4:0] F
    );
	 
	 always @(*) begin
		if (sixth_bit == 1) begin
			if (sig < 5'b1_1111) begin // no sig overflow
				E = exp;
				F = sig + 1;
			end
			else begin // sig overflow
				if (exp < 3'b111) begin // no exp overflow
					E = exp + 1;
					F = 5'b1_0000;
				end
				else begin // exp overflow
					E = 3'b111;
					F = 5'b1_1111;
				end
			end
		end
		else begin // no need for rounding
			E = exp;
			F = sig;
		end
	 end
	 
endmodule