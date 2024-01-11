`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:50:13 02/18/2008 
// Design Name: 
// Module Name:    lightController 
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
module lightController(Clock, reset, lightMode, red, yellow, green);
    input Clock;
    input reset;
    input [1:0] lightMode;
    output red;
    output yellow;
    output green;

	reg red, yellow, green;
	reg [3:0] State, NextState;

	always@(posedge Clock) begin
		if(!reset) 
			State <= 0;
		else
			State <= NextState;
	end
	
	always@(State, lightMode) begin
		case(State) 
		
		4'd0 : begin
				 case(lightMode)
					2'b00 : begin
							  NextState <= 4'd0;
							  end
					2'b10 : begin
							  NextState <= 4'd1;
							  end
					default : begin
								 NextState <= 4'd3;
								 end
				 endcase
				 
				 red <= 1;
				 yellow <= 0;
				 green <= 0;
				 
				 end
		4'd1 : begin
				 case(lightMode)
					2'b01 : begin
							  NextState <= 4'd2;
							  end
				   2'b10 : begin
							  NextState <= 4'd1;
							  end
				   default : begin
							     NextState <= 4'd3;
						        end
			   endcase
				
				red <= 0;
				yellow <= 0;
				green <= 1;
				
				end
	  4'd2 : begin
				case(lightMode) 
					2'b00 : begin
							  NextState <= 4'd0;
							  end
				   2'b01 : begin
							  NextState <= 4'd2;
							  end
					default : begin
								 NextState <= 4'd3;
								 end
			  endcase
			  
			  red <= 0;
			  yellow <= 1;
			  green <= 0;
			  
			  end
	  default : begin
				NextState <= 4'd3;
				red <= 1;
				yellow <= 0;
				green <= 0;
				end
	  
	  endcase
 
 end

endmodule
