`timescale 1ns / 1 ps
module Match (clock, DataIn, Go_flag, Data, Address, Found) ;

input clock ;
input [7:0] DataIn ;
input Go_flag ;
output reg [3:0] Address ;
input [31:0] Data ;
output reg [31:0] Found ;

wire [31:0] Word1, Word2, Word3, Word4 ;
wire [31:0] ex1, ex2, ex3 ;
reg [31:0] theMatch ; //Used in combinational block
reg [7:0] Data1, Data2, Data3 ;

//transient registers
reg [31:0] Data_buffer ;
reg [7:0] DataIn_buffer ;
reg [1:0] state ;
reg [3:0] isMatch ;
reg [2:0] isMatchEx ;
reg C_out ;

parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3 ;

// Define the Data line / wires
assign Word1 = {{24'd0},{DataIn_buffer}} ;
assign Word2 = {{16'd0},{Data1},{DataIn_buffer}} ;
assign Word3 = {{8'd0},{Data2},{Data1},{DataIn_buffer}} ;
assign Word4 = {{Data3},{Data2},{Data1},{DataIn_buffer}} ;
assign ex1 = {{24'd0},{Data1}} ;
assign ex2 = {{16'd0},{Data2},{Data1}} ;
assign ex3 = {{8'd0},{Data3},{Data2},{Data1}} ;




/*
Combinational Block to define the MatchOutput Word4 if (Word4 is a match)
Output ex3 if (word4 is not a match and ex3 is a match)
Output ex2 if (word3 is not a match and ex2 is a match)
Output ex1 if (word2 is not a match and ex1 is a match)
Output No match if no match is found - Equivalent of leaving Found[31:0] low
*/
always@(isMatch or isMatchEx or ex1 or ex2 or ex3 or Word4)
	if(isMatch[3]) theMatch = Word4 ;
	else if (~isMatch[3] && isMatchEx[2]) theMatch = ex3 ;
	else if (~isMatch[2] && isMatchEx[1]) theMatch = ex2 ;
	else if (~isMatch[1] && isMatchEx[0]) theMatch = ex1 ;
	else theMatch = 0 ;



// Global Controller
always@(posedge clock)
case(state)

//Wait for Go in State 0
S0: begin
	//Reset Found, isMatch, Address, C_out
	Found = 0 ;
	isMatch = 4'b0000 ;
	Address = 0 ;
	C_out = 0 ;
	
	//Once Go_flag goes high set read DataIn and adjust data lines
	//State 3 in next clock cycle
	if(Go_flag) begin
		state = S3 ;
		DataIn_buffer <= DataIn ;
		Data1 <= DataIn_buffer ;
		Data2 <= Data1 ;
		Data3 <= Data2 ;
	end
	
	//Wait for Go_flag
	else state = S0 ;
end

//Compare latest word from SRAM to newest Word1, 2, 3, and 4
S1: begin
	if(Data_buffer == Word1) isMatch[0] = 1 ;
	if(Data_buffer == Word2) isMatch[1] = 1 ;
	if(Data_buffer == Word3) isMatch[2] = 1 ;
	
	//If last four DataIns match go to State 2
	if(Data_buffer == Word4) begin isMatch[3] = 1 ; state = S2 ;  end
	//If last four DataIns do not match, then iterate between S3/S1 until C_out is high
	else begin		
		if(~C_out) state = S3 ;
		else if(C_out)begin
			// If there is(in S1) a Match once C_out is high then go to S2 in next clock cycle
			if(|theMatch) state = S2 ;
			// If there is (in S1) no Match once C_out is high then go to S0 to get another DataIn, reset vars,
			// and restart the SRAM iteration process
			else begin
				//isMatch is saved to isMatchEx for next iteration
				//isMatchEx will be used in logic block to determine if there is a valid Match
				isMatchEx = isMatch[2:0] ;
				state = S0 ;
			end
		end
	end
end

// State 2 is the output state. Output for one cycle and then go to S0 in the following cycle.
S2: begin
	Found = theMatch ;
	state = S0 ;
	isMatchEx = isMatch[2:0] ;
end

// S3 is the read state.
S3: begin
	// Read data from SRAM into buffer
	Data_buffer = Data ;
	// increment the address. If overflow C_out will be one.
	{{C_out},{Address}} = Address + 1 ;
	state = S1 ;
end

// if state is undefined, state will be S0.
default: state = S0 ;
endcase

endmodule
