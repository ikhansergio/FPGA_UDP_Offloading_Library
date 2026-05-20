`timescale 1ns / 1ps

module Top
(
input CLK                           ,


input  wire          Eth_RXC        ,
input  wire          Eth_RX_CTL     ,
input  wire [4-1:0]  Eth_RXD        ,

output wire          Eth_TXC        ,
output wire          Eth_TX_CTL     ,
output wire [4-1:0]  Eth_TXD        ,

output reg EtheReset =0             // Invered on PCB. EtheReset == 1 -> PHY is reseted

 );
 
wire wEth_RXC;
 
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


 wire wMCK;
 
 (* KEEP_HIERARCHY = "TRUE" *)
 UDP_Offloading_Engine_Wrapper UDP_Offloading_Engine_Wrapper_inst
(
.CLK                        (CLK),

.Eth_RX_CTL                 (Eth_RX_CTL),
.Eth_RXC                    (Eth_RXC),
.Eth_RXD                    (Eth_RXD),
.Eth_TX_CTL                 (Eth_TX_CTL),
.Eth_TXC                    (Eth_TXC),
.Eth_TXD                    (Eth_TXD),

.MAC_LOCAL_ADDR_IN          (wMAC_LOCAL_ADDR),
.IP4_LOCAL_ADDR_IN          (wIP4_LOCAL_ADDR),
.UDP_LOCAL_PORT_IN          (wUDP_LOCAL_PORT),

.UDP_Data_Source_CLK        (wEth_RXC),
.UDP_Data_Source_TFIRST     (wUDP_Data_TFIRST    ),
.UDP_Data_Source_TVALID     (wUDP_Data_TVALID    ),
.UDP_Data_Source_TERROR     (wUDP_Data_TERROR    ),
.UDP_Data_Source_TLAST      (wUDP_Data_TLAST     ),
.UDP_Data_Source_TDATA      (wUDP_Data_TDATA     ),

.Sink_CLK                   (wEth_RXC            ),
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
