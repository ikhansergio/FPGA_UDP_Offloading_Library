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

module RGMII_TXC_FORMING_CLK_REFERENCE_250MHz
#(parameter RGMII_TXC_FRONT_POSITION = "EDGE_ALIGNED")   // EDGE_ALIGNED , CENTER_ALIGNED
(
input wire           RGMII_TXC_REFERENCE,
input wire [2-1:0]   RGMII_SPEED_STATE,
input wire           RGMII_SpeedSyncPulse,
input wire           RGMII_HighSpeedSyncPulse,

output ClkTimingD1_OUT,
output ClkTimingD2_OUT
);

reg RGMII_HighSpeedSyncPulse250_D0=0;
reg RGMII_HighSpeedSyncPulse250_D1=0;
reg RGMII_HighSpeedSyncPulse250=0;

always @(posedge RGMII_TXC_REFERENCE)
begin
RGMII_HighSpeedSyncPulse250_D0<=RGMII_HighSpeedSyncPulse;
RGMII_HighSpeedSyncPulse250_D1<=RGMII_HighSpeedSyncPulse250_D0;
RGMII_HighSpeedSyncPulse250<=RGMII_HighSpeedSyncPulse250_D0&!RGMII_HighSpeedSyncPulse250_D1;
end


reg   SpeedCounterZeroPulse_REF=1'b0; 
reg   SpeedCounterZeroPulse_REF_D0=1'b0;  
reg   SpeedCounterZeroPulse_REF_D1=1'b0;  

 
reg [2-1:0] RGMII_SPEED_STATE_REF=0;

reg [9:0] ClkTimingD1=0;
reg [9:0] ClkTimingD2=0;

reg  [3:0] ClkTimingDivider=0;
wire [3:0] wClkTimingDividerThresold;
assign wClkTimingDividerThresold = (RGMII_SPEED_STATE_REF[1:0]==2'b0) ? 4'd9 : 4'd0;
reg  ClkTimingDividerTickPulse=0;


assign ClkTimingD1_OUT = ClkTimingD1[0];
assign ClkTimingD2_OUT = ClkTimingD2[0];

always @(posedge RGMII_TXC_REFERENCE)
begin
SpeedCounterZeroPulse_REF_D0 <= RGMII_SpeedSyncPulse;
SpeedCounterZeroPulse_REF_D1 <= SpeedCounterZeroPulse_REF_D0;
SpeedCounterZeroPulse_REF <= SpeedCounterZeroPulse_REF_D0&&!SpeedCounterZeroPulse_REF_D1;

RGMII_SPEED_STATE_REF <= RGMII_SPEED_STATE;


    ClkTimingDividerTickPulse<=  (ClkTimingDivider==0);  
    if (SpeedCounterZeroPulse_REF) ClkTimingDivider <= wClkTimingDividerThresold;
        else if (ClkTimingDivider==0) ClkTimingDivider <= wClkTimingDividerThresold;
            else ClkTimingDivider <= ClkTimingDivider -1'b1;     
             
    if (RGMII_SPEED_STATE_REF[1]==1'b1) 
        begin
            if (RGMII_HighSpeedSyncPulse250)
            begin
                if (RGMII_TXC_FRONT_POSITION == "EDGE_ALIGNED")
                    begin 
                        ClkTimingD1<=10'b0101010101;
                        ClkTimingD2<=10'b0101010101;
                    end 
                 else if (RGMII_TXC_FRONT_POSITION == "CENTER_ALIGNED")
                    begin 
                        ClkTimingD1<=10'b1010101010;
                        ClkTimingD2<=10'b0101010101;
                    end 
                end else 
            begin
                ClkTimingD1[9:0] <= {ClkTimingD1[0],ClkTimingD1[9:1]};
                ClkTimingD2[9:0] <= {ClkTimingD2[0],ClkTimingD2[9:1]};
            end
        end 
    else if (RGMII_SPEED_STATE_REF[1]==1'b0)
        begin
            if (SpeedCounterZeroPulse_REF) 
                begin
                    if (RGMII_SPEED_STATE_REF[0]==1'b1) 
                        begin
                            ClkTimingD1<=10'b1111000001;
                            ClkTimingD2<=10'b1111000001;
                        end 
                    else if (RGMII_SPEED_STATE_REF[0]==1'b0) 
                        begin
                            ClkTimingD1<=10'b1111100000;
                            ClkTimingD2<=10'b1111100000;
                        end                         
                end else 
             if (ClkTimingDividerTickPulse)
                begin
                    ClkTimingD1[9:0] <= {ClkTimingD1[0],ClkTimingD1[9:1]};
                    ClkTimingD2[9:0] <= {ClkTimingD2[0],ClkTimingD2[9:1]};
                end 
        end
end
endmodule