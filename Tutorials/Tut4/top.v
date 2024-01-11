`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:23:00 02/18/2008 
// Design Name: 
// Module Name:    top 
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
module top(Clock, reset, sensor0, sensor1, sensor2, sensor3, light0, light1, light2, light3);
    input Clock;
    input reset;
    input sensor0;
    input sensor1;
    input sensor2;
    input sensor3;
    output light0;
    output light1;
    output light2;
    output light3;
	 
	 wire newClock, locked;
	 wire [1:0] lightNorthSouth, lightEastWest;
	 
	 controller myController (
    .Clock(Clock), 
    .reset(reset), 
    .sensor0(sensor0), 
    .sensor1(sensor1), 
    .sensor2(sensor2), 
    .sensor3(sensor3), 
    .lightNorthSouth(lightNorthSouth), 
    .lightEastWest(lightEastWest)
    );
	 
	 datapath myDataPath (
    .Clock(Clock), 
    .reset(reset), 
    .lightNorthSouth(lightNorthSouth), 
    .lightEastWest(lightEastWest), 
    .light0(light0), 
    .light1(light1), 
    .light2(light2), 
    .light3(light3)
    );

endmodule
