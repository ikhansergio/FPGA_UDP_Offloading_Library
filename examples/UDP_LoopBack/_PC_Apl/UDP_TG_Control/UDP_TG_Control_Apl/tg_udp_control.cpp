#include "tg_udp_control.h"
#include <iostream>

TG_UDP_Control::TG_UDP_Control(QObject *parent): QObject(parent)
{
UDP_Buffer.resize(9*1024);
}

TG_UDP_Control::~TG_UDP_Control()
{
    disconnect(TG_UdpSocket, SIGNAL(readyRead()), this, SLOT(Read_UDP_Data()));
    TG_UdpSocket->close();
}


void TG_UDP_Control::Send_UDP_Data(QByteArray Data)
{
    QHostAddress mmmmm;
    mmmmm.setAddress("192.168.0.49");
    qint64 SendResult=0;

    TG_Counter=0;

    for (int i=0;i<10; i++)
    {
        SendResult = TG_UdpSocket->writeDatagram(Data, mmmmm , 9999);
        if (SendResult>0) return;
    }

}

void TG_UDP_Control::Send_UDP_Data2(QByteArray Data)
{

    QHostAddress mmmmm;
    mmmmm.setAddress("192.168.0.49");
    qint64 SendResult=0;

    //unsigned int index =0;

    unsigned int PackCount =0;


    //for (int j=0;j<1000000; j++)
    //{

       //if (index==0) QThread::msleep(10);
       //index++;
       //if (index>100)index=0;

       *reinterpret_cast<unsigned int*> (Data.data())  = PackCount;

        //for (int i=0;i<10000; i++)
        //{

            SendResult = TG_UdpSocket->writeDatagram(Data, mmmmm , 9998);
            TG_UdpSocket->flush();
            //if (SendResult>0)  break;

        //}
    PackCount++;
    //}

std::cout << "PackCount " << PackCount << std::endl;
}

void TG_UDP_Control::Start_UDP_Control()
{
    TG_UdpSocket = new QUdpSocket(this);
    TG_UdpSocket->bind(3000);
    TG_UdpSocket->setPauseMode(TG_UdpSocket->PauseNever);
    connect(TG_UdpSocket, SIGNAL(readyRead()), this, SLOT(Read_UDP_Data()));
}

void TG_UDP_Control::Read_UDP_Data()
{
Counter++;


QHostAddress senderAddress;
quint16 senderPort;
while (TG_UdpSocket->hasPendingDatagrams())
{
    unsigned int Size=(unsigned int)TG_UdpSocket->pendingDatagramSize();
    TG_UdpSocket->readDatagram(UDP_Buffer.data(), Size ,&senderAddress, &senderPort);
    //signed short *DataPointer   =(signed short*)UDP_Buffer.data();
    //signed int   *DataPointerAPD=(signed int*  )UDP_Buffer.data();

    if (senderPort==9998)
    {

        //emit UDP_IQ_SignalRxReady();
    } else if (senderPort==9999)
    {
    TG_Counter++;
    //emit  TG_Pack_Received(TG_Counter);
    }
};

}

