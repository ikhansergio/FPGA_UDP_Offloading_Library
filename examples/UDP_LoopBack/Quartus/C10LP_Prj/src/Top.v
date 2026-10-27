`timescale 1ns / 1ps

 module Top
#(
parameter ETH_RESET_POLARITY = "POSITIVE",   // "POSITIVE" or "NEGATIVE"
parameter TX_MAC_Ports_Count = 1  ,
parameter RX_UDP_Ports_Count = 1    
)
(
input CLK_100MHZ                    ,

input  wire          RGMII_RXC      ,
input  wire          RGMII_RX_CTL   ,
input  wire [4-1:0]  RGMII_RXD      ,

output wire          RGMII_TXC      ,
output wire          RGMII_TX_CTL   ,
output wire [4-1:0]  RGMII_TXD      ,

output reg           RGMII_PHY_RST =0             

 );

(* keep = "true" *) reg [16-1:0] wUDP_LOCAL_PORT_LB = 16'd9998;  
(* keep = "true" *) reg [16-1:0] wUDP_LOCAL_PORT_TG = 16'd9999;  

(* keep = "true" *) reg  [  48-1:0] wMAC_LOCAL_ADDR = 48'hCC28AA040506;
(* keep = "true" *) reg  [  32-1:0] wIP4_LOCAL_ADDR = {8'd192,8'd168,8'd0,8'd49};  
 

(* keep = "true" *) wire           wEthClk125;
(* keep = "true" *) wire           wEthClk125_90;
(* keep = "true" *) wire           wEthClk_25;

 (* KEEP_HIERARCHY = "TRUE" *)
 Sys_Clk_PLL  Sys_Clk_PLL_inst
 (
	// Clock in ports
 	.inclk0 ( CLK_100MHZ ),
	// Clock out ports
	.c0 ( wEthClk125    ),
	.c1 ( wEthClk125_90 ),
	.c2 ( wEthClk_25    ),
	// Status and control signals
	.locked (  )
 );

reg [20-1:0] EtheResetCounter =1; 
wire wResetCondition;
assign wResetCondition = (EtheResetCounter!=0);
always @(posedge wEthClk_25)
begin
if (wResetCondition) EtheResetCounter<=EtheResetCounter+1'b1;
if (ETH_RESET_POLARITY == "POSITIVE" ) RGMII_PHY_RST <= wResetCondition;
    else RGMII_PHY_RST <= !wResetCondition;
end 

(* KEEP_HIERARCHY = "TRUE" *)
UDP_LoopBack_Wrapper
#(
.RX_ARCH                ("ALT_Cyclone10LP"  ),
.TX_ARCH                ("ALT_Cyclone10LP"  ),
.MB_ARCH                ("ALT_Cyclone10LP"  ),
.RX_CLK_BUFF_SCH_TYPE   (1              	  ),
.TX_MAC_Ports_Count     (TX_MAC_Ports_Count ),
.RX_UDP_Ports_Count		(RX_UDP_Ports_Count ),
.OVER_SAMPLING          ("NO"           	  ),
.OVER_SAMPLING_SHIFT    (0                  )
)UDP_LoopBack_Wrapper_inst
(
.CLK625MHZ                  (0),
.EthClk125                  (wEthClk125),
.EthClk125_90               (wEthClk125_90),

.MAC_LOCAL_ADDR_IN          (wMAC_LOCAL_ADDR),
.IP4_LOCAL_ADDR_IN          (wIP4_LOCAL_ADDR),
.UDP_LOCAL_PORT_UC_IN       (wUDP_LOCAL_PORT_UC),
.UDP_LOCAL_PORT_TG_IN       (wUDP_LOCAL_PORT_TG),
.UDP_LOCAL_PORT_LB_IN       (wUDP_LOCAL_PORT_LB),

.UDP_Data_Source_CLK        (),
.UDP_Data_Source_TFIRST     (),
.UDP_Data_Source_TVALID     (),
.UDP_Data_Source_TERROR     (),
.UDP_Data_Source_TLAST      (),
.UDP_Data_Source_TDATA      (),

.MAC_REMOTE_ADDR_OUT        (),
.IP4_REMOTE_ADDR_OUT        (),
.UDP_REMOTE_PORT_OUT        (),

.MAC_TxFrameBody_TRDY       (),
.MAC_TxFrameBody_TVALID     (0),
.MAC_TxFrameBody_TERROR     (0),
.MAC_TxFrameBody_TLAST      (0),
.MAC_TxFrameBody_TDATA      (0),

.RGMII_RXC                  (RGMII_RXC      ),
.RGMII_RX_CTL               (RGMII_RX_CTL   ),
.RGMII_RXD                  (RGMII_RXD      ),

.RGMII_TXC                  (RGMII_TXC      ),
.RGMII_TX_CTL               (RGMII_TX_CTL   ),
.RGMII_TXD                  (RGMII_TXD      )
);

endmodule
