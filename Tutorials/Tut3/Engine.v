//`timescale 1ns/10ps
module Engine (clock, reset, 
		 new, //=1 ==> start search
		 search, //5 char word
		 Found, //=1 if found
		 NotFound, // =1 if not found
		 data, // data OP from SRAM
		 ETX, //End of file OP to controller
		 match, // match found to controller
		 sp, // space found
		 CharCount // current character order in word
		);


	input 				clock;
	input				reset; 
	input 				new; //=1 ==> start search
	input 	[5*8-1:0] search; //5 char word
	input 	[7:0] 		data;  // data OP from SRAM
	input 	[2:0] 		CharCount; // current character order in word
	
	output 				Found; //=1 if found
	output 				NotFound; // =1 if not found
	output 				ETX; //End of file OP to controller
	output 				match; // match found to controller
	output 				sp; // space found



// Flip-flops


	wire 	ETX; 
	wire	sp; 
	reg 	match; 
	reg 	Found; 
	reg 	NotFound; 
	reg [(5*8)-1:0] SearchWord; 
	reg [(5*8)-1:0] word; 
	
	always@(posedge clock) begin
		if (reset) begin
			SearchWord <=	39'hface;
		end  	
		else if (new) begin 
			SearchWord <= search;
		end
	end
	// Note the following code.  It is a direct and ugly description
	// of a demux.  But being direct, it is likely to yield smaller
	// logic than a more elegant version
	
	always@(posedge clock) begin
		if (reset) begin 
			word <=	39'hbace;
		end
		else begin
	  		case(CharCount)
	   		3'h0: begin
		   		word[39:32] 	<= data; 
		   		word[31:0] 		<= 32'h0;	// zero pad word to match format in SearchWord
	  	 	end  
	   		3'h1: word[31:24] 	<= data;
	   		3'h2: word[23:16] 	<= data;
	   		3'h3: word[15:8] 	<= data;
	   		3'h4: word[7:0]		<= data;
	  		endcase
	  	end
	end
	 
	 // blocking assignment
	 
	always@(sp or ETX or SearchWord or word) begin
	   	if((sp | ETX) & (SearchWord == word)) begin
	    	match = 1;
	    end
	    else begin
	    	match = 0;
	    end
	end
	  
	assign	sp = (data == 8'h20)?1'b1:1'b0; // space
	assign	ETX = (data == 8'h03)?1'b1:1'b0; // end of text
	
	
	always@(posedge clock) begin
		if (reset) begin
			Found	<=	1'b0;
			NotFound <=	1'b0;
		end
		else if (new)begin
	   		Found <= 1'b0;
	       	NotFound <= 1'b0;
	    end
	  	else if (match) 
	  		Found <= 1'b1;
	  	else if (ETX & !Found) 
	  		NotFound <= 1'b1;  
	end
endmodule 

