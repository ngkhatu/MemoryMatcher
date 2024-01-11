#!/usr/bin/perl
#
# CreateModel.pl
# version 0.1
use strict;
use warnings;
use POSIX;

sub log2 {
	my $n = shift;
	return (log($n)/log(2));
}

my $library_name;
my $max_transition;
my $data_width;
my $addr_width;
my $cellname; 
my $area;
my $en_cap;
my $addr_cap;
my $data_cap;
my $clk_cap;
my $decode_power;
my $rdwrprt;
my $rdprt;
my $wrprt;
my $cacti_width;
my $numsubbanks;
my $scalearea_flag;
my $scalefactor; 
my $lineread;
my $areaflag; 
my $powerflag; 
my $timeflag; 
my @addr_rise_base;
my @addr_fall_base;
my $mem_depth;
my $mem_size;
my @addr_rise;
my @addr_fall;
my @output_delay;
my @driver_delay;
my @op_rise_tr;
my @op_fall_tr;
my $templineread;
my $clk_per_ns;
my $access_time;
my $width;
my $decode_time;
my $i;
my $addr_msb;
my $data_msb;
my $cacti_path;
my $op_data_driver_dyn,;
my $op_data_driver_leak;
my $wl_data_energy_dyn; 
my $wl_data_power_leak; 
my $rd_data_bl_dyn; 
my $wr_data_bl_dyn; 
my $bl_data_power_leak; 
my $sa_data_dyn, 
my $sa_data_leak;
my $decode_data_dyn;
my $decode_data_leak;
my $compare_dyn,;
my $compare_leak;
my $valid_dyn,;
my $valid_leak;
my $op_tag_driver_dyn,;
my $op_tag_driver_leak;
my $wl_tag_energy_dyn; 
my $wl_tag_power_leak; 
my $rd_tag_bl_dyn; 
my $wr_tag_bl_dyn; 
my $bl_tag_power_leak; 
my $sa_tag_dyn, 
my $sa_tag_leak;
my $decode_tag_dyn;
my $decode_tag_leak;

my $rd_data_power_dyn;
my $wr_data_power_dyn;
my $rd_data_power_leak;
my $wr_data_power_leak;
my $rd_tag_power_dyn;
my $wr_tag_power_dyn;
my $rd_tag_power_leak;
my $wr_tag_power_leak;
my $mem_size_user;
my $data_ram_area;
my $tag_ram_area;
my $rd_power_dyn;
my $wr_power_dyn;

my $tot_rd_energy_dyn;
my $tot_wr_energy_dyn;

my $helpplease;
my $WORK_DIRECTORY;
my $leakage;
my $debug_flag;

$max_transition	=	2.8;
$mem_depth		=	4096;
$data_width	=	32;
$cellname	=	"Memory"; 
$area	=	0;
$en_cap	=	0.0125; #Borrowed from NAND2x input capacitance
$addr_cap	=	0.0139855;  #Borrowed from BUF4x input capacitance
$data_cap	=	0.00882947; #Borrowed from DFF input capacitance
$clk_cap	=	0.0373938;	#Borrowed from CLKBUF3 input capacitance
@addr_rise_base = (0.0510, 0.0515, 0.0522, 0.0550, 0.0604, 0.0700, 0.0893);
@addr_fall_base = (0.0191, 0.0203, 0.0216, 0.0275, 0.0391, 0.0592, 0.0997);
@driver_delay = (0.094, 0.108, 0.132, 0.220, 0.352, 0.572, 0.924);
@op_fall_tr = (0.046281, 0.050589, 0.0804, 0.196, 0.378, 0.574, 0.952);
$clk_per_ns = 10;
$cacti_path = "./Cacti/cacti";
#Run CACTI FOR THE PRESENT INPUT CONFIG
$rdwrprt = 0;
$rdprt	 = 2;
$wrprt	 = 1;
$numsubbanks = 1;
$scalearea_flag = 0;
$WORK_DIRECTORY = `pwd`;
$helpplease = 0;
$debug_flag = 0;

while (@ARGV) {
	#this means war!! 
	$_ = shift;
	if (/^-help$/) {
		$helpplease = 1;
	}
	elsif ( /^-depth$/) {
		$mem_depth = shift;	
	} 
	elsif ( /^-width$/) {
		$data_width = shift;	
	} 
	elsif ( /^-cacti_path$/) {
		$cacti_path = shift;	
	} 
	elsif ( /^-debug$/) {
		$debug_flag = shift;	
	} 
	else {
		print "[ERROR] Incorrect arguments: Please type \">CreateModel.pl -help \" to see the help for this file\n";
		exit;
	}

}

if ($helpplease == 1) {
	print "[NOTE]: Please make sure you have a compiled version of Cacti before running this flow\n\n";
	print "[NOTE]: Please ensure that you have done an \"add synopsys\"\n";
	print "[NOTE]: To run this analysis the inputs needed are:\n";
	print "The help option (-help) To bring up this screen\n";
	print "The depth of the memory in number of words (-depth) [DEFAULT: 4096]\n";
	print "The width in bits of each entry in memory (-width) [DEFAULT: 32]\n";
	print "The full path to the Cacti Exectuable (-cacti_path) [DEFAULT: ./Cacti/cacti]\n";
	print "For example run as : > ./CreateModel.pl -depth 8192 -width 40 -cacti_path ./Cacti/cacti\n"; 
    print "ALL THE BEST !!!\n\n";
	
	exit;
}

