#ifndef TG_UDP_CONTROL_TYPES_H
#define TG_UDP_CONTROL_TYPES_H

typedef struct
{
    unsigned char 	CommandCode;
    unsigned char 	CommandParam;
    unsigned short 	CommandSize;

    unsigned int 	CommandReserve;
    unsigned int 	CommandUniqConstant;
    unsigned int 	HeaderCRC;

    unsigned int 	PayloadMagicConstant;

    unsigned short 	TG_PacketSize;
    unsigned short 	TG_PacketGap;

    unsigned int 	TG_PacketCount;

    unsigned int 	DataReserve[14];
    unsigned int 	FullCommandCRC;

} TG_Start_Struct;

typedef struct
{
unsigned char CommandCode;
unsigned char CommandParam;
unsigned short CommandSize;

unsigned int CommandReserve;
unsigned int CommandUniqConstant;
unsigned int HeaderCRC;

unsigned int PayloadMagicConstant;

unsigned int DataReserve[16];
unsigned int FullCommandCRC;
} RequestTelemetry_Struct;


#endif // TG_UDP_CONTROL_TYPES_H
