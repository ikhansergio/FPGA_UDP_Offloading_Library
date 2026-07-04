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

module UDP_CommandFIFOx36
#(
    parameter ARCH = "XLX_ULTRASCALE"     
) 
(
    input  wire                    WrClk,
    input  wire                    WrRst,
    input  wire                    WrEna,
    input  wire [36-1:0]           WrDat,

    input  wire                    RdClk,
    input  wire                    RdEna,
    output wire                    RdEpt,
    output wire                    RdPgF,
    output wire [36-1:0]           RdDat

);


 generate
if (ARCH == "XLX_SERIES7")
 begin
     XLX_LUT_FIFO_36x64 XLX_LUT_FIFO_36x64_inst (
    .rst            (WrRst),
    .wr_clk         (WrClk),
    .rd_clk         (RdClk),
    .din            (WrDat),
    .wr_en          (WrEna),
    .rd_en          (RdEna),
    .dout           (RdDat),
    .full           (),
    .prog_full      (RdPgF),
    .empty          (RdEpt)
  );
 end else if (ARCH == "XLX_ULTRASCALE")  
 begin
     XLX_LUT_FIFO_36x64 XLX_LUT_FIFO_36x64_inst (
    .rst            (WrRst),
    .wr_clk         (WrClk),
    .rd_clk         (RdClk),
    .din            (WrDat),
    .wr_en          (WrEna),
    .rd_en          (RdEna),
    .dout           (RdDat),
    .full           (),
    .prog_full      (RdPgF),
    .empty          (RdEpt)
  );   
 end else if (ARCH == "ALT_Cyclone10LP")  
 begin
 wire [7:0] wRdUsedw;
 reg RdPgFull =0;
 
 always @(posedge RdClk)
 begin
 if (wRdUsedw>250) RdPgFull<=1'b1;
    else if (wRdUsedw<250) RdPgFull<=1'b0;
 end
 assign RdPgF = RdPgFull;
 
   ALT_BLK_FIFO_36x256	ALT_BLK_FIFO_36x256_inst (
	.aclr              ( WrRst     ),
	.data              ( WrDat     ),
	.rdclk             ( RdClk     ),
	.rdreq             ( RdEna     ),
	.wrclk             ( WrClk     ),
	.wrreq             ( WrEna     ),
	.q                 ( RdDat     ),
	.rdempty           ( RdEpt     ),
	.rdusedw           ( wRdUsedw  ),
	.wrfull            (           )
	);   
 end
 endgenerate  


endmodule
