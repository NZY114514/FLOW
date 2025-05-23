
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

set designer niuzhaoyi
	