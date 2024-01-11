//`timescale 1ns/10ps
module Controller (clock, reset, 
		   new,
		   ETX1, sp1, Match1,
		   StartAddress1, 
		   
		   ETX2, sp2, Match2,
		   StartAddress2,
		    
		   CharCount1, CharCount2, 
		   rd_en1, rd_en2, 
		   Address1, Address2
		  );
		  
 	input clock, reset;
 	input new;
 	input ETX1;
 	input sp1;
 	input Match1;
 	input ETX2;
 	input sp2;
 	input Match2;
 	input  	[9:0] 	StartAddress1;
 	input  	[9:0] 	StartAddress2;
 	
 	output  [2:0] 	CharCount1;
 	output  [9:0] 	Address1;
 	output  [2:0] 	CharCount2;
 	output  [9:0] 	Address2;
 	output			rd_en1;
 	output			rd_en2;
 	
 	reg				rd_en1, rd_en2;
 	reg 	[2:0] 	CharCount1;
 	reg 	[9:0] 	Address1;		  
 	reg 	[2:0] 	CharCount2;
 	reg 	[9:0] 	Address2;		  
	// Though not logically necessary, it saves power
	// to stop counting on ETX or Match

	always@(posedge clock) begin
	  	if (reset) 
	  		CharCount1 <= 4'h0;
		else if (new || sp1) 
			CharCount1 <= 4'h0;
	  	else if (!ETX1 && !Match1) 
	  		CharCount1 <= CharCount1 + 1'b1;
	end
	
	always@(posedge clock) begin
	  	if (reset) begin
	  		Address1 <= 10'h0;
	  		rd_en1	<=	1'b0;	
	  	end
	  	else if (new) begin
	  		Address1 <= StartAddress1;
	  		rd_en1	<=	1'b0; // active low read enable
	  	end 
	  	else if (!ETX1 && !Match1) begin
	  		Address1 <= Address1 + 1'b1;
	  		rd_en1	<=	1'b0;
	  	end
	  	else begin
	  		rd_en1	<=	1'b1; // Do Not read when not needed
	  	end
	end 

	always@(posedge clock) begin
	  	if (reset) 
	  		CharCount2 <= 4'h0;
		else if (new || sp2) 
			CharCount2 <= 4'h0;
	  	else if (!ETX2 && !Match2) 
	  		CharCount2 <= CharCount2 + 1'b1;
	end
	
	always@(posedge clock) begin
	  	if (reset) begin
	  		Address2 <= 10'h0;
	  		rd_en2	<=	1'b0;	
	  	end
	  	else if (new) begin
	  		Address2 <= StartAddress2;
	  		rd_en2	<=	1'b0; // active low read enable
	  	end 
	  	else if (!ETX1 && !Match1) begin
	  		Address2 <= Address2 + 1'b1;
	  		rd_en2	<=	1'b0;
	  	end
	  	else begin
	  		rd_en2	<=	1'b1; // Do Not read when not needed
	  	end
	end 

endmodule
