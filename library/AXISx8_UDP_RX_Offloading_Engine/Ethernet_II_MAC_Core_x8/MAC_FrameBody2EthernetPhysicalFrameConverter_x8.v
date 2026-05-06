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

module MAC_FrameBody2EthernetPhysicalFrameConverter_x8
(
input  wire           clk,

output wire           MAC_FrameBody_TRDY,
input  wire           MAC_FrameBody_TVALID,
input  wire           MAC_FrameBody_TLAST,
input  wire  [8-1:0]  MAC_FrameBody_TDATA,

input  wire           EthernetPhysicalFrame_TRDY,
output wire           EthernetPhysicalFrame_TVALID,
output wire           EthernetPhysicalFrame_TLAST,
output wire  [8-1:0]  EthernetPhysicalFrame_TDATA
);

wire           wEthernetTxFrameFCS_RDY;
wire           wEthernetTxFrameFCS_Val;
wire           wEthernetTxFrameFCS_EoF;
wire  [8-1:0]  wEthernetTxFrameFCS_Dat;

(* KEEP_HIERARCHY = "TRUE" *)
EthernetTxFrameFCSinsertion_x8      EthernetTxFrameFCSinsertion_x8_inst
(
.clk                             (clk                           ),

.FCSinsertion_Sink_Rdy           (MAC_FrameBody_TRDY            ),
.FCSinsertion_Sink_Val           (MAC_FrameBody_TVALID          ), 
.FCSinsertion_Sink_EoF           (MAC_FrameBody_TLAST           ),
.FCSinsertion_Sink_Dat           (MAC_FrameBody_TDATA           ),

.FCSinsertion_Source_Rdy         (wEthernetTxFrameFCS_RDY       ),
.FCSinsertion_Source_Val         (wEthernetTxFrameFCS_Val),
.FCSinsertion_Source_EoF         (wEthernetTxFrameFCS_EoF),
.FCSinsertion_Source_Dat         (wEthernetTxFrameFCS_Dat)
);

(* KEEP_HIERARCHY = "TRUE" *)
EthernetTxFramePreambleInsertion_x8  EthernetTxFramePreambleInsertion_x8_Inst
(
.clk                              (clk                          ),

.PreambleInsertion_Sink_RDY       (wEthernetTxFrameFCS_RDY      ), 
.PreambleInsertion_Sink_Val       (wEthernetTxFrameFCS_Val      ), 
.PreambleInsertion_Sink_EoF       (wEthernetTxFrameFCS_EoF      ), 
.PreambleInsertion_Sink_Dat       (wEthernetTxFrameFCS_Dat      ),
	
.PreambleInsertion_Source_RDY     (EthernetPhysicalFrame_TRDY   ),
.PreambleInsertion_Source_EoF     (EthernetPhysicalFrame_TLAST  ),
.PreambleInsertion_Source_Val     (EthernetPhysicalFrame_TVALID ),
.PreambleInsertion_Source_Dat     (EthernetPhysicalFrame_TDATA  )
);

endmodule
