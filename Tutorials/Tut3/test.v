//`timescale 1ns/10ps
module test_search;
	parameter CLKPERIOD = 10;
	reg 				clock, reset;
	reg 				new;
	reg 	[(5*8)-1:0] search;
	
	reg 	[9:0] 		StartAddress1, StartAddress2;
	wire 				Found, NotFound;
	
//	wire 	[7:0] 		data1, data2;
//	wire 	[9:0] 		address1, address2;
//	wire				rd_en1, rd_en2;
	
	initial	begin
	  	//$dumpfile("Tut2.vcd"); // save waveforms in this file
	  	//$dumpvars;  // saves all waveforms
	    $readmemh("memdata.txt", top_mem.mem_inst.mem); 	
			
	    clock = 0; new = 0; 
	    reset = 0;
	   	#(CLKPERIOD+2)
	    reset = 1; 
	    search = 40'h6561737900; // The word "easy" padded with zeros
	   	StartAddress1 =	0;		 // start address for string 1	
	   	StartAddress2 =	10'd100; // start address for string 2  	    
		#CLKPERIOD reset =1'b0; 		 // start the design at a known state
	    #CLKPERIOD new =1'b1; 			 // begin search by asserting new		
	    #CLKPERIOD new =1'b0;  		 // assert new for one cycle

	    #(50*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;
	top_with_mem	top_mem(	
			.clock(clock), .reset(reset), .new(new), 
			.search(search), 
			.StartAddress1(StartAddress1), .StartAddress2(StartAddress2), 
			.Found(Found), .NotFound(NotFound)
		);
	
	
endmodule

