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

module RGMII_TX_PHY
#(
parameter ARCH = "DEFAULT_LOGIC",
parameter RGMII_InBandStatusEnabled = 0,
parameter RGMII_TXC_FRONT_POSITION = "EDGE_ALIGNED"     ,   // EDGE_ALIGNED , CENTER_ALIGNED
parameter RGMII_TXD_REFERENCE_CLK  = "REFERENCE_PHY_RXC",   // REFERENCE_PHY_RXC, REFERENCE_125MHz,
parameter RGMII_TXC_REFERENCE_CLK  = "REFERENCE_PHY_RXC"    // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz,    
)
(
input  wire           RGMII_LINK_UP         ,
input  wire  [2-1:0]  RGMII_SPEED           ,

input  wire           RGMII_TxClockSync     ,

input   wire          RGMII_TXC_REFERENCE   ,
input   wire          RGMII_TXD_REFERENCE   ,
input   wire          RGMII_TX_VAL          ,
input   wire          RGMII_TX_Err          ,
input   wire [8-1:0]  RGMII_TX_DAT          ,
output  reg           RGMII_TX_RDY =1'b1    ,

output  wire          RGMII_TXC             ,
output  wire          RGMII_TX_CTL          ,
output  wire [4-1:0]  RGMII_TXD
);

//  Parameters validation

generate

if (RGMII_TXD_REFERENCE_CLK == "REFERENCE_PHY_RXC") 
    begin
        // If the REFERENCE_PHY_RXC clock is selected on the data line, then only the REFERENCE_PHY_RXC clock can be used to form the external TXC clock.
        if (RGMII_TXC_REFERENCE_CLK != "REFERENCE_PHY_RXC") RGMII_Error REFERENCE_PHY_RXC_ERROR ( );
    end    
else if (RGMII_TXD_REFERENCE_CLK == "REFERENCE_125MHz")           
    begin
        // If the clock REFERENCE_125MHz is selected on the data line, then to form the external TXC clock it is possible to use the clocks: REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz
        if (RGMII_TXC_REFERENCE_CLK != "REFERENCE_125MHz" ) 
            if (RGMII_TXC_REFERENCE_CLK != "REFERENCE_125MHz_90" )
                if (RGMII_TXC_REFERENCE_CLK != "REFERENCE_250MHz" ) RGMII_Error REFERENCE_125MHz_ERROR ( );                
    end 
else          
    begin
        RGMII_Error RGMII_Error_inst ( );
    end      

    if (RGMII_TXC_REFERENCE_CLK == "REFERENCE_PHY_RXC") // If the RGMII uses its own local clock, which is obtained from the PHY.
        begin
            if (RGMII_TXC_FRONT_POSITION != "EDGE_ALIGNED") RGMII_Error REFERENCE_PHY_RXC_EDGE_ALIGNED_ONLY_ALLOWED_ERROR ( );
        end
    else if (RGMII_TXC_REFERENCE_CLK == "REFERENCE_125MHz")           
        begin
            if (RGMII_TXC_FRONT_POSITION != "EDGE_ALIGNED") RGMII_Error REFERENCE_125MHz_EDGE_ALIGNED_ONLY_ALLOWED_ERROR ( );
        end       
    else if (RGMII_TXC_REFERENCE_CLK=="REFERENCE_125MHz_90")           
        begin
            if (RGMII_TXC_FRONT_POSITION != "CENTER_ALIGNED") RGMII_Error REFERENCE_125MHz_90_CENTER_ALIGNED_ONLY_ALLOWED_ERROR ( );
        end
    else if (RGMII_TXC_REFERENCE_CLK=="REFERENCE_250MHz")           
        begin
            if (RGMII_TXC_FRONT_POSITION != "EDGE_ALIGNED")
                if (RGMII_TXC_FRONT_POSITION != "CENTER_ALIGNED") RGMII_Error REFERENCE_250MHz_FORBIDEN_EDGE_POSITION_ERROR ( );
        end
    else          
    begin
        RGMII_Error RGMII_Error_inst ( );
    end
endgenerate

reg         RGMII_LINK_VAL =0;
reg [2-1:0] RGMII_SPEED_STATE=0;

