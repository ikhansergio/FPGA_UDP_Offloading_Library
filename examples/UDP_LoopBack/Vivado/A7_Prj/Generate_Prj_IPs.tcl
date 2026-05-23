##################################################################
# CHECK VIVADO VERSION
##################################################################

set scripts_vivado_version 2023.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  catch {common::send_msg_id "IPS_TCL-100" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_ip_tcl to create an updated script."}
  return 1
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source my_ips.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project vv_Artix7 vv_Artix7 -part xc7a50ticsg325-1L
  set_property target_language Verilog [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:axis_data_fifo:2.0 xilinx.com:ip:fifo_generator:13.2 xilinx.com:ip:clk_wiz:6.0 xilinx.com:ip:blk_mem_gen:8.4 xilinx.com:ip:dist_mem_gen:8.0 }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP AXISx8_Clock_Crossing_FIFO
##################################################################

set AXISx8_Clock_Crossing_FIFO [create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name AXISx8_Clock_Crossing_FIFO]

# User Parameters
set_property -dict [list \
  CONFIG.FIFO_DEPTH {32} \
  CONFIG.HAS_TLAST {1} \
  CONFIG.IS_ACLK_ASYNC {1} \
  CONFIG.PROG_FULL_THRESH {13} \
  CONFIG.SYNCHRONIZATION_STAGES {8} \
  CONFIG.TUSER_WIDTH {1} \
] [get_ips AXISx8_Clock_Crossing_FIFO]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $AXISx8_Clock_Crossing_FIFO

##################################################################

##################################################################
# CREATE IP RGMII_ELASTIC_FIFO
##################################################################

set RGMII_ELASTIC_FIFO [create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name RGMII_ELASTIC_FIFO]

# User Parameters
set_property -dict [list \
  CONFIG.Data_Count_Width {5} \
  CONFIG.Empty_Threshold_Assert_Value {8} \
  CONFIG.Empty_Threshold_Negate_Value {9} \
  CONFIG.Fifo_Implementation {Independent_Clocks_Distributed_RAM} \
  CONFIG.Full_Threshold_Assert_Value {24} \
  CONFIG.Full_Threshold_Negate_Value {23} \
  CONFIG.Input_Data_Width {10} \
  CONFIG.Input_Depth {32} \
  CONFIG.Output_Data_Width {10} \
  CONFIG.Output_Depth {32} \
  CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant} \
  CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant} \
  CONFIG.Read_Data_Count_Width {5} \
  CONFIG.Reset_Pin {false} \
  CONFIG.Reset_Type {Asynchronous_Reset} \
  CONFIG.Use_Dout_Reset {false} \
  CONFIG.Use_Embedded_Registers {false} \
  CONFIG.Write_Data_Count_Width {5} \
  CONFIG.synchronization_stages {4} \
] [get_ips RGMII_ELASTIC_FIFO]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $RGMII_ELASTIC_FIFO

##################################################################

##################################################################
# CREATE IP Sys_Clk_PLL
##################################################################

set Sys_Clk_PLL [create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name Sys_Clk_PLL]

# User Parameters
set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {116.571} \
  CONFIG.CLKOUT1_PHASE_ERROR {91.100} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
  CONFIG.CLKOUT2_JITTER {116.571} \
  CONFIG.CLKOUT2_PHASE_ERROR {91.100} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
  CONFIG.CLKOUT2_REQUESTED_PHASE {90} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT3_JITTER {128.710} \
  CONFIG.CLKOUT3_PHASE_ERROR {91.100} \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {75} \
  CONFIG.CLKOUT3_USED {true} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {11.250} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {9.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {9} \
  CONFIG.MMCM_CLKOUT1_PHASE {90.000} \
  CONFIG.MMCM_CLKOUT2_DIVIDE {15} \
  CONFIG.NUM_OUT_CLKS {3} \
  CONFIG.PRIM_SOURCE {No_buffer} \
  CONFIG.USE_RESET {false} \
] [get_ips Sys_Clk_PLL]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $Sys_Clk_PLL

##################################################################

##################################################################
# CREATE IP XLX_LUT_FIFO_36x64
##################################################################

set XLX_LUT_FIFO_36x64 [create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name XLX_LUT_FIFO_36x64]

