`timescale 1ns / 1ps


module RGMII_TB
    (

    );
    
    
reg         CLK125Mhz=1;      //  clock (125 MHz)
reg         CLK625Mhz=1;      //  clock (125 MHz)

always #4.01  CLK125Mhz   = ~ CLK125Mhz;
//always #3.99  CLK125Mhz   = ~ CLK125Mhz;
always #0.80  CLK625Mhz   = ~ CLK625Mhz;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    reg [7:0] ARP_TestFrame_memory [0:63];
    initial 
    begin
    $readmemh("../../../../../sim/EthernetTestFrame_memory_ARP.txt" , ARP_TestFrame_memory);
    end


    integer i =1;

    reg [12:0]  ARP_TestFrameAdress=8000;

    reg [7:0]   ARP_Test_TData=0;
    reg         ARP_Test_TValid=0;
    reg         ARP_Test_TLast=0;
    wire        ARP_Test_TRDY;




    always @(posedge CLK125Mhz)
    begin
    if (ARP_Test_TRDY)
    begin
   // if (i==250) i<=0; else i<=i+1;
    if (i==850) i<=0; else i<=i+1;
    
        if (i==0) ARP_TestFrameAdress<=0;
            else if (ARP_TestFrameAdress==8000) ARP_TestFrameAdress<=ARP_TestFrameAdress;
                    else ARP_TestFrameAdress<=ARP_TestFrameAdress+1'b1;
        
    end 
        if (ARP_TestFrameAdress<(60)) ARP_Test_TData <= ARP_TestFrame_memory [ARP_TestFrameAdress]; else ARP_Test_TData <= 0;
        ARP_Test_TValid<= ARP_TestFrameAdress<(60);
        ARP_Test_TLast <= ARP_TestFrameAdress==((60)-1);
    end

/////////// ADD Preambule and FCS

wire           wARP_PhysicalFrame_TRDY;
wire           wARP_PhysicalFrame_TVALID;
wire           wARP_PhysicalFrame_TLAST;
wire  [8-1:0]  wARP_PhysicalFrame_TDATA; 
    
    

(* KEEP_HIERARCHY = "TRUE" *)
MAC_FrameBody2EthernetPhysicalFrameConverter_x8 MAC_FrameBody2EthernetPhysicalFrameConverter_x8_inst
(
.clk                            (CLK125Mhz),
.MAC_FrameBody_TRDY             (ARP_Test_TRDY),
.MAC_FrameBody_TVALID           (ARP_Test_TValid),
.MAC_FrameBody_TERROR           (0),
.MAC_FrameBody_TLAST            (ARP_Test_TLast),
.MAC_FrameBody_TDATA            (ARP_Test_TData),

.EthernetPhysicalFrame_TRDY     (wARP_PhysicalFrame_TRDY),
.EthernetPhysicalFrame_TVALID   (wARP_PhysicalFrame_TVALID),
.EthernetPhysicalFrame_TERROR   (),
.EthernetPhysicalFrame_TLAST    (wARP_PhysicalFrame_TLAST),
.EthernetPhysicalFrame_TDATA    (wARP_PhysicalFrame_TDATA)
);


/////////// Send RGMII DDR signal    
wire          wARP_RGMII_TXC;
wire          wARP_RGMII_TX_CTL;
wire [4-1:0]  wARP_RGMII_TXD;

(* KEEP_HIERARCHY = "TRUE" *)
RGMII_TX_PHY 
#(
.ARCH("XLX_SERIES7"),
.RGMII_InBandStatusEnabled(1),
.RGMII_TXC_FRONT_POSITION("EDGE_ALIGNED"       ),
.RGMII_TXC_REFERENCE_CLK("REFERENCE_125MHz"    ),
.RGMII_TXD_REFERENCE_CLK("REFERENCE_125MHz"    )
)  
RGMII_TX_PHY_INST
(
.RGMII_LINK_UP              (1                          ),
.RGMII_SPEED                (1                          ),

.RGMII_TxClockSync          (0                          ),

.RGMII_TXC_REFERENCE        (CLK125Mhz                  ),
.RGMII_TXD_REFERENCE        (CLK125Mhz                  ),
.RGMII_TX_VAL               (wARP_PhysicalFrame_TVALID  ),
.RGMII_TX_Err               (0                          ),
.RGMII_TX_DAT               (wARP_PhysicalFrame_TDATA   ),
.RGMII_TX_RDY               (wARP_PhysicalFrame_TRDY    ),

.RGMII_TXC                  (wARP_RGMII_TXC             ),
.RGMII_TX_CTL               (wARP_RGMII_TX_CTL          ),
.RGMII_TXD                  (wARP_RGMII_TXD             )
);

wire wARP_RGMII_TXC_DLY;

assign #0.0 wARP_RGMII_TXC_DLY = wARP_RGMII_TXC ; 

(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_RGMII_BRIDGE 
#(
.RX_ARCH                    ("XLX_SERIES7"),             // "XLX_SERIES7", "DEFAULT_LOGIC"
//.RX_ARCH("DEFAULT_LOGIC"),                             // "XLX_SERIES7", "DEFAULT_LOGIC"
.TX_ARCH                    ("XLX_SERIES7"),
.RX_CLK_BUFF_SCH_TYPE       (1),
.OVER_SAMPLING              ("YES"),
//.OVER_SAMPLING              ("NO"),
.RGMII_TXC_FRONT_POSITION   ("CENTER_ALIGNED"),           // EDGE_ALIGNED , CENTER_ALIGNED
.RGMII_TXD_REFERENCE_CLK    ("REFERENCE_125MHz"),         // REFERENCE_PHY_RXC, REFERENCE_125MHz,     
.RGMII_TXC_REFERENCE_CLK    ("REFERENCE_125MHz_90")       // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz,
) AXISx8_RGMII_BRIDGE_INST
(
.CLK625MHZ                  (CLK625Mhz),

.RGMII_LINK_UP              (),
.RGMII_DUPLEX               (),
.RGMII_SPEED                (),

.RGMII_RXC                  (wARP_RGMII_TXC_DLY),
.RGMII_RX_CTL               (wARP_RGMII_TX_CTL),
.RGMII_RXD                  (wARP_RGMII_TXD),
.RGMII_TXC                  (),
.RGMII_TX_CTL               (),
.RGMII_TXD                  (),

.RGMII_TxClockSync          (0),
.RGMII_TXC_REFERENCE        (CLK125Mhz    ),
.RGMII_TXD_REFERENCE        (CLK125Mhz    ),

.Sink_PHY_TVALID            (0),
.Sink_PHY_TERROR            (0),
.Sink_PHY_TREADY            ( ),
.Sink_PHY_TDATA             (0),

.Source_PHY_CLK             (),
.Source_PHY_TVALID          (),
.Source_PHY_TERROR          (),
.Source_PHY_TFIRST          (),
.Source_PHY_TLAST           (),
.Source_PHY_TDATA           ()
);




   
endmodule
