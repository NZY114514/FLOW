
set compile_enable_constant_propagation_with_no_boundary_opt	false
set timing_enable_multiple_clocks_per_reg				true
set enable_recovery_removal_arcs					true

create_clock -period 4.0 -waveform {0 2.0} -name clk [get_ports clk]

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
	