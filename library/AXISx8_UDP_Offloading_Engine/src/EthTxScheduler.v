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

module EthTxScheduler
#(
    parameter TxPortCount = 4    //  Number of UDP Tx Masters + ARP + ICMP PING
) 
(
    input	Clk,

    output	reg   [1*TxPortCount-1:0]     Sink_TRDY=0,
    input	wire  [1*TxPortCount-1:0]     Sink_TVALID,
    input	wire  [1*TxPortCount-1:0]     Sink_TERROR,
    input	wire  [1*TxPortCount-1:0]     Sink_TLAST,
    input	wire  [8*TxPortCount-1:0]     Sink_TDATA,
    
    input	wire                          Source_RDY,
    output	reg                           Source_Val = 0,
    output	reg                           Source_Err = 0,
    output	reg                           Source_EoF = 0,
    output	reg   [8-1:0]                 Source_DAT = 0
 );


//function integer TxPortCount (input integer Value);                  
//    TxPortCount = Value +1;                                                        
//endfunction 
function integer REQUEST_COUNT (input integer Value);                  
    REQUEST_COUNT = 1 << Value;                                                        
endfunction 

function integer BitWidth (input integer Value);                  
    if (Value<3)
        begin
            BitWidth = 1; 
        end
    else 
        begin
            Value=Value-1;                                                            
            for(BitWidth=0; Value>0; BitWidth=BitWidth+1) Value = Value >> 1;
            //BitWidth = BitWidth-1;                                                      
        end                                                          
endfunction 

localparam  IDLE=0, WAIT_FINISH=1, TRANSFER_DONE=2, GAP_STATE=3; // ADD PADDING STATE
localparam  INDEX_WIDTH      = BitWidth(TxPortCount);
localparam  MAX_TxPortCount  = REQUEST_COUNT(INDEX_WIDTH);

reg [1*TxPortCount-1:0]     Sink_RDY_REG=0;

reg                         Sink_RDY_Flag=0;

wire wHasValidRequest;
reg [1:0] CurrentSearchState=GAP_STATE;

reg LastDone =0;

reg  GapBlock=0;
reg  [4:0]              GapCounter=23;
reg                     GapDoneFlag=0;
reg  [INDEX_WIDTH-1:0]  CurrentCheckIndex=0;
wire [INDEX_WIDTH-1:0]  wConfirmedIndex;
reg  [INDEX_WIDTH-1:0]  ConfirmedIndex=0;

reg [16-1: 0] WatchdogTimer =0;
reg WatchdogIvent=0;
reg WatchdogResetPulse=0;

reg [MAX_TxPortCount-1:0] wSink_Val =0;
integer k=0; 
always @(*)
begin
for (k = 0; k < MAX_TxPortCount; k = k + 1) 
    begin
    if (k<TxPortCount) wSink_Val[k]<=Sink_TVALID[k];
        else wSink_Val[k]<=0;
    end
end


(* KEEP_HIERARCHY = "TRUE" *)
EthTxSchedulerRequestEncoder #(.INDEX_WIDTH(INDEX_WIDTH))EthTxSchedulerRequestEncoder_inst
(
. Clk                                   (Clk                ),
. ValidRequest                          (wSink_Val          ),
. CurrentCheckIndex                     (CurrentCheckIndex  ),
 
. HasValidRequest                       (wHasValidRequest   ),      // Set to 1, if has any Valid Request
. CurrentValidIndex                     (wConfirmedIndex    )       // Index of first ValidRequest greater than or equal to CurrentCheckIndex
);

reg   [1-1:0]                 wSource_Val =1'b0;
reg   [1-1:0]                 wSource_Err =1'b0;
reg   [1-1:0]                 wSource_EoF =1'b0;
reg   [8-1:0]                 wSource_DAT =8'b0;

integer i=0; 
always @(*)
begin

wSource_Val =1'b0;
wSource_Err =1'b0;
wSource_EoF =1'b0;
wSource_DAT =8'b0;

