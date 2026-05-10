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

// "DEFAULT_LOGIC"
// "XLX_SERIES7"
// "XLX_ULTRASCALE"

module RGMII_IDDR
#(
parameter ARCH = "DEFAULT_LOGIC"        ,
parameter RX_CLK_BUFF_SCH_TYPE=1		,
parameter OVER_SAMPLING = "NO"
)
(
input  wire          CLK625MHZ,

input  wire          RGMII_RXC,
input  wire          RGMII_RX_CTL,
input  wire [4-1:0]  RGMII_RXD,

output wire          RGMII_RX_CLK,
output wire          RGMII_RX_CLK_Q1,
output wire          RGMII_RX_CLK_Q2,
output wire          RGMII_RX_CTL_Q1,
output wire          RGMII_RX_CTL_Q2,
output wire [8-1:0]  RGMII_RX_DATA_Q
);

//assign RGMII_RX_CLK = RGMII_RXC;
wire [5:0] wRGMII_In;
wire [5:0] wRGMII_Q1;
wire [5:0] wRGMII_Q2;

//assign wRGMII_RXC = (OVER_SAMPLING == "YES") ?  CLK625MHZ : RGMII_RX_CLK;
//assign wRGMII_RXC = (OVER_SAMPLING == "YES") ?  CLK625MHZ : wRGMII_RXC_BUF;

assign wRGMII_In  = (OVER_SAMPLING == "YES") ?  {RGMII_RXC,RGMII_RX_CTL,RGMII_RXD} : {1'b0,RGMII_RX_CTL,RGMII_RXD};

assign RGMII_RX_DATA_Q[3:0] = wRGMII_Q1[3:0];
assign RGMII_RX_DATA_Q[7:4] = wRGMII_Q2[3:0];
assign RGMII_RX_CTL_Q1      = wRGMII_Q1[4];
assign RGMII_RX_CTL_Q2      = wRGMII_Q2[4];
assign RGMII_RX_CLK_Q1      = wRGMII_Q1[5];
assign RGMII_RX_CLK_Q2      = wRGMII_Q2[5];

genvar i;
generate 
if (ARCH == "XLX_SERIES7")
begin
	wire wRGMII_RXC;
	wire wRGMII_RXC_BUF;
	wire wRGMII_RXC_FABRIC;
	
	if (OVER_SAMPLING != "YES")
	   begin
	   (* KEEP_HIERARCHY = "TRUE" *)
	   XLX_SERIES7_Clk_Buff_Schematic_Type
	   #(
	   .RX_CLK_BUFF_SCH_TYPE(RX_CLK_BUFF_SCH_TYPE)		
	   ) XLX_SERIES7_Clk_Buff_Schematic_Type_inst
	   (
	   .RGMII_RXC    (RGMII_RXC		),
	   .CLK_IDDR     (wRGMII_RXC_BUF	),
	   .CLK_FABRIC   (wRGMII_RXC_FABRIC)
	   );
	   end
	
	assign RGMII_RX_CLK = (OVER_SAMPLING == "YES") ?  CLK625MHZ : wRGMII_RXC_FABRIC;
	assign wRGMII_RXC   = (OVER_SAMPLING == "YES") ?  CLK625MHZ : wRGMII_RXC_BUF;
	
    for (i = 0; i < 6; i = i + 1) begin: pins
    IDDR
    #(.DDR_CLK_EDGE   ("SAME_EDGE_PIPELINED"), //"OPPOSITE_EDGE",  "SAME_EDGE, "SAME_EDGE_PIPELINED"
    .INIT_Q1        (1'b0),
    .INIT_Q2        (1'b0),
    .SRTYPE         ("ASYNC"))
    iddr_inst
    (
    .Q1             (wRGMII_Q1[i]),        // 1-bit output: Registered parallel output 1
    .Q2             (wRGMII_Q2[i]),        // 1-bit output: Registered parallel output 2
    .C              (wRGMII_RXC),          // 1-bit input: High-speed clock
    .CE             (1'b1),
    .D              (wRGMII_In[i]),         // 1-bit input: Serial Data Input
    .R              (1'b0),                 // 1-bit input: Active-High Async Reset
    .S              (1'b0)
    );
    end
end else if (ARCH == "XLX_ULTRASCALE")
begin
	wire wRGMII_RXC;
	wire wRGMII_RXC_BUF;
	wire wRGMII_RXC_FABRIC;
	
	assign wRGMII_RXC_BUF          = RGMII_RXC;
	assign wRGMII_RXC_FABRIC       = RGMII_RXC;
	
	assign RGMII_RX_CLK    = (OVER_SAMPLING == "YES") ?  CLK625MHZ : wRGMII_RXC_FABRIC;
	assign wRGMII_RXC      = (OVER_SAMPLING == "YES") ?  CLK625MHZ : wRGMII_RXC_BUF;
	
    for (i = 0; i < 6; i = i + 1) begin: pins
    IDDRE1 #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),   // IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
    .IS_CB_INVERTED(1'b1),                  // Optional inversion for CB
    .IS_C_INVERTED(1'b0)                    // Optional inversion for C
    )
    IDDRE1_inst (
    .Q1              (wRGMII_Q1[i]),        // 1-bit output: Registered parallel output 1
    .Q2              (wRGMII_Q2[i]),        // 1-bit output: Registered parallel output 2
    .C               (wRGMII_RXC),          // 1-bit input: High-speed clock
    .CB              (wRGMII_RXC),          // 1-bit input: Inversion of High-speed clock C
    .D               (wRGMII_In[i]),        // 1-bit input: Serial Data Input
    .R               (1'b0)                 // 1-bit input: Active-High Async Reset
    );
end
end else  // if (ARCH == "DEFAULT_LOGIC")
begin
	wire wRGMII_RXC;
	wire wRGMII_RXC_BUF;
	wire wRGMII_RXC_FABRIC;
	
	assign wRGMII_RXC_BUF          = RGMII_RXC;
	assign wRGMII_RXC_FABRIC       = RGMII_RXC;
	
	assign RGMII_RX_CLK    = (OVER_SAMPLING == "YES") ?  CLK625MHZ : wRGMII_RXC_FABRIC;
	assign wRGMII_RXC      = (OVER_SAMPLING == "YES") ?  CLK625MHZ : wRGMII_RXC_BUF;
	
    for (i = 0; i < 6; i = i + 1) begin: pins
    (* KEEP_HIERARCHY = "TRUE" *)
    IDDR_LOGIC          IDDR_LOGIC_inst
    (
    .C              (wRGMII_RXC),
    .D              (wRGMII_In[i]),
    .Q1             (wRGMII_Q1[i]),
    .Q2             (wRGMII_Q2[i])
    );
end 
end
endgenerate

endmodule