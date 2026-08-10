`timescale 1ns / 1ps

module Top
(
input CLK_100MHZ                    ,


input  wire          RGMII_RXC,
input  wire          RGMII_RX_CTL,
input  wire [4-1:0]  RGMII_RXD,

output wire          RGMII_TXC,
output wire          RGMII_TX_CTL,
output wire [4-1:0]  RGMII_TXD,

output reg EtheReset =0             // Inverted on PCB. EtheReset == 1 -> PHY is reseted

 );
 
(* keep = "true" *) reg [16-1:0] wUDP_LOCAL_PORT_TG = 16'd9998;  
(* keep = "true" *) reg [16-1:0] wUDP_LOCAL_PORT_LB = 16'd9999;  

(* keep = "true" *) reg  [  48-1:0] wMAC_LOCAL_ADDR = 48'hCC28AA040506;
(* keep = "true" *) reg  [  32-1:0] wIP4_LOCAL_ADDR = {8'd192,8'd168,8'd0,8'd49};  
 

(* keep = "true" *) wire           wEthClk125;
(* keep = "true" *) wire           wEthClk125_90;

 (* KEEP_HIERARCHY = "TRUE" *)
 Sys_Clk_PLL  Sys_Clk_PLL_inst
 (
  // Clock out ports
  .clk_out1 (wEthClk125),
  .clk_out2 (wEthClk125_90),
  // Status and control signals
  .locked   (),
 // Clock in ports
  .clk_in1 (CLK_100MHZ)
 );
 

(* KEEP_HIERARCHY = "TRUE" *)
UDP_LoopBack_Wrapper
#(
.RX_ARCH("XLX_SERIES7"),
.TX_ARCH("XLX_SERIES7"),
.MB_ARCH("XLX_SERIES7"),
.RX_CLK_BUFF_SCH_TYPE(1)
)UDP_LoopBack_Wrapper_inst
(
.CLK625MHZ      (0),
.EthClk125      (wEthClk125),
.EthClk125_90   (wEthClk125_90),

.MAC_LOCAL_ADDR_IN          (wMAC_LOCAL_ADDR),
.IP4_LOCAL_ADDR_IN          (wIP4_LOCAL_ADDR),
.UDP_LOCAL_PORT_TG_IN       (wUDP_LOCAL_PORT_TG),
.UDP_LOCAL_PORT_LB_IN       (wUDP_LOCAL_PORT_LB),

.RGMII_RXC      (RGMII_RXC),
.RGMII_RX_CTL   (RGMII_RX_CTL),
.RGMII_RXD      (RGMII_RXD),

.RGMII_TXC      (RGMII_TXC),
.RGMII_TX_CTL   (RGMII_TX_CTL),
.RGMII_TXD      (RGMII_TXD)
);

endmodule
