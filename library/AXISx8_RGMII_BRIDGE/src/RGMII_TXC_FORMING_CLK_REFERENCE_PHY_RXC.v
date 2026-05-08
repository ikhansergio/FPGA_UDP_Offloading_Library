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

module RGMII_TXC_FORMING_CLK_REFERENCE_PHY_RXC
(
input wire           RGMII_TXC_REFERENCE,
input wire [2-1:0]   RGMII_SPEED_STATE,

output ClkTimingD1_OUT,
output ClkTimingD2_OUT
);

reg [2-1:0] RGMII_SPEED_STATE_REF=0;

reg [9:0] ClkTimingD1=0;
reg [9:0] ClkTimingD2=0;

assign ClkTimingD1_OUT = ClkTimingD1[0];
assign ClkTimingD2_OUT = ClkTimingD2[0];

always @(posedge RGMII_TXC_REFERENCE)
begin
RGMII_SPEED_STATE_REF <= RGMII_SPEED_STATE;
if (RGMII_SPEED_STATE_REF[1]==1'b1) 
    begin
        ClkTimingD1<=10'b1111111111;
        ClkTimingD2<=10'b0000000000;
    end else
    begin
        ClkTimingD1<=10'b0000000000;
        ClkTimingD2<=10'b1111111111;
    end         
end
endmodule