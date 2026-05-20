`timescale 1ns / 1ps

module UDP_Offloading_Engine_Wrapper
(
input CLK,

input  wire          Eth_RX_CTL,
input  wire          Eth_RXC,
input  wire [4-1:0]  Eth_RXD,
output wire          Eth_TX_CTL,
output wire          Eth_TXC,
output wire [4-1:0]  Eth_TXD,

output wire  		 UDP_Data_Source_CLK,
output wire  		 UDP_Data_Source_TFIRST,
output wire 		 UDP_Data_Source_TVALID,
output wire 		 UDP_Data_Source_TERROR,
output wire			 UDP_Data_Source_TLAST ,
output wire [ 8-1:0] UDP_Data_Source_TDATA ,

input  wire [48-1:0] MAC_LOCAL_ADDR_IN  ,
input  wire [32-1:0] IP4_LOCAL_ADDR_IN  ,
input  wire [16-1:0] UDP_LOCAL_PORT_IN  ,

input  wire          Sink_CLK,
output wire          Sink_TRDY  ,
input  wire          Sink_TVALID,
input  wire          Sink_TLAST,
input  wire [ 4-1:0] Sink_TKEEP,
input  wire [32-1:0] Sink_TDATA
);

wire                    wEthClk125;
wire                    wEthClk125_90;
 
wire                    wRGMII_RX_dCLK;
wire                    wRGMII_RX_dVAL;
wire                    wRGMII_RX_dErr;
wire                    wRGMII_RX_dSoF;
wire                    wRGMII_RX_dEoF;
wire [7:0]              wRGMII_RX_DATA;


wire                    wRGMII_FIFO_RX_dCLK;
wire                    wRGMII_FIFO_RX_dVAL;
wire                    wRGMII_FIFO_RX_dErr;
wire                    wRGMII_FIFO_RX_dSoF;
wire                    wRGMII_FIFO_RX_dEoF;
wire [7:0]              wRGMII_FIFO_RX_DATA;

wire                    wRGMII_TX_RDY;
wire                    wRGMII_TX_dVAL;
wire                    wRGMII_TX_dERR;
wire                    wRGMII_TX_dEoF;
wire [7:0]              wRGMII_TX_DATA;

wire [1*1-1:0]	        wMAC_TxFrameBody_TRDY;
wire [1*1-1:0]	        wMAC_TxFrameBody_TVALID;
wire [1*1-1:0]	        wMAC_TxFrameBody_TLAST;
wire [8*1-1:0]          wMAC_TxFrameBody_TDATA;


(* keep = "true" *) wire [48-1:0] wMAC_REMOTE_ADDR ;
(* keep = "true" *) wire [32-1:0] wIPv4_REMOTE_ADDR ;
(* keep = "true" *) wire [16-1:0] wUDP_REMOTE_PORT ;
 
 
 (* KEEP_HIERARCHY = "TRUE" *)
 Sys_Clk_PLL  Sys_Clk_PLL_inst
 (
  // Clock out ports
  .clk_out1 (wEthClk125),
  .clk_out2 (wEthClk125_90),
  // Status and control signals
  .locked   (),
 // Clock in ports
  .clk_in1 (CLK)
 );
 
 
(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_RGMII_BRIDGE 
#(
.RX_ARCH("XLX_SERIES7"),                              // "XLX_SERIES7", "DEFAULT_LOGIC"
//.RX_ARCH("DEFAULT_LOGIC"),                                // "XLX_SERIES7", "DEFAULT_LOGIC"
.TX_ARCH("XLX_SERIES7"),
.RGMII_TXC_FRONT_POSITION ("CENTER_ALIGNED"),           // EDGE_ALIGNED , CENTER_ALIGNED
.RGMII_TXD_REFERENCE_CLK  ("REFERENCE_125MHz"),         // REFERENCE_PHY_RXC, REFERENCE_125MHz,     
.RGMII_TXC_REFERENCE_CLK  ("REFERENCE_125MHz_90")       // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz,
) AXISx8_RGMII_BRIDGE_INST
(
.RGMII_LINK_UP              (),
.RGMII_DUPLEX               (),
.RGMII_SPEED                (),

.RGMII_RXC                  (Eth_RXC),
.RGMII_RX_CTL               (Eth_RX_CTL),
.RGMII_RXD                  (Eth_RXD),
.RGMII_TXC                  (Eth_TXC),
.RGMII_TX_CTL               (Eth_TX_CTL),
.RGMII_TXD                  (Eth_TXD),

.RGMII_TxClockSync          (0),
.RGMII_TXC_REFERENCE        (wEthClk125_90 ),
.RGMII_TXD_REFERENCE        (wEthClk125    ),

.Sink_PHY_TVALID            (wRGMII_TX_dVAL),
.Sink_PHY_TERROR            (wRGMII_TX_dERR),
.Sink_PHY_TREADY            (wRGMII_TX_RDY ),
.Sink_PHY_TDATA             (wRGMII_TX_DATA),

.Source_PHY_CLK             (wRGMII_RX_dCLK),
.Source_PHY_TVALID          (wRGMII_RX_dVAL),
.Source_PHY_TERROR          (wRGMII_RX_dErr),
.Source_PHY_TFIRST          (wRGMII_RX_dSoF),
.Source_PHY_TLAST           (wRGMII_RX_dEoF),
.Source_PHY_TDATA           (wRGMII_RX_DATA)
);


(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_Clock_Crossing_FIFO AXISx8_Clock_Crossing_FIFO_INST 
(
  .s_axis_aresetn                   (1'b1                                       ),  // input wire s_axis_aresetn
  .s_axis_aclk                      (wRGMII_RX_dCLK                             ),        // input wire s_axis_aclk
  .s_axis_tvalid                    (wRGMII_RX_dVAL                             ),    // input wire s_axis_tvalid
  .s_axis_tready                    (                                           ),    // output wire s_axis_tready
  .s_axis_tdata                     (wRGMII_RX_DATA                             ),      // input wire [7 : 0] s_axis_tdata
  .s_axis_tlast                     (wRGMII_RX_dEoF                             ),      // input wire s_axis_tlast
  .s_axis_tuser                     (wRGMII_RX_dErr                             ),      // input wire [0 : 0] s_axis_tuser
  
  .m_axis_aclk                      (wEthClk125                                 ),        // input wire m_axis_aclk
  .m_axis_tvalid                    (wRGMII_FIFO_RX_dVAL                        ),    // output wire m_axis_tvalid
  .m_axis_tready                    (1'b1                                       ),    // input wire m_axis_tready
  .m_axis_tdata                     (wRGMII_FIFO_RX_DATA                        ),      // output wire [7 : 0] m_axis_tdata
  .m_axis_tlast                     (wRGMII_FIFO_RX_dEoF                        ),      // output wire m_axis_tlast
  .m_axis_tuser                     (wRGMII_FIFO_RX_dErr                        )      // output wire [0 : 0] m_axis_tuser
  

);

(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_UDP_Offloading_Engine   
#(
.TxPortCount    (  1  ),
.Has_ARP_Proc   ("YES"),                        // "YES" or "NO"   
.HasICMP_PING   ("YES")                         // "YES" or "NO"
)
 AXISx8_UDP_Offloading_Engine_inst
 (
.Sink_PHY_RX_CLK            (wEthClk125         ),
.Sink_PHY_RX_TVALID         (wRGMII_FIFO_RX_dVAL),
.Sink_PHY_RX_TERROR         (wRGMII_FIFO_RX_dErr),
.Sink_PHY_RX_TLAST          (wRGMII_FIFO_RX_dEoF),
.Sink_PHY_RX_TDATA          (wRGMII_FIFO_RX_DATA),

.Source_TFIRST              (UDP_Data_Source_TFIRST),
.Source_TVALID              (UDP_Data_Source_TVALID),
.Source_TERROR              (UDP_Data_Source_TERROR),
.Source_TLAST               (UDP_Data_Source_TLAST),
.Source_TDATA               (UDP_Data_Source_TDATA),

.MAC_LOCAL_ADDR_IN          (MAC_LOCAL_ADDR_IN  ),
.IP4_LOCAL_ADDR_IN          (IP4_LOCAL_ADDR_IN  ),
.UDP_LOCAL_PORT_IN          (UDP_LOCAL_PORT_IN  ),

.MAC_REMOTE_ADDR_OUT        (wMAC_REMOTE_ADDR),
.IP4_REMOTE_ADDR_OUT        (wIPv4_REMOTE_ADDR),
.UDP_REMOTE_PORT_OUT        (wUDP_REMOTE_PORT),
	
/////////////////////////////////////////////////////////////////////////////////////
//Tx Interface

.Sink_TRDY                  (wMAC_TxFrameBody_TRDY),
.Sink_TVALID                (wMAC_TxFrameBody_TVALID),
.Sink_TERROR                (1'b0),
.Sink_TLAST                 (wMAC_TxFrameBody_TLAST),
.Sink_TDATA                 (wMAC_TxFrameBody_TDATA),

.Source_PHY_TX_CLK          (wEthClk125),	
.Source_PHY_TX_TRDY         (wRGMII_TX_RDY),
.Source_PHY_TX_TVALID       (wRGMII_TX_dVAL),
.Source_PHY_TX_TERROR       (wRGMII_TX_dERR),
.Source_PHY_TX_TLAST        (wRGMII_TX_dEoF),
.Source_PHY_TX_TDATA        (wRGMII_TX_DATA)
);

assign UDP_Data_Source_CLK = wEthClk125;

(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_UDP_Framing_AXISx32_Sink    
#(
    .ARCH     ( "XLX_ULTRASCALE" ),
    .DROP_IF_OVERFLOW   ( "YES"  ), // "YES" or "NO"
    .ETHERNET_MTU       ( 1500   ),
    .BUFFER_COUNT_1K    ( 4      )  
) 
AXISx8_UDP_Framing_AXISx32_Sink_inst
(      
. Sink_CLK              (Sink_CLK                   ),
. Sink_TRDY             (Sink_TRDY                  ),
. Sink_TVALID           (Sink_TVALID                ),
. Sink_TLAST            (Sink_TLAST                 ),
. Sink_TKEEP            (Sink_TKEEP                 ),
. Sink_TDATA            (Sink_TDATA                 ),
 
. UDP_LOCAL_PORT_IN     (UDP_LOCAL_PORT_IN          ),
. UDP_REMOTE_PORT_IN    (wUDP_REMOTE_PORT           ),
  
. IP4_LOCAL_ADDR_IN     (IP4_LOCAL_ADDR_IN          ),
. IP4_REMOTE_ADDR_IN    (wIPv4_REMOTE_ADDR          ),

. MAC_LOCAL_ADDR_IN     (MAC_LOCAL_ADDR_IN          ),  
. MAC_REMOTE_ADDR_IN    (wMAC_REMOTE_ADDR           ),

. Source_CLK            (wEthClk125                 ),    
. Source_TRDY           (wMAC_TxFrameBody_TRDY      ),
. Source_TVALID         (wMAC_TxFrameBody_TVALID    ),
. Source_TLAST          (wMAC_TxFrameBody_TLAST     ),
. Source_TDATA          (wMAC_TxFrameBody_TDATA     )       
);


endmodule
