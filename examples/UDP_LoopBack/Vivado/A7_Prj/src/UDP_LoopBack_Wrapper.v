`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//MIT License

//Copyright (c) 2026 Sergio Batu    ikhan.sergio@gmail.com

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
////////////////////////////////////////////////////////////////////////////////


// ARCH - Supported architectures:
// "XLX_ULTRASCALE",   - Xilinx ULTRASCALE FPGAs
// "XLX_SERIES7",      - Xilinx 7 Series FPGAs
// "ALT_Cyclone10LP",  - Altera Cyclone10LP Series FPGAs
// "DEFAULT_LOGIC",    - implementation on FPGA fabric


module UDP_LoopBack_Wrapper
#(
parameter RX_ARCH = "DEFAULT_LOGIC" ,
parameter TX_ARCH = "DEFAULT_LOGIC" ,
parameter MB_ARCH = "DEFAULT_LOGIC" ,
parameter RX_CLK_BUFF_SCH_TYPE  = 0 ,
parameter OVER_SAMPLING = "NO"      ,                       // "YES" or "NO"
parameter OVER_SAMPLING_SHIFT  = 0  
)
(
input  wire          CLK625MHZ,
input  wire          EthClk125,
input  wire          EthClk125_90,

input  wire          RGMII_RXC,
input  wire          RGMII_RX_CTL,
input  wire [4-1:0]  RGMII_RXD,

output wire          RGMII_TXC,
output wire          RGMII_TX_CTL,
output wire [4-1:0]  RGMII_TXD,

input  wire [48-1:0] MAC_LOCAL_ADDR_IN  ,
input  wire [32-1:0] IP4_LOCAL_ADDR_IN  ,
input  wire [16-1:0] UDP_LOCAL_PORT_TG_IN, 
input  wire [16-1:0] UDP_LOCAL_PORT_LB_IN 

);

wire wUDP_CLK;
 
(* KEEP = "TRUE" *)wire	[2*1-1:0] wUDP_Data_TFIRST;
(* KEEP = "TRUE" *)wire	[2*1-1:0] wUDP_Data_TVALID;
(* KEEP = "TRUE" *)wire	[2*1-1:0] wUDP_Data_TERROR;
(* KEEP = "TRUE" *)wire	[2*1-1:0] wUDP_Data_TLAST ;
(* KEEP = "TRUE" *)wire [2*8-1:0] wUDP_Data_TDATA ;
 
//(* KEEP = "TRUE" *)wire            wUDP_Data_TFIRST_x32 ;
//(* KEEP = "TRUE" *)wire            wUDP_Data_TERROR_x32 ;
(* KEEP = "TRUE" *)wire            wUDP_Data_TVALID_x32 ;
(* KEEP = "TRUE" *)wire            wUDP_Data_TLAST_x32  ;
(* KEEP = "TRUE" *)wire   [ 4-1:0] wUDP_Data_TKEEP_x32  ;
(* KEEP = "TRUE" *)wire   [32-1:0] wUDP_Data_TDATA_x32;

(* keep = "true" *) wire [2*16-1:0] wUDP_LOCAL_PORT_IN;
assign wUDP_LOCAL_PORT_IN = {UDP_LOCAL_PORT_LB_IN,UDP_LOCAL_PORT_TG_IN}; 

(* keep = "true" *) wire [2*48-1:0] wMAC_REMOTE_ADDR;
(* keep = "true" *) wire [2*32-1:0] wIP4_REMOTE_ADDR; 
(* keep = "true" *) wire [2*16-1:0] wUDP_REMOTE_PORT;  

(* keep = "true" *) wire            wTG_Start_Pulse;
(* keep = "true" *) wire  [32-1:0]  wTG_PacketCount;
(* keep = "true" *) wire  [16-1:0]  wTG_PacketSize;
(* keep = "true" *) wire  [16-1:0]  wTG_PacketGap;


 (* KEEP_HIERARCHY = "TRUE" *)
 UDP_Offloading_Engine_Wrapper
#(
.RX_ARCH (RX_ARCH),
.TX_ARCH (TX_ARCH),
.MB_ARCH (MB_ARCH),
.RX_CLK_BUFF_SCH_TYPE(RX_CLK_BUFF_SCH_TYPE),
.OVER_SAMPLING(OVER_SAMPLING),
.OVER_SAMPLING_SHIFT(OVER_SAMPLING_SHIFT)
)UDP_Offloading_Engine_Wrapper_inst
(
.CLK625MHZ                  (CLK625MHZ),
.EthClk125                  (EthClk125),
.EthClk125_90               (EthClk125_90),

.TG_Start_Pulse             (wTG_Start_Pulse),
.TG_PacketCount             (wTG_PacketCount),
.TG_PacketSize              (wTG_PacketSize), 
.TG_PacketGap               (wTG_PacketGap),    

.RGMII_RXC                  (RGMII_RXC),
.RGMII_RX_CTL               (RGMII_RX_CTL),
.RGMII_RXD                  (RGMII_RXD),

.RGMII_TXC                  (RGMII_TXC),
.RGMII_TX_CTL               (RGMII_TX_CTL),
.RGMII_TXD                  (RGMII_TXD),

.MAC_LOCAL_ADDR_IN          ( MAC_LOCAL_ADDR_IN),
.IP4_LOCAL_ADDR_IN          ( IP4_LOCAL_ADDR_IN),
.UDP_LOCAL_PORT_IN          (wUDP_LOCAL_PORT_IN),

.MAC_REMOTE_ADDR_IN         (wMAC_REMOTE_ADDR),
.IP4_REMOTE_ADDR_IN         (wIP4_REMOTE_ADDR),
.UDP_REMOTE_PORT_IN         (wUDP_REMOTE_PORT),

.MAC_REMOTE_ADDR_OUT        (wMAC_REMOTE_ADDR),
.IP4_REMOTE_ADDR_OUT        (wIP4_REMOTE_ADDR),
.UDP_REMOTE_PORT_OUT        (wUDP_REMOTE_PORT),

.UDP_Data_Source_CLK        (wUDP_CLK            ),
.UDP_Data_Source_TFIRST     (wUDP_Data_TFIRST    ),
.UDP_Data_Source_TVALID     (wUDP_Data_TVALID    ),
.UDP_Data_Source_TERROR     (wUDP_Data_TERROR    ),
.UDP_Data_Source_TLAST      (wUDP_Data_TLAST     ),
.UDP_Data_Source_TDATA      (wUDP_Data_TDATA     ),

.Sink_CLK                   (wUDP_CLK            ),
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
           
. CLK                       (wUDP_CLK                       ),
 
. TFIRST                    (wUDP_Data_TFIRST      [0]      ),   
. TVALID                    (wUDP_Data_TVALID      [0]      ),
. TERROR                    (wUDP_Data_TERROR      [0]      ),
. TLAST                     (wUDP_Data_TLAST       [0]      ),       
. TDATA                     (wUDP_Data_TDATA       [0*8 +:8]),  

//. TFIRST_OUT                (wUDP_Data_TFIRST_x32           ),
. TVALID_OUT                (wUDP_Data_TVALID_x32           ),
//. TERROR_OUT                (wUDP_Data_TERROR_x32           ), 
. TLAST_OUT                 (wUDP_Data_TLAST_x32            ),
. TKEEP_OUT                 (wUDP_Data_TKEEP_x32            ),
. TDATA_OUT                 (wUDP_Data_TDATA_x32            )
 );  
 
 (* KEEP_HIERARCHY = "TRUE" *)
AXISx8_UDP_TG_Controller    AXISx8_UDP_TG_Controller_inst
(

. CLK                       (wUDP_CLK                       ),
    
. TFIRST                    (wUDP_Data_TFIRST      [1]      ),   
. TVALID                    (wUDP_Data_TVALID      [1]      ),
. TERROR                    (wUDP_Data_TERROR      [1]      ),
. TLAST                     (wUDP_Data_TLAST       [1]      ),       
. TDATA                     (wUDP_Data_TDATA       [1*8 +:8]),  
    
.TG_Start_Pulse             (wTG_Start_Pulse),
.TG_PacketCount             (wTG_PacketCount),
.TG_PacketSize              (wTG_PacketSize),  
.TG_PacketGap               (wTG_PacketGap) 
            
);

endmodule

