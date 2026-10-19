`timescale 1ns / 1ps

module Zynq_GMII_MII_2_RGMII_Adapter
#(
parameter RX_ARCH = "DEFAULT_LOGIC" ,
parameter TX_ARCH = "DEFAULT_LOGIC" ,
parameter MB_ARCH = "DEFAULT_LOGIC" ,
parameter RX_CLK_BUFF_SCH_TYPE = 0  ,
parameter RGMII_TXC_FRONT_POSITION = "EDGE_ALIGNED",        // EDGE_ALIGNED , CENTER_ALIGNED
parameter RGMII_TXD_REFERENCE_CLK  = "REFERENCE_PHY_RXC",   // REFERENCE_PHY_RXC, REFERENCE_125MHz
parameter RGMII_TXC_REFERENCE_CLK  = "REFERENCE_PHY_RXC"    // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz 
)
(
// Clocks to PS 
output wire           GMII_TXCLK             ,
output wire           GMII_RXCLK             ,
output wire           RGMII_RXC_OUT          ,

output  wire          RGMII_LINK_UP          ,               // PHY InBand Status. Link is Up.
output  wire          RGMII_DUPLEX           ,               // PHY InBand Status. Duplex is enabled.
output  wire  [2-1:0] RGMII_SPEED            ,               // PHY InBand Status. Ethernet PHY speed.

input   wire          RGMII_TXC_REFERENCE    ,               // Reference CLK for RGMII TXC signal
input   wire          RGMII_TXD_REFERENCE    ,               // Reference CLK for RGMII TXD signal

input  wire           RGMII_RXC              ,
input  wire           RGMII_RX_CTL           ,
input  wire [4-1:0]   RGMII_RXD              ,

output wire           RGMII_TXC              ,
output wire           RGMII_TX_CTL           ,
output wire [4-1:0]   RGMII_TXD              ,

input wire            GMII_TX_EN             ,
input wire            GMII_TXERR             ,
input wire [8-1:0]    GMII_TXD               ,   

output  wire          GMII_RXDV              ,
output  wire          GMII_RXERR             ,
output  wire [8-1:0]  GMII_RXD               ,

output  wire          GMII_COL               ,
output  wire          GMII_CRS

);
 

wire                    wRGMII_RX_dCLK;
wire                    wRGMII_RX_dVAL;
wire                    wRGMII_RX_dErr;
wire                    wRGMII_RX_dSoF;
wire                    wRGMII_RX_dEoF;
wire [7:0]              wRGMII_RX_DATA;

wire                    wRGMII_TX_RDY;
wire                    wRGMII_TX_dVAL;
wire                    wRGMII_TX_dERR;
wire                    wRGMII_TX_dEoF;
wire [7:0]              wRGMII_TX_DATA;

wire                    wRGMII_FIFO_TX_dVAL;
wire                    wRGMII_FIFO_TX_dErr;
wire                    wRGMII_FIFO_TX_dEoF;
wire                    wRGMII_FIFO_TX_dRDY;
wire [7:0]              wRGMII_FIFO_TX_DATA;

 
(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_RGMII_BRIDGE 
#(
.RX_ARCH                    (RX_ARCH					),             
.OVER_SAMPLING              ("NO"                       ),
.OVER_SAMPLING_SHIFT        (0                          ),
.TX_ARCH                    (TX_ARCH					),
.RX_CLK_BUFF_SCH_TYPE       (RX_CLK_BUFF_SCH_TYPE	    ),
.RGMII_TXC_FRONT_POSITION   (RGMII_TXC_FRONT_POSITION   ),      // EDGE_ALIGNED , CENTER_ALIGNED
.RGMII_TXD_REFERENCE_CLK    (RGMII_TXD_REFERENCE_CLK    ),      // REFERENCE_PHY_RXC, REFERENCE_125MHz,     
.RGMII_TXC_REFERENCE_CLK    (RGMII_TXC_REFERENCE_CLK    )       // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz,

) AXISx8_RGMII_BRIDGE_INST
(
.RGMII_LINK_UP              (RGMII_LINK_UP          ),
.RGMII_DUPLEX               (RGMII_DUPLEX           ),
.RGMII_SPEED                (RGMII_SPEED            ),

.CLK625MHZ                  (0                      ),
.RGMII_RXC                  (RGMII_RXC              ),
.RGMII_RX_CTL               (RGMII_RX_CTL           ),
.RGMII_RXD                  (RGMII_RXD              ),
.RGMII_TXC                  (RGMII_TXC              ),
.RGMII_TX_CTL               (RGMII_TX_CTL           ),
.RGMII_TXD                  (RGMII_TXD              ),

.RGMII_TxClockSync          (0),
.RGMII_TXC_REFERENCE        (RGMII_TXC_REFERENCE    ),
.RGMII_TXD_REFERENCE        (RGMII_TXD_REFERENCE    ),

.Sink_PHY_TVALID            (wRGMII_FIFO_TX_dVAL    ),
.Sink_PHY_TERROR            (wRGMII_FIFO_TX_dErr    ),
.Sink_PHY_TREADY            (wRGMII_FIFO_TX_dRDY    ),
.Sink_PHY_TDATA             (wRGMII_FIFO_TX_DATA    ),

.Source_PHY_CLK             (wRGMII_RX_dCLK         ),
.Source_PHY_TVALID          (wRGMII_RX_dVAL         ),
.Source_PHY_TERROR          (wRGMII_RX_dErr         ),
.Source_PHY_TFIRST          (wRGMII_RX_dSoF         ),
.Source_PHY_TLAST           (wRGMII_RX_dEoF         ),
.Source_PHY_TDATA           (wRGMII_RX_DATA         )
);



(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_Clock_Crossing_FIFO 
#(
.MB_ARCH (MB_ARCH )
)AXISx8_Clock_Crossing_FIFO_INST 
(
  .s_axis_aresetn                   (1'b1                                       ),  // input wire s_axis_aresetn
  .s_axis_aclk                      (wRGMII_RX_dCLK                             ),        // input wire s_axis_aclk
  .s_axis_tvalid                    (wRGMII_TX_dVAL                             ),    // input wire s_axis_tvalid
  .s_axis_tready                    (1'b1                                       ),    // output wire s_axis_tready
  .s_axis_tdata                     (wRGMII_TX_DATA                             ),      // input wire [7 : 0] s_axis_tdata
  .s_axis_tlast                     (wRGMII_TX_dEoF                             ),      // input wire s_axis_tlast
  .s_axis_tuser                     (wRGMII_TX_dERR                             ),      // input wire [0 : 0] s_axis_tuser
  
  .m_axis_aclk                      ( RGMII_TXC_REFERENCE                       ),        // input wire m_axis_aclk
  .m_axis_tvalid                    (wRGMII_FIFO_TX_dVAL                        ),    // output wire m_axis_tvalid
  .m_axis_tready                    (wRGMII_FIFO_TX_dRDY                        ),    // input wire m_axis_tready
  .m_axis_tdata                     (wRGMII_FIFO_TX_DATA                        ),      // output wire [7 : 0] m_axis_tdata
  .m_axis_tlast                     (wRGMII_FIFO_TX_dEoF                        ),      // output wire m_axis_tlast
  .m_axis_tuser                     (wRGMII_FIFO_TX_dErr                        )      // output wire [0 : 0] m_axis_tuser
  
);


(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_GMII_MII_BRIDGE      AXISx8_GMII_MII_BRIDGE_inst
(
.GMII_MII_MODE_SELECT   (RGMII_SPEED[1] ),         

.GMII_RXCLK             (wRGMII_RX_dCLK ),
.GMII_RXDV              (GMII_TX_EN     ),
.GMII_RXERR             (GMII_TXERR     ),
.GMII_RXD               (GMII_TXD       ),
.GMII_RX_COL            (0              ),
.GMII_RX_CRS            (0              ),

.GMII_TXCLK             (wRGMII_RX_dCLK ),
.GMII_TX_EN             (GMII_RXDV      ),
.GMII_TXERR             (GMII_RXERR     ),
.GMII_TXD               (GMII_RXD       ),   
.GMII_TX_COL            (GMII_COL       ),
.GMII_TX_CRS            (GMII_CRS       ),

.Sink_TREADY            (),
.Sink_TVALID            (wRGMII_RX_dVAL ),
.Sink_TERROR            (wRGMII_RX_dErr ),
.Sink_TFIRST            (wRGMII_RX_dSoF ),
.Sink_TLAST             (wRGMII_RX_dEoF ),
.Sink_TDATA             (wRGMII_RX_DATA ),
.Sink_TUSER             (0              ),

.Source_TVALID          (wRGMII_TX_dVAL ),
.Source_TERROR          (wRGMII_TX_dERR ),
.Source_TFIRST          (0              ),
.Source_TLAST           (wRGMII_TX_dEoF ),
.Source_TDATA           (wRGMII_TX_DATA )
);

assign GMII_TXCLK       =   wRGMII_RX_dCLK;
assign GMII_RXCLK       =   wRGMII_RX_dCLK;

assign RGMII_RXC_OUT    =   wRGMII_RX_dCLK;

 

endmodule