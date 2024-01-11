module top_with_mem(clock, reset, new, search, StartAddress1, StartAddress2, Found, NotFound);

	input 				clock, reset;
	input 				new;
	input 	[(5*8)-1:0] search;
	input 	[9:0] 		StartAddress1, StartAddress2;
	
	output				Found, NotFound;
	
	wire 	[7:0] 		data1, data2;
	wire 	[9:0] 		address1, address2;
	wire				rd_en1, rd_en2;
	
	top top_inst (	.clock(clock), .new(new), .reset(reset), .search(search), 
				.data1(data1), .address1(address1), .StartAddress1(StartAddress1),  
				.data2(data2), .address2(address2), .StartAddress2(StartAddress2),  
				.rd_en1(rd_en1), .rd_en2(rd_en2), 
				.Found(Found), .NotFound(NotFound) 
			);
	
	MemGen_8_10 mem_inst (	.clock_wr(clock), .clock_rd1(clock), .clock_rd2(clock), 
	
							.wr_en(1'b1), .wr_addr(10'h0), .wr_data(8'h0), 
							
							.rd_en1(rd_en1), .rd_addr1(address1), .rd_data1(data1), 
							.rd_en2(rd_en2), .rd_addr2(address2), .rd_data2(data2) 
						
						);
	
endmodule
