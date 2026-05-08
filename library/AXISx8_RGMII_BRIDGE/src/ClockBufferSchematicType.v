`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2026 17:53:11
// Design Name: 
// Module Name: ClockBufferSchematicType
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ClockBufferSchematicType
#(
parameter Clk_Buff_Connection_Type=0		
)
(
input   wire    RGMII_RXC,
output  wire    CLK_IDDR,
output  wire    CLK_FABRIC
);

if (Clk_Buff_Connection_Type == 0 )
begin
	assign CLK_IDDR 	= RGMII_RXC;
	assign CLK_FABRIC 	= RGMII_RXC;
end else 
if (Clk_Buff_Connection_Type == 1 )
begin
	BUFIO IDDR_inst 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFR FABRIC_inst 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (Clk_Buff_Connection_Type == 2 )
begin
	BUFIO IDDR_inst 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFG FABRIC_inst 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (Clk_Buff_Connection_Type == 3 )
begin
	BUFR IDDR_inst 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFR FABRIC_inst 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (Clk_Buff_Connection_Type == 4 )
begin
	BUFR IDDR_inst 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFG FABRIC_inst 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (Clk_Buff_Connection_Type == 5 )
begin
	BUFG IDDR_inst 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFR FABRIC_inst 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end else 
if (Clk_Buff_Connection_Type == 6 )
begin
	BUFG IDDR_inst 
		(
		.O(CLK_IDDR),                 // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                 // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);

	BUFG FABRIC_inst 
		(
		.O(CLK_FABRIC),                // 1-bit output: Clock output   (connect to I/O clock loads).
		.I(RGMII_RXC)                  // 1-bit input: Clock input     (connect to an IBUF or BUFMR).
		);
end

endmodule
