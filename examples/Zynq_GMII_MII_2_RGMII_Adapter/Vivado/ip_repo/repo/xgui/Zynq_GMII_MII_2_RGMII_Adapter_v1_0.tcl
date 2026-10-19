# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "RX_ARCH" -widget comboBox
  ipgui::add_param $IPINST -name "TX_ARCH" -widget comboBox
  ipgui::add_param $IPINST -name "MB_ARCH" -widget comboBox
  ipgui::add_param $IPINST -name "RX_CLK_BUFF_SCH_TYPE"

}

proc update_PARAM_VALUE.MB_ARCH { PARAM_VALUE.MB_ARCH } {
	# Procedure called to update MB_ARCH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MB_ARCH { PARAM_VALUE.MB_ARCH } {
	# Procedure called to validate MB_ARCH
	return true
}

proc update_PARAM_VALUE.RGMII_TXC_FRONT_POSITION { PARAM_VALUE.RGMII_TXC_FRONT_POSITION } {
	# Procedure called to update RGMII_TXC_FRONT_POSITION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RGMII_TXC_FRONT_POSITION { PARAM_VALUE.RGMII_TXC_FRONT_POSITION } {
	# Procedure called to validate RGMII_TXC_FRONT_POSITION
	return true
}

proc update_PARAM_VALUE.RGMII_TXC_REFERENCE_CLK { PARAM_VALUE.RGMII_TXC_REFERENCE_CLK } {
	# Procedure called to update RGMII_TXC_REFERENCE_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RGMII_TXC_REFERENCE_CLK { PARAM_VALUE.RGMII_TXC_REFERENCE_CLK } {
	# Procedure called to validate RGMII_TXC_REFERENCE_CLK
	return true
}

proc update_PARAM_VALUE.RGMII_TXD_REFERENCE_CLK { PARAM_VALUE.RGMII_TXD_REFERENCE_CLK } {
	# Procedure called to update RGMII_TXD_REFERENCE_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RGMII_TXD_REFERENCE_CLK { PARAM_VALUE.RGMII_TXD_REFERENCE_CLK } {
	# Procedure called to validate RGMII_TXD_REFERENCE_CLK
	return true
}

proc update_PARAM_VALUE.RX_ARCH { PARAM_VALUE.RX_ARCH } {
	# Procedure called to update RX_ARCH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_ARCH { PARAM_VALUE.RX_ARCH } {
	# Procedure called to validate RX_ARCH
	return true
}

proc update_PARAM_VALUE.RX_CLK_BUFF_SCH_TYPE { PARAM_VALUE.RX_CLK_BUFF_SCH_TYPE } {
	# Procedure called to update RX_CLK_BUFF_SCH_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_CLK_BUFF_SCH_TYPE { PARAM_VALUE.RX_CLK_BUFF_SCH_TYPE } {
	# Procedure called to validate RX_CLK_BUFF_SCH_TYPE
	return true
}

proc update_PARAM_VALUE.TX_ARCH { PARAM_VALUE.TX_ARCH } {
	# Procedure called to update TX_ARCH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_ARCH { PARAM_VALUE.TX_ARCH } {
	# Procedure called to validate TX_ARCH
	return true
}


proc update_MODELPARAM_VALUE.RX_ARCH { MODELPARAM_VALUE.RX_ARCH PARAM_VALUE.RX_ARCH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_ARCH}] ${MODELPARAM_VALUE.RX_ARCH}
}

proc update_MODELPARAM_VALUE.TX_ARCH { MODELPARAM_VALUE.TX_ARCH PARAM_VALUE.TX_ARCH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_ARCH}] ${MODELPARAM_VALUE.TX_ARCH}
}

proc update_MODELPARAM_VALUE.RX_CLK_BUFF_SCH_TYPE { MODELPARAM_VALUE.RX_CLK_BUFF_SCH_TYPE PARAM_VALUE.RX_CLK_BUFF_SCH_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_CLK_BUFF_SCH_TYPE}] ${MODELPARAM_VALUE.RX_CLK_BUFF_SCH_TYPE}
}

proc update_MODELPARAM_VALUE.MB_ARCH { MODELPARAM_VALUE.MB_ARCH PARAM_VALUE.MB_ARCH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MB_ARCH}] ${MODELPARAM_VALUE.MB_ARCH}
}

proc update_MODELPARAM_VALUE.RGMII_TXC_FRONT_POSITION { MODELPARAM_VALUE.RGMII_TXC_FRONT_POSITION PARAM_VALUE.RGMII_TXC_FRONT_POSITION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RGMII_TXC_FRONT_POSITION}] ${MODELPARAM_VALUE.RGMII_TXC_FRONT_POSITION}
}

proc update_MODELPARAM_VALUE.RGMII_TXD_REFERENCE_CLK { MODELPARAM_VALUE.RGMII_TXD_REFERENCE_CLK PARAM_VALUE.RGMII_TXD_REFERENCE_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RGMII_TXD_REFERENCE_CLK}] ${MODELPARAM_VALUE.RGMII_TXD_REFERENCE_CLK}
}

proc update_MODELPARAM_VALUE.RGMII_TXC_REFERENCE_CLK { MODELPARAM_VALUE.RGMII_TXC_REFERENCE_CLK PARAM_VALUE.RGMII_TXC_REFERENCE_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RGMII_TXC_REFERENCE_CLK}] ${MODELPARAM_VALUE.RGMII_TXC_REFERENCE_CLK}
}

