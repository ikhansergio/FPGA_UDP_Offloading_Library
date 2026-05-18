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

module XLX_SERIES7_Clk_Buff_Schematic_Type
#(
parameter RX_CLK_BUFF_SCH_TYPE=0		
)
(
input   wire    RGMII_RXC,
output  wire    CLK_IDDR,
output  wire    CLK_FABRIC
);

generate

if (RX_CLK_BUFF_SCH_TYPE == 0 )        // Default Auto mode
begin
	assign CLK_IDDR 	= RGMII_RXC;
	assign CLK_FABRIC 	= RGMII_RXC;
end else 
if (RX_CLK_BUFF_SCH_TYPE == 1 )
begin
	BUFIO IDDR_inst1 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFR FABRIC_inst1 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (RX_CLK_BUFF_SCH_TYPE == 2 )
begin
	BUFIO IDDR_inst2 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFG FABRIC_inst2 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (RX_CLK_BUFF_SCH_TYPE == 3 )
begin
	BUFR IDDR_inst3 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

//	BUFR FABRIC_inst3 
//		(
//		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
//		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
//		);
        assign CLK_FABRIC = CLK_IDDR;
end else 
if (RX_CLK_BUFF_SCH_TYPE == 4 )
begin
	BUFR IDDR_inst4 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFG FABRIC_inst4 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (RX_CLK_BUFF_SCH_TYPE == 5 )
begin
	BUFG IDDR_inst5 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFR FABRIC_inst5 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (RX_CLK_BUFF_SCH_TYPE == 6 )
begin
	BUFG IDDR_inst6 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

//	BUFG FABRIC_inst6 
//		(
//		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
//		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
//		);
		assign CLK_FABRIC = CLK_IDDR;
end

endgenerate

endmodule
