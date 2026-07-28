# Copyright (C) 2022  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: qii_Cyclone10LP_Prj.tcl
# Generated on: Tue Jul 28 17:35:21 2026

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "qii_Cyclone10LP_Prj"]} {
		puts "Project qii_Cyclone10LP_Prj is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists qii_Cyclone10LP_Prj]} {
		project_open -revision qii_Cyclone10LP_Prj qii_Cyclone10LP_Prj
	} else {
		project_new -revision qii_Cyclone10LP_Prj qii_Cyclone10LP_Prj
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone 10 LP"
	set_global_assignment -name DEVICE 10CL016YU256I7G
	set_global_assignment -name TOP_LEVEL_ENTITY Top
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 21.1.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "22:19:35  JULY 27, 2026"
	set_global_assignment -name LAST_QUARTUS_VERSION "21.1.1 Standard Edition"
	set_global_assignment -name DEVICE_FILTER_PACKAGE UFBGA
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 256
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 7
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP "-40"
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/CommandFIFO.v
	set_global_assignment -name VERILOG_FILE ../src/UDP_Offloading_Engine_Wrapper.v
	set_global_assignment -name VERILOG_FILE ../src/Top.v
	set_global_assignment -name QIP_FILE ../ip/Sys_Clk_PLL.qip
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