// If the RGMII uses its own local clock, which is obtained from the PHY. We use wSpeedCounterThresold_Local_Clock. 
// This clock can be 125 MHz, 25 MHz, or 2.5 MHz, depending on the link speed in the PHY. 
wire [6:0] wSpeedCounterThresold_LocalClock;
assign wSpeedCounterThresold_LocalClock =   ((RGMII_SPEED_STATE[1:0]==2'd0)) ?  7'd1 :
                                                ((RGMII_SPEED_STATE[1:0]==2'd1)) ?  7'd1 :
                                                    ((RGMII_SPEED_STATE[1:0]==2'd2)) ?  7'd0 :  7'd0 ;
                                                       
// If RGMII uses an external FPGA clock. We use wSpeedCounterThresold_ExternClock. 
//  This clock can only be 125 MHz.
wire [6:0] wSpeedCounterThresold_ExternClock;
assign wSpeedCounterThresold_ExternClock =  ((RGMII_SPEED_STATE[1:0]==2'd0)) ?  7'd99 :
                                                ((RGMII_SPEED_STATE[1:0]==2'd1)) ?  7'd9 :
                                                    ((RGMII_SPEED_STATE[1:0]==2'd2)) ? 7'd0 : 7'd0 ;
                                                                                                       
// The IsExternalClkUsed parameter is used to correctly configure the dividers.
wire [6:0] wSpeedCounterThresold;
assign wSpeedCounterThresold = (RGMII_TXD_REFERENCE_CLK == "REFERENCE_PHY_RXC") ?  wSpeedCounterThresold_LocalClock : wSpeedCounterThresold_ExternClock ;
                                           
wire [6:0] wDataSwitchTresold_ExternClock ;
assign wDataSwitchTresold_ExternClock =  ((RGMII_SPEED_STATE[1:0]==2'd0)) ?  7'd49 :
                                                ((RGMII_SPEED_STATE[1:0]==2'd1)) ?  7'd4 :
                                                    ((RGMII_SPEED_STATE[1:0]==2'd2)) ? 7'd0 : 7'd0 ;
                                                    
wire [6:0] wDataSwitchTresold_LocalClock;
assign wDataSwitchTresold_LocalClock =  ((RGMII_SPEED_STATE[1:0]==2'd0)) ?  7'd0 :
                                                ((RGMII_SPEED_STATE[1:0]==2'd1)) ?  7'd0 :
                                                    ((RGMII_SPEED_STATE[1:0]==2'd2)) ? 7'd0 : 7'd0 ;
                                                    
wire [6:0] wDataSwitchTresold;
assign wDataSwitchTresold = (RGMII_TXD_REFERENCE_CLK == "REFERENCE_PHY_RXC") ?  wDataSwitchTresold_LocalClock : wDataSwitchTresold_ExternClock ;
                                                                                                                                                  
reg [6:0]   SpeedCounter=3; 
reg         SpeedCounterZeroPulse=1'b0;  

reg         DataL_H_SwitchtFlag  =1'b0;   

reg         RGMII_TX_WrEna_D=1'b0;
reg         RGMII_TX_Reset_D=1'b0;
reg         RGMII_TX_VAL_D=1'b0;
reg         RGMII_TX_Err_D=1'b0;
reg [8-1:0] RGMII_TX_DAT_D = 1'b0;

reg         RGMII_TX_VAL_Reg=1'b0;
reg         RGMII_TX_Err_Reg=1'b0;
reg [8-1:0] RGMII_TX_DAT_Reg = 1'b0;

reg         RGMII_TX_VAL_OUT=1'b0;
reg         RGMII_TX_Err_OUT=1'b0;
reg [8-1:0] RGMII_TX_DAT_OUT = 1'b0;

reg         RGMII_TxClockSync_D=0;
reg         RGMII_TxClockSyncPulse=0;


wire [8-1:0] wRGMII_InBandStatus;
assign wRGMII_InBandStatus  = (RGMII_InBandStatusEnabled==0) ? 0 : {1'b1,RGMII_SPEED_STATE,RGMII_LINK_VAL,1'b1,RGMII_SPEED_STATE,RGMII_LINK_VAL};


always @(posedge RGMII_TXD_REFERENCE)
begin
RGMII_LINK_VAL      <=  RGMII_LINK_UP;
RGMII_SPEED_STATE   <=  RGMII_SPEED;

RGMII_TxClockSync_D <= RGMII_TxClockSync;
RGMII_TxClockSyncPulse <= RGMII_TxClockSync && !RGMII_TxClockSync_D;
 
RGMII_TX_DAT_D <= RGMII_TX_DAT;
RGMII_TX_VAL_D <= RGMII_TX_VAL&RGMII_LINK_VAL;
RGMII_TX_Err_D <= RGMII_TX_Err;       

if (RGMII_TxClockSyncPulse) SpeedCounter<=wSpeedCounterThresold;
    else if (SpeedCounter==0) SpeedCounter<=wSpeedCounterThresold;
        else SpeedCounter <= SpeedCounter - 1'b1; 

if (RGMII_SPEED_STATE[1]==1'b1) RGMII_TX_RDY<=1'b1;
    else if (RGMII_TxClockSyncPulse) RGMII_TX_RDY<=1'b0;
        else if ((SpeedCounter==1)) RGMII_TX_RDY<=1'b1;
            else if ((SpeedCounter!=1)) RGMII_TX_RDY<=1'b0;
   
RGMII_TX_WrEna_D <= RGMII_TX_RDY &&  RGMII_TX_VAL;
RGMII_TX_Reset_D <= RGMII_TX_RDY && !RGMII_TX_VAL;

if (RGMII_TX_WrEna_D) RGMII_TX_DAT_Reg <= RGMII_TX_DAT_D; else if (RGMII_TX_Reset_D) RGMII_TX_DAT_Reg <= wRGMII_InBandStatus; 
if (RGMII_TX_WrEna_D) RGMII_TX_Err_Reg <= RGMII_TX_Err_D; else if (RGMII_TX_Reset_D) RGMII_TX_Err_Reg <= 0; 
if (RGMII_TX_WrEna_D) RGMII_TX_VAL_Reg <= RGMII_TX_VAL_D; else if (RGMII_TX_Reset_D) RGMII_TX_VAL_Reg <= 0; 

DataL_H_SwitchtFlag <= (SpeedCounter> wDataSwitchTresold);

if (RGMII_SPEED_STATE[1]==1'b1)  RGMII_TX_DAT_OUT <= RGMII_TX_DAT_Reg;
    else if (DataL_H_SwitchtFlag) RGMII_TX_DAT_OUT <= {RGMII_TX_DAT_Reg[3:0],RGMII_TX_DAT_Reg[3:0]};
        else RGMII_TX_DAT_OUT <= {RGMII_TX_DAT_Reg[7:4],RGMII_TX_DAT_Reg[7:4]};

if (RGMII_SPEED_STATE[1]==1'b1)  {RGMII_TX_VAL_OUT , RGMII_TX_Err_OUT}<= {RGMII_TX_VAL_Reg , RGMII_TX_VAL_Reg^RGMII_TX_Err_Reg};
    else if (DataL_H_SwitchtFlag) {RGMII_TX_VAL_OUT , RGMII_TX_Err_OUT} <= {RGMII_TX_VAL_Reg,RGMII_TX_VAL_Reg};
        else {RGMII_TX_VAL_OUT , RGMII_TX_Err_OUT} <= {RGMII_TX_VAL_Reg^RGMII_TX_Err_Reg,RGMII_TX_VAL_Reg^RGMII_TX_Err_Reg};

SpeedCounterZeroPulse <=  (SpeedCounter==0);
end

///////////////////////////////////////////////////////////////////////////////////////////////
///// RGMII_TXC Clock managment 
///////////////////////////////////////////////////////////////////////////////////////////////

wire wClkTimingD1;
wire wClkTimingD2;

generate
if (RGMII_TXC_REFERENCE_CLK=="REFERENCE_PHY_RXC") // If the RGMII uses its own local clock, which is obtained from the PHY.
    begin
        (* KEEP_HIERARCHY = "TRUE" *)
        RGMII_TXC_FORMING_CLK_REFERENCE_PHY_RXC RGMII_TXC_FORMING_CLK_REFERENCE_PHY_RXC_inst
        (
        .RGMII_TXC_REFERENCE        (RGMII_TXC_REFERENCE),
        .RGMII_SPEED_STATE          (RGMII_SPEED_STATE),

        .ClkTimingD1_OUT            (wClkTimingD1),
        .ClkTimingD2_OUT            (wClkTimingD2)
        );
    end else if (RGMII_TXC_REFERENCE_CLK=="REFERENCE_125MHz")           
    begin
        (* KEEP_HIERARCHY = "TRUE" *) 
        RGMII_TXC_FORMING_CLK_REFERENCE_125MHz RGMII_TXC_FORMING_CLK_REFERENCE_125MHz_inst
        (
        .RGMII_TXC_REFERENCE        (RGMII_TXC_REFERENCE),
        .RGMII_SPEED_STATE          (RGMII_SPEED_STATE),
        .RGMII_SpeedSyncPulse       (SpeedCounterZeroPulse),

        .ClkTimingD1_OUT            (wClkTimingD1),
        .ClkTimingD2_OUT            (wClkTimingD2)
        );
    end else if (RGMII_TXC_REFERENCE_CLK=="REFERENCE_125MHz_90")           
    begin
        (* KEEP_HIERARCHY = "TRUE" *) 
        RGMII_TXC_FORMING_CLK_REFERENCE_125MHz RGMII_TXC_FORMING_CLK_REFERENCE_125MHz_90_inst
        (
        .RGMII_TXC_REFERENCE        (RGMII_TXC_REFERENCE),
        .RGMII_SPEED_STATE          (RGMII_SPEED_STATE),
        .RGMII_SpeedSyncPulse       (SpeedCounterZeroPulse),

        .ClkTimingD1_OUT            (wClkTimingD1),
        .ClkTimingD2_OUT            (wClkTimingD2)
        );
    end else if (RGMII_TXC_REFERENCE_CLK=="REFERENCE_250MHz")           
    begin
        reg Clk250SyncPulse=0;
        always @(posedge RGMII_TXD_REFERENCE) Clk250SyncPulse <= ! Clk250SyncPulse;
        
        (* KEEP_HIERARCHY = "TRUE" *) 
        RGMII_TXC_FORMING_CLK_REFERENCE_250MHz   #(.RGMII_TXC_FRONT_POSITION(RGMII_TXC_FRONT_POSITION))   RGMII_TXC_FORMING_CLK_REFERENCE_250MHz_inst
        (
        .RGMII_TXC_REFERENCE        (RGMII_TXC_REFERENCE),
        .RGMII_SPEED_STATE          (RGMII_SPEED_STATE),
        .RGMII_SpeedSyncPulse       (SpeedCounterZeroPulse),
        .RGMII_HighSpeedSyncPulse   (Clk250SyncPulse),

        .ClkTimingD1_OUT            (wClkTimingD1),
        .ClkTimingD2_OUT            (wClkTimingD2)
        );
    end 

endgenerate
///////////////////////////////////////////////////////////////////////////////////////////////
///// RGMII ODDR instance
///////////////////////////////////////////////////////////////////////////////////////////////

(* KEEP_HIERARCHY = "TRUE" *)
RGMII_ODDR #(.ARCH(ARCH))  RGMII_ODDR_INST
(
.RGMII_TXC          ( RGMII_TXC             ),
.RGMII_TX_CTL       ( RGMII_TX_CTL          ),
.RGMII_TXD          ( RGMII_TXD             ),

.CLK_D1             ( wClkTimingD1          ),
.CLK_D2             ( wClkTimingD2          ),

.RGMII_TXC_REFERENCE( RGMII_TXC_REFERENCE   ),
.RGMII_TXD_REFERENCE( RGMII_TXD_REFERENCE   ),
.RGMII_TX_dVAL      ( RGMII_TX_VAL_OUT      ),
.RGMII_TX_dErr      ( RGMII_TX_Err_OUT      ),
.RGMII_TX_DATA      ( RGMII_TX_DAT_OUT      )
);


endmodule