open(SCRIPT,">infofile.memgen") || die "ERROR: Could not open infofile.memgen for writing";
print SCRIPT <<EOM;

 ######################## RUN INFORMATION #############################;

	The the depth of the memory in number of words (-depth)= $mem_depth
	The width in bits of each entry in memory (-width) = $data_width
	The full path to the Cacti Exectuable (-cacti_path) = $cacti_path
	
 	PRESENT WORKING DIRECTORY IS: $WORK_DIRECTORY;
 ######################## RUN INFORMATION #############################;

EOM
close(SCRIPT);


$addr_width		=	log2($mem_depth);
$addr_width		=	ceil($addr_width);
if(($data_width/8) < 8) {
	$cacti_width =	8;
	$scalefactor = 	($data_width / ($cacti_width*8));	
}
elsif(($data_width %8)!=0) {
	$cacti_width = int(($data_width)/8);
	$cacti_width = $cacti_width + 1;
	$scalefactor = 	($data_width / ($cacti_width*8));	
}
else {
	$cacti_width =	$data_width/8;
	$scalefactor = 1;
}
$mem_size_user = ($data_width * $mem_depth)/8;

$mem_size = $cacti_width * $mem_depth;
$areaflag  = 0;
$timeflag = 0;
$powerflag = 0;
#print "${cacti_path} $mem_size $cacti_width 1 0.18um $rdwrprt $rdprt $wrprt $numsubbanks > Output.Cacti\n";	
print "			Memory Parameters: \n";
print "				Memory Depth (number of words): ${mem_depth} \n";
print "				Word Size in bits: ${data_width} \n";
print "				Implied Number of Address Bits: ${addr_width} \n";
print "				Implied Memory Size in bytes: ${mem_size_user}  \n\n";
print "					Running CACTI to determine power and timing values\n";
print "##########################################################################\n\n";
print "   \n\nRUNNING: ${cacti_path} $mem_size $cacti_width 1 0.18um $rdwrprt $rdprt $wrprt $numsubbanks > Output.Cacti \n";
system("${cacti_path} $mem_size $cacti_width 1 0.18um $rdwrprt $rdprt $wrprt $numsubbanks > Output.Cacti");
$areaflag = 0;
open(READFILE,"< Output.Cacti") || die "ERROR: Could not open Output.Cacti for reading";
	while ($lineread = <READFILE>) {
		#Determine the different area components to make final area
		if ($areaflag == 1) {
			if($lineread=~/^Data\s*array(.+):\s*([0-9|\.]+)/) {
				#print "Area = $2  ; ScaleFactor  = $scalefactor \n";
				$area = $area + ($2*$scalefactor);
				#print "$area  ";
			}
			elsif($lineread=~/^Data\s*column\s*post(.+):\s*([0-9|\.]+)/) {
				$area = $area + ($2*$scalefactor);
				#print "$area  ";
			}
			elsif($lineread=~/^Data\s*(.+):\s*([0-9|\.]+)/) {
				$area = $area + $2;	
				#print "$area  ";
			}
		}
		if($lineread =~ /^\s*Area\s*Components/) {
			$areaflag = 1;				
		}
	}	
$area = $area * 1000000;	
$areaflag = 0;
close(READFILE);
print "Total Area = $area and Scaling Factor: $scalefactor\n";
$library_name	=	"MemGen_${data_width}_${addr_width}";

$timeflag = 0;
$decode_power = 0;
$decode_time =0;
$access_time = 0;
open(READFILE,"< Output.Cacti") || die "ERROR: Could not open Output.Cacti for reading";
	while ($lineread = <READFILE>) {
		#Determine the different area components to make final area
		if ($timeflag == 1) {
			if($lineread=~/decode_data(.+):\s*([0-9|\.]+)/) {
				#print $lineread;
				$decode_time = $2;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*energy(.+):\s*([0-9|\.]+)/) {
					#print $templineread;
					$decode_data_dyn =	$2;
				}
			}
			elsif($lineread =~ /\s*data\s*side\s*\(with\s*Output\s*driver\)(.+):\s*([0-9|\.]+)/) {
				#print $lineread;
				$access_time = $2;	
			}
		}
		if($lineread =~ /^\s*Time\s*Components/){
			#print $lineread;
			$timeflag = 1;				
		}
	}	
