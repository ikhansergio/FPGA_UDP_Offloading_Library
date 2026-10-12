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

module GMII_MII_Rx_To_AXISx8
(
input  wire         GMII_MII_MODE_SELECT    ,
input  wire         GMII_RXCLK              ,   
input  wire         GMII_RXDV               ,
input  wire         GMII_RXERR              ,
input  wire [8-1:0] GMII_RXD                ,

input  wire         GMII_COL                ,
input  wire         GMII_CRS                ,

output reg          Source_TVALID=0         ,
output reg          Source_TERROR=0         ,
output reg          Source_TFIRST=0         ,
output wire         Source_TLAST            ,
output reg  [8-1:0] Source_TDATA=0          ,
output reg  [2-1:0] Source_TUSER=0      
);

reg GMII_RXDV_D=0;
reg MII_DIV=0;

reg MII_TFIRST=0;

reg MII_TLAST_PULSE=0;

wire wMII_TVALID;
assign  wMII_TVALID = GMII_RXDV && GMII_RXDV_D && MII_DIV || GMII_RXDV_D && !GMII_RXDV && MII_DIV;

always @(posedge GMII_RXCLK)
begin
if (GMII_RXDV & ! GMII_RXDV_D) MII_DIV <=1; else MII_DIV <= !MII_DIV;

MII_TFIRST <= GMII_RXDV & ! GMII_RXDV_D;    
GMII_RXDV_D<=GMII_RXDV;

if (GMII_MII_MODE_SELECT)
    begin
    Source_TUSER  <= {GMII_CRS , GMII_COL};
    Source_TVALID <= GMII_RXDV;
    Source_TFIRST <= GMII_RXDV & ! GMII_RXDV_D;
    Source_TDATA  <= GMII_RXD;
    if (GMII_RXERR&&GMII_RXDV) Source_TERROR <= 1'b1;
        else if (GMII_RXDV & ! GMII_RXDV_D)  Source_TERROR <= GMII_RXERR;
        
    MII_TLAST_PULSE <=  0;    
    end 
    else
    begin
    if (wMII_TVALID ) Source_TUSER  <= {GMII_COL,GMII_CRS};
    Source_TVALID <= wMII_TVALID;
    Source_TFIRST <= GMII_RXDV && MII_TFIRST;
    
    if (GMII_RXERR&&GMII_RXDV) Source_TERROR <= 1'b1;                           // if GMII_RXERR is set -> Source_TERROR is set
        else if (GMII_RXDV & ! GMII_RXDV_D)  Source_TERROR <= GMII_RXERR;       // Reinit Source_TERROR at start.
            else if (GMII_RXDV_D&&!GMII_RXDV&&MII_DIV) Source_TERROR <= 1'b1;   // Detection Error if host sent odd number of data
        
    // MII mode is 4 bit interface. We need to reorder 4 bit data to 8 bit AXIS bus.
    if (GMII_RXDV & ! GMII_RXDV_D) Source_TDATA[3:0] <= GMII_RXD[3:0];          
        else if (GMII_RXDV & ! MII_DIV) Source_TDATA[3:0] <= GMII_RXD[3:0];
            else if (GMII_RXDV &   MII_DIV) Source_TDATA[7:4] <= GMII_RXD[3:0];
                else if (!GMII_RXDV ) Source_TDATA[7:0] <= 0;
    
    // Trying to detect odd number of data in MII frame            
    MII_TLAST_PULSE <=  GMII_RXDV_D && !GMII_RXDV && MII_DIV;
    end
end 

assign Source_TLAST = GMII_RXDV_D&&!GMII_RXDV || MII_TLAST_PULSE; 
endmodule
