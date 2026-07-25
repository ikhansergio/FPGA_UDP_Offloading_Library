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

module RGMII_OverSampler_ClockShift
#(
parameter OVER_SAMPLING_SHIFT = 0
)
(
input  wire         CLK625MHZ,

input wire          IN_RGMII_RX_CLK_Q1,
input wire          IN_RGMII_RX_CLK_Q2,
input wire          IN_RGMII_RX_CTL_Q1,
input wire          IN_RGMII_RX_CTL_Q2,
input wire [8-1:0]  IN_RGMII_RX_DATA_Q,

output wire         OUT_RGMII_RX_CLK_Q1,
output wire         OUT_RGMII_RX_CLK_Q2,
output wire         OUT_RGMII_RX_CTL_Q1,
output wire         OUT_RGMII_RX_CTL_Q2,
output wire [8-1:0] OUT_RGMII_RX_DATA_Q
);


assign OUT_RGMII_RX_CLK_Q1 = IN_RGMII_RX_CLK_Q1;
assign OUT_RGMII_RX_CLK_Q2 = IN_RGMII_RX_CLK_Q2;
    
generate 
if ((OVER_SAMPLING_SHIFT == 0)||(OVER_SAMPLING_SHIFT > 9) ) 
    begin
    assign OUT_RGMII_RX_CTL_Q1 = IN_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_CTL_Q2 = IN_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_DATA_Q = {IN_RGMII_RX_DATA_Q[7:4],IN_RGMII_RX_DATA_Q[3:0]};
    end
else if (OVER_SAMPLING_SHIFT == 1) 
    begin
    assign OUT_RGMII_RX_CTL_Q1 = IN_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_CTL_Q2 = IN_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_DATA_Q = {IN_RGMII_RX_DATA_Q[3:0],IN_RGMII_RX_DATA_Q[7:4]};
    end
else if (OVER_SAMPLING_SHIFT == 2) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D0_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_CTL_Q2 = D0_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_DATA_Q = {D0_RGMII_RX_DATA_Q[7:4],D0_RGMII_RX_DATA_Q[3:0]};
    end    
else if (OVER_SAMPLING_SHIFT == 3) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D0_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_CTL_Q2 = D0_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_DATA_Q = {D0_RGMII_RX_DATA_Q[3:0],D0_RGMII_RX_DATA_Q[7:4]};
    end
else if (OVER_SAMPLING_SHIFT == 4) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D1_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
        D1_RGMII_RX_CTL_Q1<=D0_RGMII_RX_CTL_Q1;
        D1_RGMII_RX_CTL_Q2<=D0_RGMII_RX_CTL_Q2;
        D1_RGMII_RX_DATA_Q<=D0_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D1_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_CTL_Q2 = D1_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_DATA_Q = {D1_RGMII_RX_DATA_Q[7:4],D1_RGMII_RX_DATA_Q[3:0]};
    end
else if (OVER_SAMPLING_SHIFT == 5) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D1_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
        D1_RGMII_RX_CTL_Q1<=D0_RGMII_RX_CTL_Q1;
        D1_RGMII_RX_CTL_Q2<=D0_RGMII_RX_CTL_Q2;
        D1_RGMII_RX_DATA_Q<=D0_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D1_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_CTL_Q2 = D1_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_DATA_Q = {D1_RGMII_RX_DATA_Q[3:0],D1_RGMII_RX_DATA_Q[7:4]};
    end
else if (OVER_SAMPLING_SHIFT == 6) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D1_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D2_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
        D1_RGMII_RX_CTL_Q1<=D0_RGMII_RX_CTL_Q1;
        D1_RGMII_RX_CTL_Q2<=D0_RGMII_RX_CTL_Q2;
        D1_RGMII_RX_DATA_Q<=D0_RGMII_RX_DATA_Q;
        D2_RGMII_RX_CTL_Q1<=D1_RGMII_RX_CTL_Q1;
        D2_RGMII_RX_CTL_Q2<=D1_RGMII_RX_CTL_Q2;
        D2_RGMII_RX_DATA_Q<=D1_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D2_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_CTL_Q2 = D2_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_DATA_Q = {D2_RGMII_RX_DATA_Q[7:4],D2_RGMII_RX_DATA_Q[3:0]};
    end