close(READFILE);
$timeflag = 0;
$decode_power = (($decode_data_dyn * 1000));
$access_time = $access_time - $decode_time;
#print "Total Access Time = $access_time\n";
#print "Total Decode Time = $decode_time\n";
#print "Total Decode Power = $decode_power\n";
$powerflag = 0;
open(READFILE,"< Output.Cacti") || die "ERROR: Could not open Output.Cacti for reading";
	while ($lineread = <READFILE>) {
		#Determine the different area components to make final area
		if ($powerflag == 1) {
			if($lineread=~/wordline\s*and\s*bitline\s*data/) {
				#print $lineread;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*wordline\s*(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$wl_data_energy_dyn =	$2;
				}
				$templineread = <READFILE>;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*read\s*data(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$rd_data_bl_dyn =	$2;
				}	
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*write\s*data(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$wr_data_bl_dyn =	$2;
				}	
			}
			elsif($lineread=~/sense_amp_data/) {
				#print $lineread;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*energy(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$sa_data_dyn =	$2;
				}	
			}
			elsif($lineread=~/data\s*output\s*driver/) {
				#print $lineread;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*read\s*energy(.+):\s*([0-9|\.|e|E|-]+)$/) {
					#print $templineread;
					$op_data_driver_dyn =	$2;
				}	
			}
		}
		if($lineread =~ /^\s*Time\s*Components/){
			#print $lineread;
			$powerflag = 1;				
		}
	}	
close(READFILE);
$powerflag = 0;
$timeflag = 0;
open(READFILE,"< Output.Cacti") || die "ERROR: Could not open Output.Cacti for reading";
	while ($lineread = <READFILE>) {
		#Determine the different area components to make final area
		if ($timeflag == 1) {
			if($lineread=~/decode_tag(.+):\s*([0-9|\.]+)/) {
				#print $lineread;
				$decode_time = $2;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*energy(.+):\s*([0-9|\.]+)/) {
					#print $templineread;
					$decode_tag_dyn =	$2;
				}
			}
			elsif($lineread=~/wordline\s*and\s*bitline\s*tag/) {
				#print $lineread;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*wordline\s*(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$wl_tag_energy_dyn =	$2;
				}
				$templineread = <READFILE>;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*read\s*data(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$rd_tag_bl_dyn =	$2;
				}	
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*write\s*data(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$wr_tag_bl_dyn =	$2;
				}	
			}
			elsif($lineread=~/sense_amp_tag/) {
				#print $lineread;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*read\s*energy(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$sa_tag_dyn =	$2;
				}	
			}
			elsif($lineread=~/\s*compare/) {
				#print $lineread;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*read\s*energy(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$compare_dyn =	$2;
				}	
			}
			elsif($lineread=~/\s*valid\s*signal/) {
				#print $lineread;
				$templineread = <READFILE>;
				if($templineread=~/dyn\.\s*read\s*energy(.+):\s*([0-9|\.|e|E|-]+)/) {
					#print $templineread;
					$valid_dyn =	$2;
				}
			}	
		}
		if($lineread =~ /^\s*Time\s*Components/){
			#print $lineread;
			$timeflag = 1;				
		}
	}	
close(READFILE);

$areaflag = 0;
open(READFILE,"< Output.Cacti") || die "ERROR: Could not open Output.Cacti for reading";
	while ($lineread = <READFILE>) {
		#Determine the different area components to make final area
		if ($areaflag == 1) {
			if($lineread=~/^Data\s*array(.+):\s*([0-9|\.]+)/) {
				$data_ram_area = $2;
			}
			if($lineread=~/^Tag\s*array(.+):\s*([0-9|\.]+)/) {
				$tag_ram_area = $2;
			}
		}
		if($lineread =~ /^\s*Area\s*Components/) {
			#print $lineread;
			$areaflag = 1;				
		}
	}	
close(READFILE);

open(READFILE,"< Output.Cacti") || die "ERROR: Could not open Output.Cacti for reading";
	while ($lineread = <READFILE>) {
		if($lineread=~/Total\s*dynamic\s*Read\s*Energy\s*all\s*Banks(.+):\s*([0-9|\.|e|E|-]+)$/) {
			$tot_rd_energy_dyn = $2;
		}
		if($lineread=~/Total\s*dynamic\s*Write\s*Energy\s*all\s*Banks(.+):\s*([0-9|\.|e|E|-]+)$/) {
			$tot_wr_energy_dyn = $2;
		}
	}
close(READFILE);

if ($debug_flag == 1)  {
	#print "TAG RAM AREA = $tag_ram_area  and DATA RAM AREA = $data_ram_area\n";
	#print "Energy Before Adjustment = $tot_rd_energy_dyn  $tot_wr_energy_dyn\n";
}
$rd_data_power_dyn 	=	$decode_data_dyn + $wl_data_energy_dyn + ($rd_data_bl_dyn*$scalefactor) + ($op_data_driver_dyn*$scalefactor) + ($sa_data_dyn*$scalefactor);

$wr_data_power_dyn 	=	$decode_data_dyn + $wl_data_energy_dyn + ($wr_data_bl_dyn*$scalefactor);

$rd_tag_power_dyn 	=	$decode_tag_dyn + $wl_tag_energy_dyn + $rd_tag_bl_dyn + $sa_tag_dyn + $compare_dyn + $valid_dyn;

$wr_tag_power_dyn 	=	$decode_tag_dyn + $wl_tag_energy_dyn + $wr_tag_bl_dyn + $compare_dyn + $valid_dyn;

