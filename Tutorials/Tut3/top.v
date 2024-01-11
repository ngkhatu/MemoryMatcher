module top (clock,reset,
  	    new,
 	    search,
	    data1,
	    rd_en1, 
	    address1,
	    StartAddress1,
	    data2,
	    rd_en2, 
	    address2,
	    StartAddress2,
	    Found,
	    NotFound
	   );
	   
	   
	input 	clock;
	input	reset;
	input 	new;
	
	input 	[(5*8)-1:0] search;
	input 	[9:0] 		StartAddress1;
	input	[9:0] 		StartAddress2;
	
	input 	[7:0] 	data1;
	input 	[7:0]	data2;
	
	output 	[9:0] 	address1;
	output 	[9:0] 	address2;
	
	output			rd_en1, rd_en2;
	
	output Found;
	output NotFound ;       
	
		   
	wire			Found1, Found2;
	wire			NotFound1, NotFound2;
	wire 			ETX1, sp1, match1;
	wire 			ETX2, sp2, match2;
	wire 	[2:0]	CharCount1;
	wire 	[2:0]	CharCount2;

	assign	Found = Found1 | Found2;
	assign	NotFound = NotFound1 & NotFound2;

	Engine Data1 (.clock(clock), .reset(reset), .new(new), .search(search), .Found(Found1), .NotFound(NotFound1),
		     .data(data1), .ETX(ETX1),  .match(match1), .sp(sp1), .CharCount(CharCount1));
	
	Engine Data2 (.clock(clock), .reset(reset), .new(new), .search(search), .Found(Found2), .NotFound(NotFound2),
		     .data(data2), .ETX(ETX2),  .match(match2), .sp(sp2), .CharCount(CharCount2));
	
	Controller Ctrl (	.clock(clock), .new(new), .reset(reset), 
					
					.ETX1(ETX1), .sp1(sp1), .Match1(match1), 
					.StartAddress1(StartAddress1), .rd_en1(rd_en1), 
					.CharCount1(CharCount1),.Address1(address1), 
					
					.ETX2(ETX2), .sp2(sp2), .Match2(match2), 
					.StartAddress2(StartAddress2), .rd_en2(rd_en2), 
					.CharCount2(CharCount2),.Address2(address2)
					
					);

endmodule

