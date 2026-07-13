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
 
wire wRGMII_RXC;
 
(* KEEP = "TRUE" *)wire  		 wUDP_Data_TFIRST;
(* KEEP = "TRUE" *)wire 		 wUDP_Data_TVALID;
(* KEEP = "TRUE" *)wire 		 wUDP_Data_TERROR;
(* KEEP = "TRUE" *)wire		     wUDP_Data_TLAST ;
(* KEEP = "TRUE" *)wire [ 8-1:0] wUDP_Data_TDATA ;
 
//(* KEEP = "TRUE" *)wire            wUDP_Data_TFIRST_x32 ;
//(* KEEP = "TRUE" *)wire            wUDP_Data_TERROR_x32 ;
(* KEEP = "TRUE" *)wire            wUDP_Data_TVALID_x32 ;
(* KEEP = "TRUE" *)wire            wUDP_Data_TLAST_x32  ;
(* KEEP = "TRUE" *)wire   [ 4-1:0] wUDP_Data_TKEEP_x32  ;
(* KEEP = "TRUE" *)wire   [32-1:0] wUDP_Data_TDATA_x32;


(* keep = "true" *) reg [48-1:0] wMAC_LOCAL_ADDR = 48'hCC28AA040506;
(* keep = "true" *) reg [32-1:0] wIP4_LOCAL_ADDR = {8'd192,8'd168,8'd4,8'd49}; 
(* keep = "true" *) reg [16-1:0] wUDP_LOCAL_PORT = 16'd9999;  


(* keep = "true" *) wire [48-1:0] wMAC_REMOTE_ADDR;
(* keep = "true" *) wire [32-1:0] wIP4_REMOTE_ADDR; 
(* keep = "true" *) wire [16-1:0] wUDP_REMOTE_PORT;  


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
 UDP_Offloading_Engine_Wrapper
#(
.RX_CLK_BUFF_SCH_TYPE(3)
)UDP_Offloading_Engine_Wrapper_inst
(
.EthClk125                  (wEthClk125),
.EthClk125_90               (wEthClk125_90),

.RGMII_RXC                  (RGMII_RXC),
.RGMII_RX_CTL               (RGMII_RX_CTL),
.RGMII_RXD                  (RGMII_RXD),

.RGMII_TXC                  (RGMII_TXC),
.RGMII_TX_CTL               (RGMII_TX_CTL),
.RGMII_TXD                  (RGMII_TXD),

.MAC_LOCAL_ADDR_IN          (wMAC_LOCAL_ADDR),
.IP4_LOCAL_ADDR_IN          (wIP4_LOCAL_ADDR),
.UDP_LOCAL_PORT_IN          (wUDP_LOCAL_PORT),

.MAC_REMOTE_ADDR_IN         (wMAC_REMOTE_ADDR),
.IP4_REMOTE_ADDR_IN         (wIP4_REMOTE_ADDR),
.UDP_REMOTE_PORT_IN         (wUDP_REMOTE_PORT),

.MAC_REMOTE_ADDR_OUT        (wMAC_REMOTE_ADDR),
.IP4_REMOTE_ADDR_OUT        (wIP4_REMOTE_ADDR),
.UDP_REMOTE_PORT_OUT        (wUDP_REMOTE_PORT),

.UDP_Data_Source_CLK        (wRGMII_RXC),
.UDP_Data_Source_TFIRST     (wUDP_Data_TFIRST    ),
.UDP_Data_Source_TVALID     (wUDP_Data_TVALID    ),
.UDP_Data_Source_TERROR     (wUDP_Data_TERROR    ),
.UDP_Data_Source_TLAST      (wUDP_Data_TLAST     ),
.UDP_Data_Source_TDATA      (wUDP_Data_TDATA     ),

.Sink_CLK                   (wRGMII_RXC            ),
.Sink_TRDY                  (),
.Sink_TVALID                (wUDP_Data_TVALID_x32),
.Sink_TLAST                 (wUDP_Data_TLAST_x32 ),
.Sink_TKEEP                 (wUDP_Data_TKEEP_x32 ),
.Sink_TDATA                 (wUDP_Data_TDATA_x32 )
);


(* KEEP_HIERARCHY = "TRUE" *)
AXIS_Width_Up_Converter
#(
. BIT_WIDTH             (8),
. N                     (4),
. BIG_ENDIAN            (0),         
. TFIRST_ReSTORE        (0) 
) AXISx8_To_AXISx32_Width_Up_Converter_inst
(
            
. CLK                       (Sink_CLK                       ),
. TFIRST                    (wUDP_Data_TFIRST               ),            
. TDATA                     (wUDP_Data_TDATA                ),
. TVALID                    (wUDP_Data_TVALID               ),
. TERROR                    (wUDP_Data_TERROR               ),
. TLAST                     (wUDP_Data_TLAST                ),
 
//. TFIRST_OUT                (wUDP_Data_TFIRST_x32           ),
. TVALID_OUT                (wUDP_Data_TVALID_x32           ),
//. TERROR_OUT                (wUDP_Data_TERROR_x32           ), 
. TLAST_OUT                 (wUDP_Data_TLAST_x32            ),
. TKEEP_OUT                 (wUDP_Data_TKEEP_x32            ),
. TDATA_OUT                 (wUDP_Data_TDATA_x32            )
 );  

endmodule
