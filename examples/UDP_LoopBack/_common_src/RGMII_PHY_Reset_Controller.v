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

module RGMII_PHY_Reset_Controller
#(
parameter ETH_RESET_POLARITY = "POSITIVE"   // "POSITIVE" or "NEGATIVE"
) 
(
    input                CLK ,
    
	 output reg           RGMII_PHY_RST =0                 
);

reg [20-1:0] EtheResetCounter =1; 
wire wResetCondition;
assign wResetCondition = (EtheResetCounter!=0);
always @(posedge CLK)
begin
if (wResetCondition) EtheResetCounter<=EtheResetCounter+1'b1;
if (ETH_RESET_POLARITY == "POSITIVE" ) RGMII_PHY_RST <= wResetCondition;
    else RGMII_PHY_RST <= !wResetCondition;
end 

endmodule
