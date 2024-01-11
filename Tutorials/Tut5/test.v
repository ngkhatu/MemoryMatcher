module test_fixture;

// set parameters for signal width and clock period
parameter sig_width = 52;
parameter exp_width = 11;
parameter ieee_compliance = 0;

parameter CLKPERIOD = 50;

reg clock=0;
reg [sig_width+exp_width : 0] inst_a;
reg [sig_width+exp_width : 0] inst_b;
reg [2 : 0] inst_rnd;
reg inst_op;
wire [sig_width+exp_width : 0] z_inst;
wire [7 : 0] status_inst;

integer i, file, r;

//real type could store 64bits float point number
real memory [0:7], result;

	initial
	begin

	file=$fopen("data.dat","r");
	i=0;
	while(!$feof(file))
	begin
		r=$fscanf(file, "%f", memory[i]);
		i=i+1;
	end
	$fclose(file);

		$display("Memory[%d]=%f", 0, memory[0]);
		$display("Memory[%d]=%f", 1, memory[1]);
	#(CLKPERIOD+2)
//System function $realtobits translate real type into 64 bits binary according to IEEE 754 Standard
		inst_a=$realtobits(memory[0]);
		inst_b=$realtobits(memory[1]);
		inst_op=1'b0;
		inst_rnd=3'b000;

	#(CLKPERIOD/2)
//System function $bitstoreal translate 64 bits binary into float point number according to IEEE 754 Standard
		result=$bitstoreal(z_inst);
		$monitor($time, "result = %f", result);

	#(CLKPERIOD/2)
		inst_op=1'b1;

	#(CLKPERIOD/2)
		result=$bitstoreal(z_inst);
		//$display("result=%f", result);

	#(CLKPERIOD*3)	$finish;

	end
	
always #(CLKPERIOD/2) clock = ~clock;

arith U1( .clock(clock), .inst_a(inst_a), .inst_b(inst_b), .inst_rnd(inst_rnd), .inst_op(inst_op), .z_inst(z_inst), .status_inst(status_inst) );
endmodule  /*test_fixture*/