if ($debug_flag == 1)  {
	#print "Energy From Data Components = $rd_data_power_dyn  $wr_data_power_dyn\n";
	#print "Energy From Tag Components = $rd_tag_power_dyn  $wr_tag_power_dyn\n";
}
$rd_data_power_dyn	=	$rd_data_power_dyn + $scalefactor*(($tot_rd_energy_dyn - $rd_data_power_dyn - $rd_tag_power_dyn)* ($data_ram_area)/($data_ram_area + $tag_ram_area));
$wr_data_power_dyn	=	$wr_data_power_dyn + $scalefactor*(($tot_wr_energy_dyn - $wr_data_power_dyn - $wr_tag_power_dyn)* ($data_ram_area)/($data_ram_area + $tag_ram_area));

if ($debug_flag == 1)  {
	#print "Energy After Adjustment = $rd_data_power_dyn  $wr_data_power_dyn\n";
}
#$rd_power_dyn = ($rd_data_power_dyn*1000)/$clk_per_ns;
#$wr_power_dyn = ($wr_data_power_dyn*1000)/$clk_per_ns;
$rd_power_dyn = ($rd_data_power_dyn*1000);
$wr_power_dyn = ($wr_data_power_dyn*1000);


open(READFILE,"< Output.Cacti") || die "ERROR: Could not open Output.Cacti for reading";
	while ($lineread = <READFILE>) {
		if($lineread=~/Total\s*leakage\s*(.+)Power\s*all(.+):\s*([0-9|\.|e|E|-]+)$/) {
			$leakage = $3 * ($data_ram_area)/($data_ram_area + $tag_ram_area);
		}

	}
close(READFILE);

for ($i=0; $i<7; $i++) {
	$addr_rise[$i] = $addr_rise_base[$i]*$addr_width;
	$addr_fall[$i] = $addr_fall_base[$i]*$addr_width;
}
for ($i=0; $i<7; $i++) {
	$output_delay[$i] = $access_time + $driver_delay[$i];
}
for ($i=0; $i<7; $i++) {
	$op_rise_tr[$i] = $op_fall_tr[$i]*3;
}

$addr_msb = $addr_width -1;
$data_msb = $data_width -1;
print "##########################################################################\n\n";
print "				CREATING LIB FILE FOR GIVEN MEMORY CONFIGURATION\n";
	open(SCRIPT,">MemGen_${data_width}_${addr_width}.lib") || die "ERROR: Could not open MemGen_${data_width}_${addr_width}.lib";
	print SCRIPT <<EOM;

