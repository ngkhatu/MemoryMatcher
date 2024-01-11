`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:26:10 02/18/2008 
// Design Name: 
// Module Name:    datapath 
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
module datapath(Clock, reset, lightNorthSouth, lightEastWest, light0, light1, light2, light3);
    input Clock;
    input reset;
    input [1:0] lightNorthSouth;
    input [1:0] lightEastWest;
    output light0;
    output light1;
    output light2;
    output light3;
 
	 wire flashNorthSouth, flashEastWest;
	 wire redNS, yellowNS, greenNS, redEW, yellowEW, greenEW;
	 
	 assign light0 = flashNorthSouth;
	 assign light1 = flashNorthSouth;
	 assign light2 = flashEastWest;
	 assign light3 = flashEastWest;
	 
	flasher flashNS (
    .Clock(Clock), 
    .reset(reset), 
    .red(redNS), 
    .yellow(yellowNS), 
    .green(greenNS), 
    .flashOut(flashNorthSouth)
    );
	 
	 flasher flashEW (
    .Clock(Clock), 
    .reset(reset), 
    .red(redEW), 
    .yellow(yellowEW), 
    .green(greenEW), 
    .flashOut(flashEastWest)
    );
	 
	 lightController controlNS (
    .Clock(Clock), 
    .reset(reset), 
    .lightMode(lightNorthSouth), 
    .red(redNS), 
    .yellow(yellowNS), 
    .green(greenNS)
    );
	 
	 lightController controlEW (
    .Clock(Clock), 
    .reset(reset), 
    .lightMode(lightEastWest), 
    .red(redEW), 
    .yellow(yellowEW), 
    .green(greenEW)
    );
endmodule
