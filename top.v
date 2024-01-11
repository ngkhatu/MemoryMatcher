`timescale 1ns / 1 ps
module top(clock, DataIn, Go_flag, Found) ;
 
 input clock ;
 input [7:0] DataIn ;
 input Go_flag ;
 output [31:0] Found ; 
 wire [3:0] Address ;
 wire [31:0] Data ;

Match Match_DUT(.clock(clock), .DataIn(DataIn), .Go_flag(Go_flag), .Data(Data), .Address(Address), .Found(Found));
SRAM MatchMemory(.ReadAddress(Address), .ReadBus(Data)) ;
endmodule
