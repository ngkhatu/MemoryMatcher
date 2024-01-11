`timescale 1ns / 1 ps
module SRAM (ReadAddress, ReadBus);
input  [3:0] ReadAddress; // Change as you change size of SRAM
output [31:0] ReadBus;

reg [31:0]   Register [0:15];   // 16 words, each 32 bit
reg [31:0]   ReadBus;

// Note the 0.3 ns delay - this is the OUTPUT DELAY FOR THE MEMORY FOR SYNTHESIS
always@(*) 
  begin 
    #0.3 ReadBus  =  Register[ReadAddress];
  end
endmodule