# User Parameters
set_property -dict [list \
  CONFIG.Almost_Full_Flag {false} \
  CONFIG.Data_Count_Width {6} \
  CONFIG.Empty_Threshold_Assert_Value {4} \
  CONFIG.Empty_Threshold_Negate_Value {5} \
  CONFIG.Fifo_Implementation {Independent_Clocks_Distributed_RAM} \
  CONFIG.Full_Flags_Reset_Value {1} \
  CONFIG.Full_Threshold_Assert_Value {60} \
  CONFIG.Full_Threshold_Negate_Value {59} \
  CONFIG.Input_Data_Width {36} \
  CONFIG.Input_Depth {64} \
  CONFIG.Output_Data_Width {36} \
  CONFIG.Output_Depth {64} \
  CONFIG.Performance_Options {First_Word_Fall_Through} \
  CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant} \
  CONFIG.Read_Data_Count_Width {6} \
  CONFIG.Reset_Pin {true} \
  CONFIG.Reset_Type {Asynchronous_Reset} \
  CONFIG.Write_Data_Count_Width {6} \
  CONFIG.synchronization_stages {3} \
] [get_ips XLX_LUT_FIFO_36x64]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $XLX_LUT_FIFO_36x64

##################################################################

##################################################################
# CREATE IP XLX_x36_1k_BLK
##################################################################

set XLX_x36_1k_BLK [create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name XLX_x36_1k_BLK]

# User Parameters
set_property -dict [list \
  CONFIG.Byte_Size {9} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Operating_Mode_A {NO_CHANGE} \
  CONFIG.Port_B_Clock {100} \
  CONFIG.Port_B_Enable_Rate {100} \
  CONFIG.Read_Width_A {36} \
  CONFIG.Read_Width_B {36} \
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
  CONFIG.Use_Byte_Write_Enable {false} \
  CONFIG.Write_Depth_A {256} \
  CONFIG.Write_Width_A {36} \
  CONFIG.Write_Width_B {36} \
] [get_ips XLX_x36_1k_BLK]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $XLX_x36_1k_BLK

##################################################################

##################################################################
# CREATE IP XLX_x36_2k_BLK
##################################################################

set XLX_x36_2k_BLK [create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name XLX_x36_2k_BLK]

# User Parameters
set_property -dict [list \
  CONFIG.Byte_Size {9} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Operating_Mode_A {NO_CHANGE} \
  CONFIG.Port_B_Clock {100} \
  CONFIG.Port_B_Enable_Rate {100} \
  CONFIG.Read_Width_A {36} \
  CONFIG.Read_Width_B {36} \
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
  CONFIG.Use_Byte_Write_Enable {false} \
  CONFIG.Write_Depth_A {512} \
  CONFIG.Write_Width_A {36} \
  CONFIG.Write_Width_B {36} \
] [get_ips XLX_x36_2k_BLK]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $XLX_x36_2k_BLK

##################################################################

##################################################################
# CREATE IP XLX_x36_4k_BLK
##################################################################

set XLX_x36_4k_BLK [create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name XLX_x36_4k_BLK]

# User Parameters
set_property -dict [list \
  CONFIG.Byte_Size {9} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Operating_Mode_A {NO_CHANGE} \
  CONFIG.Port_B_Clock {100} \
  CONFIG.Port_B_Enable_Rate {100} \
  CONFIG.Read_Width_A {36} \
  CONFIG.Read_Width_B {36} \
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
  CONFIG.Use_Byte_Write_Enable {false} \
  CONFIG.Write_Depth_A {1024} \
  CONFIG.Write_Width_A {36} \
  CONFIG.Write_Width_B {36} \
] [get_ips XLX_x36_4k_BLK]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $XLX_x36_4k_BLK

##################################################################

##################################################################
# CREATE IP XLX_x36_512_DIST
##################################################################

set XLX_x36_512_DIST [create_ip -name dist_mem_gen -vendor xilinx.com -library ip -version 8.0 -module_name XLX_x36_512_DIST]

# User Parameters
set_property -dict [list \
  CONFIG.common_output_clk {false} \
  CONFIG.data_width {36} \
  CONFIG.depth {128} \
  CONFIG.input_clock_enable {true} \
  CONFIG.input_options {registered} \
  CONFIG.memory_type {simple_dual_port_ram} \
  CONFIG.output_options {both} \
  CONFIG.qualify_we_with_i_ce {true} \
  CONFIG.simple_dual_port_address {registered} \
  CONFIG.simple_dual_port_output_clock_enable {true} \
] [get_ips XLX_x36_512_DIST]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $XLX_x36_512_DIST

##################################################################

##################################################################
# CREATE IP XLX_x36_8k_BLK
##################################################################

set XLX_x36_8k_BLK [create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name XLX_x36_8k_BLK]

# User Parameters
set_property -dict [list \
  CONFIG.Byte_Size {9} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Operating_Mode_A {NO_CHANGE} \
  CONFIG.Port_B_Clock {100} \
  CONFIG.Port_B_Enable_Rate {100} \
  CONFIG.Read_Width_A {36} \
  CONFIG.Read_Width_B {36} \
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
  CONFIG.Use_Byte_Write_Enable {false} \
  CONFIG.Write_Depth_A {2048} \
  CONFIG.Write_Width_A {36} \
  CONFIG.Write_Width_B {36} \
] [get_ips XLX_x36_8k_BLK]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $XLX_x36_8k_BLK

##################################################################