library(MemGen_${data_width}_${addr_width}) {
	delay_model		: table_lookup;
	revision		: 2008_Spr;
	date			: "March 03, 2008";
	comment			: "This is a memory model generated for Distribution in ECE520 @ NCSU. Please use with care";
	time_unit		: "1ns";
	voltage_unit		: "1V";
	current_unit		: "1mA";
  	leakage_power_unit      : "1mW";
	nom_process		: 1;
	nom_temperature		: 25.000;
	nom_voltage		: 1.800;
	capacitive_load_unit	 (1,pf);

	pulling_resistance_unit	        : "1kohm";

	/* additional header data */
	default_cell_leakage_power  : 0;
	default_fanout_load			: 1;
	default_inout_pin_cap		: 0.005;
	default_input_pin_cap		: 0.005;
	default_output_pin_cap		: 0.0;
	default_max_transition		: $max_transition; 

    /* default attributes */
    default_leakage_power_density : 0.0;
    slew_derate_from_library      : 1;
    slew_lower_threshold_pct_fall : 10.000;
    slew_upper_threshold_pct_fall : 90.000;
    slew_lower_threshold_pct_rise : 10.000;
    slew_upper_threshold_pct_rise : 90.000;
    input_threshold_pct_fall      : 50.000;
    input_threshold_pct_rise      : 50.000;
    output_threshold_pct_fall     : 50.000;
    output_threshold_pct_rise     : 50.000;

 	/* k-factors */
 	k_process_cell_fall             : 1;
 	k_process_cell_leakage_power    : 0;
 	k_process_cell_rise             : 1;
 	k_process_fall_transition       : 1;
 	k_process_hold_fall             : 1;
 	k_process_hold_rise             : 1;
 	k_process_internal_power        : 0;
 	k_process_min_pulse_width_high  : 1;
 	k_process_min_pulse_width_low   : 1;
 	k_process_pin_cap               : 0;
 	k_process_recovery_fall         : 1;
 	k_process_recovery_rise         : 1;
 	k_process_rise_transition       : 1;
 	k_process_setup_fall            : 1;
 	k_process_setup_rise            : 1;
 	k_process_wire_cap              : 0;
 	k_process_wire_res              : 0;
	k_temp_cell_fall		: 0.0;
	k_temp_cell_rise		: 0.0;
	k_temp_hold_fall                : 0.0;
	k_temp_hold_rise                : 0.0;
	k_temp_min_pulse_width_high     : 0.0;
	k_temp_min_pulse_width_low      : 0.0;
	k_temp_min_period               : 0.0;
	k_temp_rise_propagation         : 0.0;
	k_temp_fall_propagation         : 0.0;
	k_temp_rise_transition          : 0.0;
	k_temp_fall_transition          : 0.0;
	k_temp_recovery_fall            : 0.0;
	k_temp_recovery_rise            : 0.0;
	k_temp_setup_fall               : 0.0;
	k_temp_setup_rise               : 0.0;
	k_volt_cell_fall                : 0.0;
	k_volt_cell_rise                : 0.0;
	k_volt_hold_fall                : 0.0;
	k_volt_hold_rise                : 0.0;
	k_volt_min_pulse_width_high     : 0.0;
	k_volt_min_pulse_width_low      : 0.0;
	k_volt_min_period               : 0.0;
	k_volt_rise_propagation         : 0.0;
	k_volt_fall_propagation         : 0.0;
	k_volt_rise_transition	        : 0.0;
	k_volt_fall_transition	        : 0.0;
	k_volt_recovery_fall            : 0.0;
	k_volt_recovery_rise            : 0.0;
	k_volt_setup_fall               : 0.0;
	k_volt_setup_rise               : 0.0;


	operating_conditions(typical) {
		process		 : 1;
		temperature	 : 25.000;
		voltage		 : 1.800;
		tree_type	 : balanced_tree;
	}

	wire_load("sample") {
		resistance	 : 1.6e-05;
		capacitance	 : 0.0002;
		area		 : 1.7;
  		slope		 : 500;
		fanout_length	 (1,500);
	}
    lu_table_template(mem_delay_template) {
       variable_1 : total_output_net_capacitance;
           index_1 ("1000, 1001, 1002, 1003, 1004, 1005, 1006");
    }
	lu_table_template(mem_constraint_template_1) {
           variable_1 : related_pin_transition;
               index_1 ("1000, 1001, 1002, 1003, 1004, 1005, 1006");
        }
	lu_table_template(mem_constraint_template_2) {
           variable_1 : constrained_pin_transition;
               index_1 ("1000, 1001, 1002, 1003, 1004, 1005, 1006");
        }
	lu_table_template(mem_load_template) {
           variable_1 : total_output_net_capacitance;
               index_1 ("1000, 1001, 1002, 1003, 1004, 1005, 1006");
        }
    power_lut_template(mem_passive_energy_template) {
       variable_1 : input_transition_time;
           index_1 ("1000, 1001");
    }
	library_features(report_delay_calculation);
	type (DATA_BUS) {
		base_type : array ;
		data_type : bit ;
		bit_width : $data_width;
		bit_from  : $data_msb;
		bit_to	  : 0 ;
		downto 	  : true ;
	}

	type (ADDR_BUS) {
		base_type : array ;
		data_type : bit ;
		bit_width : $addr_width;
		bit_from  : $addr_msb;
		bit_to    : 0 ;
		downto    : true ;
	}

	
cell(MemGen_${data_width}_${addr_width}) {
	area		 : $area;
	dont_use	 : TRUE;
	dont_touch	 : TRUE;
	interface_timing : TRUE;
	memory() {
		type : ram;
		address_width : $addr_width;
		word_width : $data_width;
	}

	/* 	*******************************************************************
		MEMORY WRITE INTERFACE: CENB (wr_en), AB (wr_addr), DB (wr data), CLKB
	********************************************************************* */
	pin(wr_en) {
		direction : input;
		capacitance : $en_cap;
		timing() {
			related_pin : "clock_wr" ;
			timing_type : setup_rising ;
			rise_constraint(mem_constraint_template_1) {
			/* 	************************************************************
				CHANGES WITH RELATED PIN (CLK) TRANSITION
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values ( "0.256, 0.258, 0.262, 0.275, 0.302, 0.349, 0.446")
				
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				CHANGES WITH CONSTRAINED PIN TRANSITION
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values ( "0.506, 0.513, 0.520, 0.550, 0.609, 0.712, 0.920")
			}	
		}
		timing() {
			related_pin : "clock_wr" ;
			timing_type : hold_rising ;
			rise_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR CENB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR CENB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}	
		}	
	}

	bus (wr_addr)  {
		bus_type : ADDR_BUS;
  	    direction : input;
		capacitance : $addr_cap;
	    internal_power(){
	    	when : "!wr_en";
			power(mem_passive_energy_template) {
				index_1 ("0.0 1.0");
	    		values ("${decode_power}, ${decode_power}") 
	    		/* Decoding Power*/
			}	
		}
		timing() {
			related_pin : "clock_wr"
			timing_type : setup_rising ;
			rise_constraint(mem_constraint_template_2) {
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("${addr_rise[0]}, ${addr_rise[1]}, ${addr_rise[2]}, ${addr_rise[3]}, ${addr_rise[4]}, ${addr_rise[5]}, ${addr_rise[6]}")
				/* 	************************************************************
					CHANGES WITH CONSTRAINED PIN TRANSITION
				************************************************************** */
			}
			fall_constraint(mem_constraint_template_2) {
				/* 	************************************************************
					CHANGES WITH CONSTRAINED PIN TRANSITION
				************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("${addr_fall[0]}, ${addr_fall[1]}, ${addr_fall[2]}, ${addr_fall[3]}, ${addr_fall[4]}, ${addr_fall[5]}, ${addr_fall[6]}")
			}	
		}
		timing() {
			related_pin : "clock_wr"
			timing_type : hold_rising ;
			rise_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR AB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR AB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}	
		}	
	}

	bus (wr_data)	 {
		bus_type : DATA_BUS;
		direction : input;
		capacitance : $data_cap;
		memory_write() {
			address : wr_addr;
			clocked_on : "clock_wr";
		}
		timing() {
			related_pin : "clock_wr"
			timing_type : setup_rising ;
			rise_constraint(mem_constraint_template_1) {
			/* 	************************************************************
				CHANGES WITH RELATED PIN
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.036, 0.039, 0.041, 0.053, 0.077, 0.119, 0.203")
				
			}
			fall_constraint(mem_constraint_template_2) {
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				/* 	************************************************************
					CHANGES WITH CONSTRAINED PIN
				************************************************************** */
				values  ("0.077, 0.084, 0.094, 0.131, 0.206, 0.337, 0.599")
			}
		}
		timing() {
			related_pin : "clock_wr"
			timing_type : hold_rising ;
			rise_constraint(mem_constraint_template_1) {
			/* 	************************************************************
				CHANGES WITH RELATED PIN
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.232, 0.230, 0.227, 0.216, 0.194, 0.156, 0.078")				
			}
			fall_constraint(mem_constraint_template_2) {
				values  ("0.186, 0.184, 0.181, 0.170, 0.148, 0.109, 0.032")
			}	
		}	
	}

	pin(clock_wr) {
		direction : input;
		capacitance : $clk_cap;
		clock	 : true;
		min_pulse_width_low	 : 0.211;
		min_pulse_width_high	 : 0.058;
		min_period		 : 	$access_time; 
        max_transition           : $max_transition;
	    internal_power(){
	    	when : "wr_en";
			power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("0.0, 0.0")
			}
		}
	    internal_power(){
			when : "!wr_en ";
			rise_power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("${wr_power_dyn}, ${wr_power_dyn}")
	    		/* */
			}	
			fall_power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("0.0, 0.0")
			}	
		}	
	}

		
	pin(rd_en1) {
		direction : input;
		capacitance : $en_cap;
		timing() {
			related_pin : "clock_rd1" ;
			timing_type : setup_rising ;
			rise_constraint(mem_constraint_template_1) {
			/* 	************************************************************
				CHANGES WITH RELATED PIN (CLK) TRANSITION
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values ( "0.256, 0.258, 0.262, 0.275, 0.302, 0.349, 0.446")
				
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				CHANGES WITH CONSTRAINED PIN TRANSITION
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values ( "0.506, 0.513, 0.520, 0.550, 0.609, 0.712, 0.920")
			}	
		}
		timing() {
			related_pin : "clock_rd1" ;
			timing_type : hold_rising ;
			rise_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR CENB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR CENB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}	
		}	
	}

	bus (rd_addr1)  {
		bus_type : ADDR_BUS;
  	    direction : input;
		capacitance : $addr_cap;
	    internal_power(){
	    	when : "!rd_en1";
			power(mem_passive_energy_template) {
				index_1 ("0.0 1.0");
	    		values ("${decode_power}, ${decode_power}") 
	    		/* Decoding Power*/
			}	
		}
		timing() {
			related_pin : "clock_rd1"
			timing_type : setup_rising ;
			rise_constraint(mem_constraint_template_2) {
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("${addr_rise[0]}, ${addr_rise[1]}, ${addr_rise[2]}, ${addr_rise[3]}, ${addr_rise[4]}, ${addr_rise[5]}, ${addr_rise[6]}")
				/* 	************************************************************
					CHANGES WITH CONSTRAINED PIN TRANSITION
				************************************************************** */
			}
			fall_constraint(mem_constraint_template_2) {
				/* 	************************************************************
					CHANGES WITH CONSTRAINED PIN TRANSITION
				************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("${addr_fall[0]}, ${addr_fall[1]}, ${addr_fall[2]}, ${addr_fall[3]}, ${addr_fall[4]}, ${addr_fall[5]}, ${addr_fall[6]}")
			}	
		}
		timing() {
			related_pin : "clock_rd1"
			timing_type : hold_rising ;
			rise_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR AB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR AB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}	
		}	
	}

	
	bus(rd_data1) {
      	bus_type : DATA_BUS;
        direction : output;
        memory_read() {
			address : rd_addr1;
		}
		timing() {
			related_pin :	"clock_rd1";
			timing_type : rising_edge;
			timing_sense : non_unate;

			cell_rise(mem_delay_template) { 
			/* 	************************************************************
				CHANGES WITH OUTPUT NET CAPACITANCE
			************************************************************** */
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${output_delay[0]}, ${output_delay[1]}, ${output_delay[2]}, ${output_delay[3]}, ${output_delay[4]}, ${output_delay[5]}, ${output_delay[6]}")
			}
			cell_fall(mem_delay_template) {
			/* 	************************************************************
				CHANGES WITH OUTPUT NET CAPACITANCE
			************************************************************** */
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${output_delay[0]}, ${output_delay[1]}, ${output_delay[2]}, ${output_delay[3]}, ${output_delay[4]}, ${output_delay[5]}, ${output_delay[6]}")
			}
			
			rise_transition(mem_load_template) {
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${op_rise_tr[0]}, ${op_rise_tr[1]}, ${op_rise_tr[2]}, ${op_rise_tr[3]}, ${op_rise_tr[4]}, ${op_rise_tr[5]}, ${op_rise_tr[6]}")
			}
			fall_transition(mem_load_template) {
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${op_fall_tr[0]}, ${op_fall_tr[1]}, ${op_fall_tr[2]}, ${op_fall_tr[3]}, ${op_fall_tr[4]}, ${op_fall_tr[5]}, ${op_fall_tr[6]}")
			}	
		}
	}
	
	pin(clock_rd1) {
		direction : input;
		capacitance : $clk_cap;
		clock	 : true;
		min_pulse_width_low	 : 0.211;
		min_pulse_width_high	 : 0.058;
		min_period		 : $access_time; 
        max_transition           : $max_transition;
	    internal_power(){
	    	when : "rd_en1";
			power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("0.0, 0.0")
			}
		}
	    internal_power(){
			when : "!rd_en1 ";
			rise_power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("${rd_power_dyn}, ${rd_power_dyn}")
	    		/* */
			}	
			fall_power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("0.0, 0.0")
			}	
		}	
	}

	pin(rd_en2) {
		direction : input;
		capacitance : $en_cap;
		timing() {
			related_pin : "clock_rd2" ;
			timing_type : setup_rising ;
			rise_constraint(mem_constraint_template_1) {
			/* 	************************************************************
				CHANGES WITH RELATED PIN (CLK) TRANSITION
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values ( "0.256, 0.258, 0.262, 0.275, 0.302, 0.349, 0.446")
				
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				CHANGES WITH CONSTRAINED PIN TRANSITION
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values ( "0.506, 0.513, 0.520, 0.550, 0.609, 0.712, 0.920")
			}	
		}
		timing() {
			related_pin : "clock_rd2" ;
			timing_type : hold_rising ;
			rise_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR CENB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR CENB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}	
		}	
	}

	bus (rd_addr2)  {
		bus_type : ADDR_BUS;
  	    direction : input;
		capacitance : $addr_cap;
	    internal_power(){
	    	when : "!rd_en2";
			power(mem_passive_energy_template) {
				index_1 ("0.0 1.0");
	    		values ("${decode_power}, ${decode_power}") 
	    		/* Decoding Power*/
			}	
		}
		timing() {
			related_pin : "clock_rd2"
			timing_type : setup_rising ;
			rise_constraint(mem_constraint_template_2) {
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("${addr_rise[0]}, ${addr_rise[1]}, ${addr_rise[2]}, ${addr_rise[3]}, ${addr_rise[4]}, ${addr_rise[5]}, ${addr_rise[6]}")
				/* 	************************************************************
					CHANGES WITH CONSTRAINED PIN TRANSITION
				************************************************************** */
			}
			fall_constraint(mem_constraint_template_2) {
				/* 	************************************************************
					CHANGES WITH CONSTRAINED PIN TRANSITION
				************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("${addr_fall[0]}, ${addr_fall[1]}, ${addr_fall[2]}, ${addr_fall[3]}, ${addr_fall[4]}, ${addr_fall[5]}, ${addr_fall[6]}")
			}	
		}
		timing() {
			related_pin : "clock_rd2"
			timing_type : hold_rising ;
			rise_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR AB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}
			fall_constraint(mem_constraint_template_2) {
			/* 	************************************************************
				NO HOLD CONSTRATINT FOR AB W.R.T CLKB
			************************************************************** */
				index_1 ("0.010, 0.050, 0.100, 0.300, 0.700, 1.400, 2.800");
				values  ("0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000")
			}	
		}	
	}

	bus(rd_data2) {
      	bus_type : DATA_BUS;
        direction : output;
        memory_read() {
			address : rd_addr2;
		}
		timing() {
			related_pin :	"clock_rd2";
			timing_type : rising_edge;
			timing_sense : non_unate;

			cell_rise(mem_delay_template) { 
			/* 	************************************************************
				CHANGES WITH OUTPUT NET CAPACITANCE
			************************************************************** */
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${output_delay[0]}, ${output_delay[1]}, ${output_delay[2]}, ${output_delay[3]}, ${output_delay[4]}, ${output_delay[5]}, ${output_delay[6]}")
			}
			cell_fall(mem_delay_template) {
			/* 	************************************************************
				CHANGES WITH OUTPUT NET CAPACITANCE
			************************************************************** */
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${output_delay[0]}, ${output_delay[1]}, ${output_delay[2]}, ${output_delay[3]}, ${output_delay[4]}, ${output_delay[5]}, ${output_delay[6]}")
			}
			
			rise_transition(mem_load_template) {
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${op_rise_tr[0]}, ${op_rise_tr[1]}, ${op_rise_tr[2]}, ${op_rise_tr[3]}, ${op_rise_tr[4]}, ${op_rise_tr[5]}, ${op_rise_tr[6]}")
			}
			fall_transition(mem_load_template) {
				index_1 ("0.000, 0.050, 0.100, 0.200, 0.370, 0.750, 1.480");
				values  ("${op_fall_tr[0]}, ${op_fall_tr[1]}, ${op_fall_tr[2]}, ${op_fall_tr[3]}, ${op_fall_tr[4]}, ${op_fall_tr[5]}, ${op_fall_tr[6]}")
			}	
		}
	}
			
	pin(clock_rd2) {
		direction : input;
		capacitance : $clk_cap;
		clock	 : true;
		min_pulse_width_low	 : 0.211;
		min_pulse_width_high	 : 0.058;
		min_period		 : $access_time; 
        max_transition           : $max_transition;
	    internal_power(){
	    	when : "rd_en2";
			power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("0.0, 0.0")
			}
		}
	    internal_power(){
			when : "!rd_en2 ";
			rise_power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("${rd_power_dyn}, ${rd_power_dyn}")
	    		/* */
			}	
			fall_power(mem_passive_energy_template) {
	    		index_1 ("0.0 1.0");
	    		values  ("0.0, 0.0")
			}	
		}	
	}

	cell_leakage_power : $leakage;
    }
}
		
