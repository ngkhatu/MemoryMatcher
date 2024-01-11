//Scale clock for simulation with unit of 1ns and accuracy of 1ps
`timescale 1ns / 1 ps
include "top.v" ;
include "sram.v" ;
include "match.v" ;

module test_match ;

// Test parameters
parameter TestCycles = 500 ; //Up to 500
parameter ClockPeriod = 2.56 ;
integer I ;
integer SimResults ;
reg [11:0] SourceVectors [TestCycles-1:0] ;
//reg [31:0] ResultVectors [TestCycles-1:0] ;

reg clock ;
reg [7:0]DataIn ;
reg Go_flag ;
wire [31:0]Found ;

initial
begin

//Read in Test Vectors and load data to SRAM
$readmemh("match_memory_hex.txt", top_DUT.MatchMemory.Register);
$readmemh("input464proj.txt", SourceVectors) ;
//$writememh("test_output.txt", ResultVectors) ;

//Open file to create output data
SimResults = $fopen("Found_results.txt") ;
//initialize the clock
clock = 0 ;

//Output to file when 'Found' changes
$fmonitor(SimResults, "%h", Found) ;
//$fmonitor(SimResults, "%c%c%c%c", Found[31:24], Found[23:16], Found[15:8], Found[7:0]) ;
#(1.1*ClockPeriod)

//begin simulation
for (I = 0 ; I < TestCycles ; I = I+1)
begin

//- Set DataIn with the Test Vector
DataIn = SourceVectors[I][11:4] ; //

//- If 0x1 for current test vector set Go_flag high else Go_flag is low
if(SourceVectors[I][3:0] == 4'h1) Go_flag = 1 ;
else Go_flag = 0 ;

//Hold Go_flag up only for one ClockPeriod
#ClockPeriod Go_flag = 0 ;

//Max clock cycles from DataIn to oneiteration of SRAM minus one
#(ClockPeriod*33) I = I ;

//#ClockPeriod if (Found != ResultVectors[I]) $fdisplay (SimResults, "ERROR in loop %d \n", I) ;

end


#(10*ClockPeriod) $finish ;
end

// Memory can be read after .31ns; --> 3.23 GHz
// with 50% duty cycle clock alternates every .31/2 = .155ns
always  #(ClockPeriod/2) clock = ~clock;
top top_DUT(.clock(clock), .DataIn(DataIn), .Go_flag(Go_flag), .Found(Found)) ;
endmodule
