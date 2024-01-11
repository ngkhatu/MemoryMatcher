include "sram.v" ;
`timescale 1ns / 1 ps
module test_sram ;
 
reg [3:0] Address ;
wire [31:0] Data ;

initial
begin
$readmemh("match_memory_hex.txt", MatchMemory.Register);

Address = 4'd0 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd1 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd2 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd3 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd4 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd5 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd6 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd7 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd8 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd9 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd10 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd11 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd12 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd13 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd14 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; Address = 4'd15 ;
#0.31 $display("Address:%b , Data:%h", Address, Data) ; $finish ;
end

SRAM MatchMemory(Address, Data) ;
endmodule