EOM
close(SCRIPT);
print "				.lib FILE CREATION FINISHED\n";
print "##########################################################################\n\n";
print "##########################################################################\n\n";
print "				CREATING DB FILE FOR GIVEN MEMORY CONFIGURATION\n";

	open(SCRIPT,">createdb.tcl") || die "ERROR: Could not open createdb.tcl";
	print SCRIPT <<TEST3;

set data_width $data_width
set addr_width $addr_width
read_lib ./MemGen_${data_width}_${addr_width}.lib
write_lib MemGen_${data_width}_${addr_width}
exit
TEST3
close(SCRIPT);

system("dc_shell-t -f createdb.tcl > dc_shell.out");
print "							DB creation finished\n";
print "##########################################################################\n\n";

	open(SCRIPT,">MemGen_${data_width}_${addr_width}_RTL.v") || die "ERROR: Could not open MemGen_${data_width}_${addr_width}_RTL.v";
	print SCRIPT <<TEST;


//`timescale 1ns/10ps

module MemGen_${data_width}_${addr_width}_RTL (
   rd_data1,
   rd_en1,
   clock_rd1,
   rd_addr1,
   
   rd_data2,
   rd_en2,
   clock_rd2,
   rd_addr2,
   
   clock_wr,
   wr_en,
   wr_addr,
   wr_data
	);

	parameter data_width	=	$data_width;
	parameter addr_width	=	$addr_width;

   output	[data_width-1:0]	rd_data1;
   input						rd_en1;
   input						clock_rd1;
   input	[addr_width-1:0]	rd_addr1;
   
   output	[data_width-1:0]	rd_data2;
   input						rd_en2;
   input						clock_rd2;
   input	[addr_width-1:0]	rd_addr2;
   
   input						clock_wr;
   input						wr_en;
   input	[addr_width-1:0]	wr_addr;
   input	[data_width-1:0]	wr_data;

