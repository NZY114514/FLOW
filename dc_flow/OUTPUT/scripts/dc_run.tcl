lappend target_library "/home/ICer/svn/lz4/trunk/rtl/S55NLLGDPH_X256Y4D64_tt_1.2_25.db" 
lappend target_library "/home/ICer/svn/lz4/trunk/rtl/S55NLLGDPH_X256Y4D8_tt_1.2_25.db" 
lappend link_library "/home/ICer/svn/lz4/trunk/rtl/S55NLLGDPH_X256Y4D64_tt_1.2_25.db" 
lappend link_library "/home/ICer/svn/lz4/trunk/rtl/S55NLLGDPH_X256Y4D8_tt_1.2_25.db" 

set_app_var target_library $target_library
set_app_var link_library $link_library
analyze -format sverilog -vcs "-f /home/ICer/svn/lz4/trunk/work/dc_filelist.f"
elaborate ddj_top
current_design ddj_top
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
#set_operating_conditions -max TCCOM -min WCCOM -max_library{fof0a_prs25_io_ttlv25c} -min_library {fof0a_prs25_io_ss0p9v125c}

set auto_wire_load_selection 	true

#set_max_fanout 32 [current_design]

compile_ultra

set_svf ../design_data/ddj_top.svf

#write 1
write_file -format verilog -hierarchy -output /home/ICer/dc_example/design_data/ddj_top_before_flatten.v

#save hierarchy
report_qor
sizeof_collection [get_cells -hierarchical]
sizeof_collection [get_cells *]
sizeof_collection [get_cells -hierarchical]

write_sdc /home/ICer/dc_example/design_data/ddj_top.sdc
write_sdf /home/ICer/dc_example/design_data/ddj_top.sdf
write_parasitics -output  /home/ICer/dc_example/design_data/ddj_top_max.spef
write_parasitics -output  /home/ICer/dc_example/design_data/ddj_top_min.spef
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

	