for (i = 0; i <  TxPortCount ; i = i + 1) 
    begin
    Sink_TRDY[i] =Sink_RDY_REG[i]&Source_RDY;
    if (ConfirmedIndex==i)
        begin
        wSource_Val =  Sink_TVALID[i]; 
        wSource_Err =  Sink_TERROR[i];
        wSource_EoF =  Sink_TLAST[i];
        wSource_DAT =  Sink_TDATA[i*8+:8];
        end    
    end
end

integer j=0;  
always @(posedge Clk)
begin
for (j = 0; j <= TxPortCount-1; j = j + 1) 
    begin
    if (Source_RDY)
    begin
        if (CurrentSearchState==WAIT_FINISH)
            begin
                 if ((ConfirmedIndex==j)&&wSource_Val&&wSource_EoF) Sink_RDY_REG[j]<=1'b0;  
                    else if (ConfirmedIndex==j) Sink_RDY_REG[j]<=1'b1;
                        else if (ConfirmedIndex!=j)  Sink_RDY_REG[j]<=1'b0; 
                Sink_RDY_Flag <=1'b1;
            end 
            else if (CurrentSearchState!=WAIT_FINISH)
            begin
                Sink_RDY_REG[j]<=0; 
                Sink_RDY_Flag <=1'b0;
            end
        end
    end
end

always @(posedge Clk )
begin


if (Source_RDY)
    begin
    
    if (CurrentSearchState==WAIT_FINISH)
        begin
            if (Sink_RDY_Flag) Source_Val <=  wSource_Val; 
            if (Sink_RDY_Flag) Source_Err <=  wSource_Err;
            if (Sink_RDY_Flag) Source_EoF <=  wSource_EoF;
            if (Sink_RDY_Flag) Source_DAT <=  wSource_DAT;
        end 
        else if (CurrentSearchState!=WAIT_FINISH)
        begin
            Source_Val <=  0;
            Source_Err <=  0;  
            Source_EoF <=  0;
            Source_DAT <=  0;
        end 

    end


if (Source_RDY)
    begin
        if (LastDone) GapCounter<= 5'd20;                          // 12 ticks interframe gap plus 8 ticks preamble plus 4 ticks FCS -> 24 ticks for gap 
            else if (GapCounter!=0) GapCounter<=GapCounter-1;
        GapDoneFlag<=(GapCounter==0);
        
        WatchdogResetPulse <= (CurrentSearchState==IDLE);    
        if (WatchdogResetPulse) WatchdogTimer<=16'hFFFF; 
            else WatchdogTimer<=WatchdogTimer-1'b1;
        WatchdogIvent<=(WatchdogTimer==0);

        if (WatchdogIvent) 
            begin
                CurrentSearchState<=IDLE;
            end  
            else begin  
                case (CurrentSearchState)
	               IDLE                        :   begin
	                                               if (wHasValidRequest&&GapDoneFlag) 
	                                                   begin 
	                                                   ConfirmedIndex<=wConfirmedIndex;
	                                                   CurrentSearchState<= WAIT_FINISH  ;
	                                                   end
	                                               end 
	               WAIT_FINISH                 :   if (wSource_Val&&wSource_EoF)
	                                               begin
	                                               CurrentSearchState<= TRANSFER_DONE;
	                                               LastDone<=1'b1;
	                                               end
	               TRANSFER_DONE               :   begin
	                                               CurrentSearchState<= GAP_STATE;
	                                               LastDone<=1'b0;
	                                               
	                                               if (CurrentCheckIndex==ConfirmedIndex) CurrentCheckIndex<= CurrentCheckIndex+1'b1;
	                                                   else CurrentCheckIndex<=ConfirmedIndex;
	                                                   /////////// !!!!! Check logic
	                                               end
	               GAP_STATE                   :   begin
	                                               if (GapDoneFlag) CurrentSearchState<= IDLE;
	                                               if (~wHasValidRequest)  CurrentCheckIndex<=0;
	                                               end
                   default 	                   :   begin
	                                               CurrentSearchState<= IDLE;
	                                               end
                endcase
            end
   
    end 
end 	

 
	  
endmodule