MemGen_${data_width}_${addr_width} u0 (
   .rd_data1(rd_data1),
   .rd_en1(rd_en1),
   .clock_rd1(clock_rd1),
   .rd_addr1(rd_addr1),
   
   .rd_data2(rd_data2),
   .rd_en2(rd_en2),
   .clock_rd2(clock_rd2),
   .rd_addr2(rd_addr2),
   
   .clock_wr(clock_wr),
   .wr_en(wr_en),
   .wr_addr(wr_addr),
   .wr_data(wr_data)
);

endmodule

TEST

close(SCRIPT);
print "##########################################################################\n\n";
print "				CREATING VERILOG FILE FOR GIVEN MEMORY CONFIGURATION\n";

	open(SCRIPT,">MemGen_${data_width}_${addr_width}.v") || die "ERROR: Could not open MemGen_${data_width}_${addr_width}.v";
	print SCRIPT <<TEST2;


//`timescale 1ns/10ps
 
module MemGen_${data_width}_${addr_width} (
   rd_data1,
   rd_en1,
   clock_rd1,
   rd_addr1,
   
   rd_data2,
   rd_en2,
   clock_rd2,
   rd_addr2,
   
   clock_wr,
   wr_en,
   wr_addr,
   wr_data
);

	parameter data_width	=	$data_width;
	parameter addr_width	=	$addr_width;
	parameter mem_depth	 	=	$mem_depth;

   output	[data_width-1:0]	rd_data1;
   input						rd_en1;
   input						clock_rd1;
   input	[addr_width-1:0]	rd_addr1;
   
   output	[data_width-1:0]	rd_data2;
   input						rd_en2;
   input						clock_rd2;
   input	[addr_width-1:0]	rd_addr2;
   
   input						clock_wr;
   input						wr_en;
   input	[addr_width-1:0]	wr_addr;
   input	[data_width-1:0]	wr_data;
   
   reg		[data_width-1:0]	rd_data1;
   reg		[data_width-1:0]	rd_data2;
   reg		[data_width-1:0]	mem[0:mem_depth-1];
   
   always @ (posedge clock_wr) begin
   		if (wr_en == 0) begin
			mem[wr_addr]	<=	wr_data;
		end   
   end
   
   always @(posedge clock_rd1) begin
   		if(rd_en1 == 0) begin
			rd_data1	<=	mem[rd_addr1];
		end
   end

   always @(posedge clock_rd2) begin
   		if(rd_en2 == 0) begin
			rd_data2	<=	mem[rd_addr2];
		end
   end


endmodule

TEST2
close(SCRIPT);
print " 				Verilog File Creation Finishedn\n";
print "##########################################################################\n\n";

