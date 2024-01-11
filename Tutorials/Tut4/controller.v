`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:18 02/18/2008 
// Design Name: 
// Module Name:    controller 
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
module controller(Clock, reset, sensor0, sensor1, sensor2, sensor3, lightNorthSouth, lightEastWest);
    input Clock;
    input reset;
    input sensor0;
    input sensor1;
    input sensor2;
    input sensor3;
    output [1:0] lightNorthSouth;
    output [1:0] lightEastWest;
	 
	 wire sensorEastWest, sensorNorthSouth;
	 
	 reg [63:0] count5, count10;
	 reg [3:0] State, NextState, delay5, delay10;
	 reg [1:0] lightNorthSouth, lightEastWest;
	 reg delay5done, delay10done;
	 
	 assign sensorEastWest = ((!sensor1) || (!sensor3));
	 assign sensorNorthSouth = ((!sensor0) || (!sensor2));
	 
	 always@(posedge Clock) begin
		if(!reset)
			State <= 0;
		else
			State <= NextState;
	 end
	 
	 always@(State, sensorEastWest, sensorNorthSouth, delay5done, delay10done) begin
			case(State)
				4'd0 : begin
								if(sensorEastWest)									
									NextState <= 4'd1;
								else
									NextState <= 4'd0;
									
								lightNorthSouth <= 2'b10;
								lightEastWest <= 2'b00;
								delay5 <= 0;
								delay10 <= 0;
						 end
						 
			   4'd1 : begin
								if(delay5done) 
									NextState <= 4'd2;
								else
									NextState <= 4'd1;
									
								lightNorthSouth <= 2'b10;
								lightEastWest <= 2'b00;
								delay5 <= 1;
								delay10 <= 0;
						end
						
				4'd2 : begin
								if(delay10done)
									NextState <= 4'd3;
								else
									NextState <= 4'd2;
							
								lightNorthSouth <= 2'b01;
								lightEastWest <= 2'b00;
								delay5 <= 0;
								delay10 <= 1;
						end
						
			  4'd3 : begin
							if(sensorNorthSouth)
								NextState <= 4'd4;
							else
								NextState <= 4'd3;
								
							lightNorthSouth <= 2'b00;
							lightEastWest <= 2'b10;
							delay5 <= 0;
							delay10 <= 0;
						end
						
			  4'd4 : begin
							if(delay5done)
								NextState <= 4'd5;
							else
								NextState <= 4'd4;
							
							lightNorthSouth <= 2'b00;
							lightEastWest <= 2'b10;
							delay5 <= 1;
							delay10 <= 0;
						end
						
			  4'd5 : begin
							if(delay10done)
								NextState <= 4'd0;
							else
								NextState <= 4'd5;
								
							lightNorthSouth <= 2'b00;
							lightEastWest <= 2'b01;
							delay5 <= 0;
							delay10 <= 0;
						end
			default : begin
					    lightNorthSouth <= 2'b00;
						 lightEastWest <= 2'b00;
						 delay5 <= 0;
						 delay10 <= 0;
						 end
		endcase
	end

	//This is the timer which counts to 5 seconds on yellow light
	always@(posedge Clock) begin
		if(!delay5)
			count5 <= 0;
		else
			count5 <= count5 + 1;
	end
	
	//This is the timer which counts to 10 seconds on a light Change
	always@(posedge Clock) begin
		if(!delay10)
			count10 <= 0;
		else
			count10 <= count10 + 1;
	end
	
	
	always@(count5, count10) begin
		if(count5 > 32'd500000000)
			delay5done <= 1;
		else
			delay5done <= 0;
		
		if(count10 > 32'd1000000000)
			delay10done <= 1;
		else
			delay10done <= 0;
	end
	
	
endmodule
