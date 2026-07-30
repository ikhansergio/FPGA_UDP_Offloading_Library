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
# Generated on: Thu Jul 30 11:13:28 2026

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
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
	set_global_assignment -name VERILOG_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_8k_BLK/ALT_x36_8k_BLK.v
	set_global_assignment -name QIP_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_8k_BLK/ALT_x36_8k_BLK.qip
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_4k_BLK/ALT_x36_4k_BLK.v
	set_global_assignment -name QIP_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_4k_BLK/ALT_x36_4k_BLK.qip
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_2k_BLK/ALT_x36_2k_BLK.v
	set_global_assignment -name QIP_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_2k_BLK/ALT_x36_2k_BLK.qip
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_1k_BLK/ALT_x36_1k_BLK.v
	set_global_assignment -name QIP_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_x36_1k_BLK/ALT_x36_1k_BLK.qip
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_BLK_FIFO_36x256/ALT_BLK_FIFO_36x256.v
	set_global_assignment -name QIP_FILE ../../../../../library/_common_src/Hard_IP/Altera/ALT_BLK_FIFO_36x256/ALT_BLK_FIFO_36x256.qip
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/UDP_RxDatagramProcessing_Core_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/nextCRC32_D8_fcs.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/MAC_FrameBody2EthernetPhysicalFrameConverter_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/IPv4_Rx_Packet_Processing_Core_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/ICMP_PING_RAM_DataBuffer_x32.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/ICMP_PING_Offloading_Engine_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/ICMP_PING_IPv4_Header_Generator_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/ICMP_PING_CheckSum.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/EthTxSchedulerRequestEncoder.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/EthTxScheduler.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/EthernetTxFramePreambleInsertion_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/EthernetTxFrameFCSinsertion_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/EthernetRxFrameFCS_Remover_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/EthernetRxFrameFCS_Check_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/Ethernet_II_FrameProcessing_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/Ethernet_II_FrameDecoder_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/AXISx8_UDP_Offloading_Engine.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/AXISx8_Network_Layer_Core.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/AXISx8_Ethernet_II_MAC_Core.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Offloading_Engine/src/ARP_Offloading_Engine_x8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/UDP_RAM_DataBuffer_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/UDP_CheckSumCalc.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/Gray2BinRegisteredInOut.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/Bin2GrayRegisteredOut.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/AXISx32_InputChecker.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/AXISx8_UDP_Framing_AXISx32_Sink.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/XLX_SERIES7_Clk_Buff_Schematic_Type.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_TXC_FORMING_CLK_REFERENCE_PHY_RXC.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_TXC_FORMING_CLK_REFERENCE_250MHz.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_TXC_FORMING_CLK_REFERENCE_125MHz.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_TX_PHY.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_Rx_To_AXISx8.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_RX_PHY.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_OverSampler_ClockShift.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_OverSampler.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_ODDR.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_IDDR_WRAPPER.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/RGMII_IDDR.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/ODDR_LOGIC.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/IDDR_LOGIC.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_RGMII_BRIDGE/src/AXISx8_RGMII_BRIDGE.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_Fabric_REG_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_DistRAM_512_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_BlockRAM_8k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_BlockRAM_4k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_BlockRAM_2k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_BlockRAM_1k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_512_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_16k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_15k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_14k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_13k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_12k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_11k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_10k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_9k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_8k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_7k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_6k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_5k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_4k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_3k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_2k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/RAM_Buffers/DataBuffer_1k_x36.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/UDP_Header_Generator.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/PacketTypeValidation.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/IPv4_Header_Generator.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/ICMP_UDP_Frame_Header_Multiplexer.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/Ethernet_II_MAC_Header_Generator.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/AXIS32_PayloadCheckSum.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/_common_src/AXIS_Width_Up_Converter.v
	set_global_assignment -name VERILOG_FILE ../../../../../library/AXISx8_UDP_Framing_AXISx32_Sink/src/CommandFIFO.v
	set_global_assignment -name VERILOG_FILE ../src/UDP_Offloading_Engine_Wrapper.v
	set_global_assignment -name VERILOG_FILE ../src/Top.v
	set_global_assignment -name QIP_FILE ../ip/Sys_Clk_PLL.qip
	set_global_assignment -name VERILOG_FILE ../src/AXISx8_Clock_Crossing_FIFO.v
	set_global_assignment -name SDC_FILE ../constrs/Constr_Cyclone10LP_KSZ9031_RGMII.sdc
	set_location_assignment PIN_R8 -to CLK_100MHZ
	set_location_assignment PIN_T8 -to RGMII_RXC
	set_location_assignment PIN_M8 -to EtheReset
	set_location_assignment PIN_M6 -to RGMII_RXD[3]
	set_location_assignment PIN_M7 -to RGMII_RXD[2]
	set_location_assignment PIN_N5 -to RGMII_RXD[1]
	set_location_assignment PIN_N6 -to RGMII_RXD[0]
	set_location_assignment PIN_N8 -to RGMII_RX_CTL
	set_location_assignment PIN_R7 -to RGMII_TXC
	set_location_assignment PIN_T7 -to RGMII_TXD[3]
	set_location_assignment PIN_R6 -to RGMII_TXD[2]
	set_location_assignment PIN_T6 -to RGMII_TXD[1]
	set_location_assignment PIN_R5 -to RGMII_TXD[0]
	set_location_assignment PIN_T5 -to RGMII_TX_CTL
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
