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

module RGMII_OverSampler
#(
parameter ARCH = "DEFAULT_LOGIC",
parameter OVER_SAMPLING = "NO",
parameter OPPOSITE_EDGE_LATCH_MODE = "NO"
)
(
input CLK625MHZ,

input   wire          RGMII_RXC,
input   wire          RGMII_RX_CTL,
input   wire [4-1:0]  RGMII_RXD,

output  wire           RGMII_RX_CLK,
output  wire           RGMII_RX_CTL_Q1,
output  wire           RGMII_RX_CTL_Q2,
output  wire  [8-1:0]  RGMII_RX_DATA_Q

);



wire wRGMII_RX_CLK;

assign RGMII_RX_CLK = wRGMII_RX_CLK;

wire        wRGMII_RX_CLK_Q1;
wire        wRGMII_RX_CLK_Q2;
wire        wRGMII_RX_CTL_Q1;
wire        wRGMII_RX_CTL_Q2;
wire [7:0]  wRGMII_RX_DATA_Q;

wire wProg_full;
reg Prog_full =0;

(* KEEP_HIERARCHY = "TRUE" *)
RGMII_IDDR_WRAPPER 
#(
.ARCH(ARCH),
.OVER_SAMPLING(OVER_SAMPLING),
.OPPOSITE_EDGE_LATCH_MODE(OPPOSITE_EDGE_LATCH_MODE)
)  RGMII_IDDR_WRAPPER_INST
(
.CLK625MHZ          (CLK625MHZ),
.RGMII_RXC          (RGMII_RXC      ),
.RGMII_RX_CTL       (RGMII_RX_CTL   ),
.RGMII_RXD          (RGMII_RXD      ),

.RGMII_RX_CLK         (wRGMII_RX_CLK       ),
.RGMII_RX_CLK_Q1      (wRGMII_RX_CLK_Q1    ),
.RGMII_RX_CLK_Q2      (wRGMII_RX_CLK_Q2    ),
.RGMII_RX_CTL_Q1      (wRGMII_RX_CTL_Q1    ),
.RGMII_RX_CTL_Q2      (wRGMII_RX_CTL_Q2    ),
.RGMII_RX_DATA_Q      (wRGMII_RX_DATA_Q    )
);

reg rRGMII_RX_CLK_Q1=0;
reg rRGMII_RX_CLK_Q2=0;

reg rRGMII_RX_CTL_Q1=0;
reg rRGMII_RX_CTL_Q2=0;

reg [7:0] RGMII_RX_DATA_Q_D0;

reg Hpulse0 =0;
reg Hpulse1 =0;
//reg Hpulse11 =0;

reg Lpulse0 =0;
reg Lpulse1 =0;

//reg Lpulse00 =0;
//reg Hpulse00 =0;

reg Lpulse =0;


reg [4:0] DataL1=0;
reg [4:0] DataL=0;
reg [4:0] DataH=0;

//reg [4:0] DataH=0;

reg [7:0] Data=0;
reg [1:0] Data_CTL=0;

reg FIFO_Lpulse =0;
reg [9:0] FIFO_LData =0;

reg SkipFlag =0;

always @(posedge CLK625MHZ)
begin
{rRGMII_RX_CLK_Q2,rRGMII_RX_CLK_Q1} <= {wRGMII_RX_CLK_Q2,wRGMII_RX_CLK_Q1};
{rRGMII_RX_CTL_Q2,rRGMII_RX_CTL_Q1} <= {wRGMII_RX_CTL_Q2,wRGMII_RX_CTL_Q1};

RGMII_RX_DATA_Q_D0 <= wRGMII_RX_DATA_Q;

Hpulse0 <= ~rRGMII_RX_CLK_Q1 && ~rRGMII_RX_CLK_Q2 &&  wRGMII_RX_CLK_Q1 &&  wRGMII_RX_CLK_Q2;
Hpulse1 <= ~rRGMII_RX_CLK_Q1 &&  rRGMII_RX_CLK_Q2 &&  wRGMII_RX_CLK_Q1 &&  wRGMII_RX_CLK_Q2;


Lpulse0 <=  rRGMII_RX_CLK_Q1 &&  rRGMII_RX_CLK_Q2 && ~wRGMII_RX_CLK_Q1 && ~wRGMII_RX_CLK_Q2;
Lpulse1 <=  rRGMII_RX_CLK_Q1 && ~rRGMII_RX_CLK_Q2 && ~wRGMII_RX_CLK_Q1 && ~wRGMII_RX_CLK_Q2;



//Hpulse00 <=Hpulse0;
//Lpulse00 <=Lpulse0;

//Hpulse11 <=Hpulse1;




if (Hpulse0) DataL <= {rRGMII_RX_CTL_Q2 , RGMII_RX_DATA_Q_D0[7:4]};
    else if (Hpulse1) DataL <= {rRGMII_RX_CTL_Q1 , RGMII_RX_DATA_Q_D0[3:0]};
    
//if (Hpulse0) DataL <= {wRGMII_RX_CTL_Q1 , wRGMII_RX_DATA_Q[7:4]};
//    else if (Hpulse1) DataL <= {wRGMII_RX_CTL_Q2 , wRGMII_RX_DATA_Q[7:4]};

if (Lpulse0) DataH <= {rRGMII_RX_CTL_Q2 , RGMII_RX_DATA_Q_D0[7:4]};
    else if (Lpulse1) DataH <= {rRGMII_RX_CTL_Q1 , RGMII_RX_DATA_Q_D0[3:0]};
    
//if (Lpulse0) DataH <= {wRGMII_RX_CTL_Q1 , wRGMII_RX_DATA_Q[7:4]};
//    else if (Lpulse1) DataH <= {wRGMII_RX_CTL_Q2 , wRGMII_RX_DATA_Q[7:4]};
    
    
    
if (Lpulse0||Lpulse1) DataL1 <= DataL;
   
Lpulse <=  Lpulse0 || Lpulse1;  




if (Lpulse) Data        <= {DataH[3:0],DataL1[3:0]}; 
if (Lpulse) Data_CTL    <= {DataH[4], DataL1[4]};

Prog_full <= wProg_full;

FIFO_Lpulse <= Lpulse && ((Prog_full != 1) || (Data_CTL != 0)  ) ;
FIFO_LData  <= {Data_CTL,Data};

SkipFlag    <= Lpulse && ((Prog_full == 1) && (Data_CTL == 0)  ) ;
end

wire wProg_Empty;
reg  FIFO_rd_en =0;


//reg WriteBlock =0;

always @(posedge wRGMII_RX_CLK) FIFO_rd_en <= !wProg_Empty || ({RGMII_RX_CTL_Q2,RGMII_RX_CTL_Q1} !=0) ;




(* KEEP_HIERARCHY = "TRUE" *)
RGMII_ELASTIC_FIFO RGMII_ELASTIC_FIFO_inst (
  .wr_clk       (CLK625MHZ),         // input wire wr_clk
  .rd_clk       (wRGMII_RX_CLK),         // input wire rd_clk
  .din          (FIFO_LData),    // input wire [9 : 0] din
  .wr_en        (FIFO_Lpulse),           // input wire wr_en
  .rd_en        (FIFO_rd_en),       // input wire rd_en
  .dout         ({RGMII_RX_CTL_Q2,RGMII_RX_CTL_Q1,RGMII_RX_DATA_Q}),              // output wire [9 : 0] dout
  .full         (),                  // output wire full
  .empty        (),           // output wire empty
  .prog_empty   (wProg_Empty),    
  .prog_full    (wProg_full)     // output wire prog_full
);

endmodule
