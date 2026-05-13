`timescale 1ns / 1ps

module UDP_3k_DataBuffer_x32
#(parameter ARCH = "XLX_ULTRASCALE")
(
input  wire                                 WrClk       ,
input  wire                                 WrEna       ,
input  wire [ 3:0]                          WrWea       ,
input  wire [RAM_AddrBitWidth(4*256)-1:0]   WrAddress   ,
input  wire [31:0]                          WrData      ,

input  wire                                 RdClk       ,
input  wire                                 RdEna       ,
input  wire [RAM_AddrBitWidth(4*256)-1:0]   RdAddress   ,
output reg  [31:0]                          RdData    
);

function integer RAM_AddrBitWidth (input integer Value);                  
    if (Value<3)
        begin
            RAM_AddrBitWidth = 1; 
        end
    else 
        begin
            Value=Value-1;                                                            
            for(RAM_AddrBitWidth=0; Value>0; RAM_AddrBitWidth=RAM_AddrBitWidth+1) Value = Value >> 1;                                                     
        end                                                          
endfunction 

wire [31:0]   wRdData0;
wire [31:0]   wRdData1;
wire [31:0]   wRdData2;

wire [ 4-1:0] wWrWeaBank0;
wire [ 4-1:0] wWrWeaBank1;
wire [ 4-1:0] wWrWeaBank2;
assign wWrWeaBank0  [ 4-1:0]  = (WrAddress[9:8]==2'b00) ? WrWea : 4'b0000; 
assign wWrWeaBank1  [ 4-1:0]  = (WrAddress[9:8]==2'b01) ? WrWea : 4'b0000; 
assign wWrWeaBank2  [ 4-1:0]  = (WrAddress[9:8]==2'b10) ? WrWea : 4'b0000; 

reg  [ 2-1:0] ReadBankSel_D0=0;
reg  [ 2-1:0] ReadBankSel_D1=0;

always @(posedge RdClk)
begin
if (RdEna) 
    begin
    ReadBankSel_D0 <= RdAddress[9:8];
    ReadBankSel_D1 <= ReadBankSel_D0;
    
    if (ReadBankSel_D1==2'b00) RdData <= wRdData0;
        else if (ReadBankSel_D1==2'b01) RdData <= wRdData1;
            else if (ReadBankSel_D1==2'b10) RdData <= wRdData2;
                else if (ReadBankSel_D1==2'b11) RdData <= 0;
    end
end

(* KEEP_HIERARCHY = "TRUE" *)
X32_1k_DataBuffer #(.ARCH(ARCH)) X32_1k_DataBuffer_inst0  
(
.WrClk             (WrClk           ),
.WrEna             (WrEna           ),
.WrWea             (wWrWeaBank0     ),
.WrAddress         (WrAddress[ 7:0] ),
.WrData            (WrData          ),

.RdClk             (RdClk           ),
.RdEna             (RdEna           ),
.RdAddress         (RdAddress[ 7:0] ),
.RdData            (wRdData0        )
);

(* KEEP_HIERARCHY = "TRUE" *)
X32_1k_DataBuffer #(.ARCH(ARCH)) X32_1k_DataBuffer_inst1  
(
.WrClk             (WrClk           ),
.WrEna             (WrEna           ),
.WrWea             (wWrWeaBank1     ),
.WrAddress         (WrAddress[ 7:0] ),
.WrData            (WrData          ),

.RdClk             (RdClk           ),
.RdEna             (RdEna           ),
.RdAddress         (RdAddress[ 7:0] ),
.RdData            (wRdData1        )
);

(* KEEP_HIERARCHY = "TRUE" *)
X32_1k_DataBuffer #(.ARCH(ARCH)) X32_1k_DataBuffer_inst2  
(
.WrClk             (WrClk           ),
.WrEna             (WrEna           ),
.WrWea             (wWrWeaBank2     ),
.WrAddress         (WrAddress[ 7:0] ),
.WrData            (WrData          ),

.RdClk             (RdClk           ),
.RdEna             (RdEna           ),
.RdAddress         (RdAddress[ 7:0] ),
.RdData            (wRdData2        )
);
endmodule