else if (OVER_SAMPLING_SHIFT == 7) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D1_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D2_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
        D1_RGMII_RX_CTL_Q1<=D0_RGMII_RX_CTL_Q1;
        D1_RGMII_RX_CTL_Q2<=D0_RGMII_RX_CTL_Q2;
        D1_RGMII_RX_DATA_Q<=D0_RGMII_RX_DATA_Q;
        D2_RGMII_RX_CTL_Q1<=D1_RGMII_RX_CTL_Q1;
        D2_RGMII_RX_CTL_Q2<=D1_RGMII_RX_CTL_Q2;
        D2_RGMII_RX_DATA_Q<=D1_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D2_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_CTL_Q2 = D2_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_DATA_Q = {D2_RGMII_RX_DATA_Q[3:0],D2_RGMII_RX_DATA_Q[7:4]};
    end
else if (OVER_SAMPLING_SHIFT == 8) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D1_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D2_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D3_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D3_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D3_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
        D1_RGMII_RX_CTL_Q1<=D0_RGMII_RX_CTL_Q1;
        D1_RGMII_RX_CTL_Q2<=D0_RGMII_RX_CTL_Q2;
        D1_RGMII_RX_DATA_Q<=D0_RGMII_RX_DATA_Q;
        D2_RGMII_RX_CTL_Q1<=D1_RGMII_RX_CTL_Q1;
        D2_RGMII_RX_CTL_Q2<=D1_RGMII_RX_CTL_Q2;
        D2_RGMII_RX_DATA_Q<=D1_RGMII_RX_DATA_Q;
        D3_RGMII_RX_CTL_Q1<=D2_RGMII_RX_CTL_Q1;
        D3_RGMII_RX_CTL_Q2<=D2_RGMII_RX_CTL_Q2;
        D3_RGMII_RX_DATA_Q<=D2_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D3_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_CTL_Q2 = D3_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_DATA_Q = {D3_RGMII_RX_DATA_Q[7:4],D3_RGMII_RX_DATA_Q[3:0]};
    end
else if (OVER_SAMPLING_SHIFT == 9) 
    begin
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D0_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D0_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D1_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D1_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D2_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D2_RGMII_RX_DATA_Q=0;
    (* keep = "true" *) reg         D3_RGMII_RX_CTL_Q1=0;
    (* keep = "true" *) reg         D3_RGMII_RX_CTL_Q2=0;
    (* keep = "true" *) reg [8-1:0] D3_RGMII_RX_DATA_Q=0;
    always @(posedge CLK625MHZ)
    begin
        D0_RGMII_RX_CTL_Q1<=IN_RGMII_RX_CTL_Q1;
        D0_RGMII_RX_CTL_Q2<=IN_RGMII_RX_CTL_Q2;
        D0_RGMII_RX_DATA_Q<=IN_RGMII_RX_DATA_Q;
        D1_RGMII_RX_CTL_Q1<=D0_RGMII_RX_CTL_Q1;
        D1_RGMII_RX_CTL_Q2<=D0_RGMII_RX_CTL_Q2;
        D1_RGMII_RX_DATA_Q<=D0_RGMII_RX_DATA_Q;
        D2_RGMII_RX_CTL_Q1<=D1_RGMII_RX_CTL_Q1;
        D2_RGMII_RX_CTL_Q2<=D1_RGMII_RX_CTL_Q2;
        D2_RGMII_RX_DATA_Q<=D1_RGMII_RX_DATA_Q;
        D3_RGMII_RX_CTL_Q1<=D2_RGMII_RX_CTL_Q1;
        D3_RGMII_RX_CTL_Q2<=D2_RGMII_RX_CTL_Q2;
        D3_RGMII_RX_DATA_Q<=D2_RGMII_RX_DATA_Q;
    end
    assign OUT_RGMII_RX_CTL_Q1 = D3_RGMII_RX_CTL_Q2;
    assign OUT_RGMII_RX_CTL_Q2 = D3_RGMII_RX_CTL_Q1;
    assign OUT_RGMII_RX_DATA_Q = {D3_RGMII_RX_DATA_Q[3:0],D3_RGMII_RX_DATA_Q[7:4]};
    end                
endgenerate


endmodule
