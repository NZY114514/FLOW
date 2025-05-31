#########################################
# Copyright (C):2025
# File Name:dc_env_gen.py
# Author:niuzhaoyi
# Date:Sat 31 May 2025 23:52:00 PM CST
# Description: gen dc env and script based on dc_config.py
# Modified by: niuzhaoyi
# Email: nzy15854811501@163.com
#########################################

import os
import argparse

def gen_dc_run_tcl():

	str = f'''

#/Library Variables  */
define_design_lib WORK -path ./work

set search_path [list $search_path .  {BASE_DB_PATH}] 

echo 		[concat{{Search path is ..}} $search_path]
echo 		[concat]

set target_library "{BASE_DB}"

set link_library "{BASE_DB}"

	'''


	str += ''
	if DB_FILE != '':
		db_list = DB_FILE.split(":")
		str += ('').join([f'lappend target_library "{db}" \n' for db in db_list])
		str += ('').join([f'lappend link_library "{db}" \n' for db in db_list])

	str += f'''
set_app_var target_library $target_library
set_app_var link_library $link_library
analyze -format sverilog -vcs "-f {FILE_LIST}"
elaborate {MODULE_NAME}
current_design {MODULE_NAME}
uniquify
link
check_design > check_design.rpt
#suppress_message UCN-1
set_fix_multiple_port_nets -feedthrough
set_fix_multiple_port_nets -all -buffer_constants
source -echo ../scripts/dc_parameter.tcl
source -echo ../scripts/constraint.tcl

change_names -rules verilog -hierarchy

set_units -time ns
set_units -capacitance pF

set_wire_load_mode enclosed
#set_max_area 0
#set_operating_conditions TCCOM
#set_operating_conditions -max TCCOM -min WCCOM -max_library{{fof0a_prs25_io_ttlv25c}} -min_library {{fof0a_prs25_io_ss0p9v125c}}

set auto_wire_load_selection 	true

#set_max_fanout 32 [current_design]

compile_ultra

set_svf ../design_data/ddj_top.svf

#write 1
write_file -format verilog -hierarchy -output /home/ICer/dc_example/design_data/{MODULE_NAME}_before_flatten.v

#save hierarchy
report_qor
sizeof_collection [get_cells -hierarchical]
sizeof_collection [get_cells *]
sizeof_collection [get_cells -hierarchical]

write_sdc /home/ICer/dc_example/design_data/{MODULE_NAME}.sdc
write_sdf /home/ICer/dc_example/design_data/{MODULE_NAME}.sdf
write_parasitics -output  /home/ICer/dc_example/design_data/{MODULE_NAME}_max.spef
write_parasitics -output  /home/ICer/dc_example/design_data/{MODULE_NAME}_min.spef
write_file -hier -f ddc -output /home/ICer/dc_example/design_data/rpt/ddj_top.ddc

report_timing > /home/ICer/dc_example/design_data/rpt/report_timing.rpt
report_power  > /home/ICer/dc_example/design_data/rpt/report_power.rpt
report_timing -max_path 1000 > /home/ICer/dc_example/design_data/rpt/report_timing_max1000.rpt
report_timing -path full > /home/ICer/dc_example/design_data/rpt/report_timing_full.rpt
#report_logic_levels > /home/ICer/dc_example/design_data/rpt/logic_levels.rpt
report_timing -delay max > /home/ICer/dc_example/design_data/rpt/report_timing_max.rpt
report_timing -delay min > /home/ICer/dc_example/design_data/rpt/report_timing_min.rpt 
report_qor > /home/ICer/dc_example/design_data/rpt/report_qor.rpt
report_constraint -all_violators > /home/ICer/dc_example/design_data/rpt/report_constraint-all_violators.rpt
check_timing > /home/ICer/dc_example/design_data/rpt/check_timing.rpt

	'''
	with open(f"{OUTPUTDIR}/scripts/dc_run.tcl",'w') as f:
		f.write(str)

def gen_dc_parameter_tcl():
	str = f'''
##########HDL Rules##########
set hdlin_check_no_latch						true
set hdlin_suppress_warnings						false
set hdlin_ff_always_sync_set_reset				 	true
set hdlin_infer_mux							default
set hdlin_keep_signal_name 						all_driving
set hdlin_on_sequential_mapping					false
set compile_delete_unloaded_sequential_cells			true
set hdlin_preserve_sequential					true


##########Verilog  Rules##########
#get rid of tri-state declarations and assings
set verilogout_no_tri						true
set verilogout_show_unconnected_pins				true
set verilogout_equation						false
set verilogout_single_bit						false

###########compile variable##########
set write_name_nets_same_as_ports					true
set compile_assume_fully_decoded_three_state_buses		true
set compile_no_new_cells_at_top_level				false
set compile_preserve_sync_resets					true

#remove	assign statements
set compile_fix_multiple_port_nets					true

set enable_recovery_removal_arcs					true
set_fix_multiple_port_nets -all -buffer_constants

##########scan optinos##########
set insert_test_design_naming_style "%s_%d"

set designer {DESIGNER}
	'''
	with open(f"{OUTPUTDIR}/scripts/dc_parameter.tcl",'w') as f:
		f.write(str)

def gen_constraint_tcl():
	str = f'''
set compile_enable_constant_propagation_with_no_boundary_opt	false
set timing_enable_multiple_clocks_per_reg				true
set enable_recovery_removal_arcs					true

create_clock -period {CLOCK_PERIOD} -waveform {{0 {CLOCK_PERIOD/2}}} -name clk [get_ports clk]

set_max_transition 0.3 [current_design]
set_max_transition -clock_path 0.1 [all_clocks]
set_max_fanout 32 [current_design]
set_clock_transition 0.1 [all_clocks]
set_input_transition 0.3 [all_inputs]

#set_driving_sell
#set_load

set_input_delay 0.8 -clock clk [all_inputs]

set_output_delay 0.8 -clock clk [all_outputs]

#set_false_path -from [get_ports reset_n]
	'''

	with open(f"{OUTPUTDIR}/scripts/constraint.tcl",'w') as f:
		f.write(str)

def gen_makefile():
	str = f'''
dc_run:
	dc_shell -f ../scripts/dc_run.tcl | tee ../log/$$(log +'%Y-%m-%d')
clean:
	find . -type f ! -name 'makefile' -exec rm -f {{}} +
	'''
	with open(f"{OUTPUTDIR}/work/makefile",'w') as f:
		f.write(str)

    

if __name__ == "__main__":

	parser = argparse.ArgumentParser()

	parser.add_argument('-o','--output',type=str,help="output dir")
	parser.add_argument('-c','--config',type=str,help="config file")

	args = parser.parse_args()
	OUTPUTDIR = args.output
	with open(args.config, 'r') as f:
		code = f.read()
	exec(code)

	os.system(f'''
		if ! [ -d {OUTPUTDIR} ];then
			mkdir {OUTPUTDIR}
		fi
		if ! [ -d {OUTPUTDIR}/scripts ];then
			mkdir {OUTPUTDIR}/scripts
		fi
		if ! [ -d {OUTPUTDIR}/work ];then
			mkdir {OUTPUTDIR}/work
		fi
		if ! [ -d {OUTPUTDIR}/log ];then
			mkdir {OUTPUTDIR}/log
		fi
		if ! [ -d {OUTPUTDIR}/design_data ];then
			mkdir {OUTPUTDIR}/design_data
		fi
	''')
	gen_dc_run_tcl()
	gen_dc_parameter_tcl()
	gen_constraint_tcl()
	gen_makefile()
