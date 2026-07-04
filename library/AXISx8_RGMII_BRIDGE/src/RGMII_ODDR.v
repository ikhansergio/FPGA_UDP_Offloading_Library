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

module RGMII_ODDR
#(parameter ARCH = "DEFAULT_LOGIC")
(
input wire          RGMII_TXC_REFERENCE,
input wire          RGMII_TXD_REFERENCE,
input wire [1-1:0]  RGMII_TX_dVAL,
input wire [1-1:0]  RGMII_TX_dErr,
input wire [8-1:0]  RGMII_TX_DATA,

input wire          CLK_D1,
input wire          CLK_D2,

output  wire         RGMII_TXC,
output  wire         RGMII_TX_CTL,
output  wire [4-1:0] RGMII_TXD
);

wire [5:0] wRGMII_C;
wire [5:0] wRGMII_D1;
wire [5:0] wRGMII_D2;
wire [5:0] wRGMII_Q;

assign wRGMII_D1 = {CLK_D1,RGMII_TX_dVAL,RGMII_TX_DATA[3:0]};
assign wRGMII_D2 = {CLK_D2,RGMII_TX_dErr,RGMII_TX_DATA[7:4]};
assign {RGMII_TXC,RGMII_TX_CTL,RGMII_TXD} = wRGMII_Q;
assign wRGMII_C = {RGMII_TXC_REFERENCE,RGMII_TXD_REFERENCE,RGMII_TXD_REFERENCE,RGMII_TXD_REFERENCE,RGMII_TXD_REFERENCE,RGMII_TXD_REFERENCE};

genvar i;
generate for (i = 0; i < 6; i = i + 1) begin: pins

    if (ARCH == "XLX_SERIES7")
    begin
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ODDR_inst 
         (
            .D1 (wRGMII_D1[i]),
            .D2 (wRGMII_D2[i]),
            .Q  (wRGMII_Q [i]), 
            .CE (1'b1),
            .R  (1'b0),
            .S  (1'b0),
            .C  (wRGMII_C [i])
         );
    end else if (ARCH == "XLX_ULTRASCALE")
    begin
    ODDRE1 #(
        .IS_C_INVERTED(1'b0),           // Optional inversion for C
        .IS_D1_INVERTED(1'b0),          // Unsupported, do not use
        .IS_D2_INVERTED(1'b0),          // Unsupported, do not use
        .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
        .SRVAL(1'b0)                    // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
        ) ODDRE1_inst (
        .Q(wRGMII_Q [i]),   // 1-bit output: Data output to IOB
        .C (wRGMII_C[i]),   // 1-bit input: High-speed clock input
        .D1(wRGMII_D1[i]), // 1-bit input: Parallel data input 1
        .D2(wRGMII_D2[i]), // 1-bit input: Parallel data input 2
        .SR(1'b0)  // 1-bit input: Active-High Async Reset
        );
    end else if (ARCH == "ALT_Cyclone10LP")  
    begin
	 
	 altddio_out
	 #(.width(1))
	 ODDR_inst 
	 (
    .datain_h	(wRGMII_D1[i]),
    .datain_l	(wRGMII_D2[i]),
    .outclock	(wRGMII_C [i]),
//    .oe			(1'b1),
//    .outclocken(1'b1),
//    .aset		(1'b0),
//    .aclr		(1'b0),
//    .sset		(1'b0),
//    .sclr		(1'b0),
    .dataout	(wRGMII_Q [i]),
    .oe_out		()
	 );
	 
    end else  // if (ARCH == "DEFAULT_LOGIC")
    begin
        ODDR_LOGIC   ODDR_LOGIC_inst
        (
        .C          (wRGMII_C [i]),
        .D1         (wRGMII_D1[i]),
        .D2         (wRGMII_D2[i]),
        .Q          (wRGMII_Q[i]) 
        );
    end 

end
endgenerate

endmodule


