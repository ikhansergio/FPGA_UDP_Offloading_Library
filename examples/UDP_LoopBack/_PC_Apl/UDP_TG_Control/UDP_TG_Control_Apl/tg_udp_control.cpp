#include "tg_udp_control.h"
#include <iostream>

TG_UDP_Control::TG_UDP_Control(QObject *parent): QObject(parent)
{

}

TG_UDP_Control::~TG_UDP_Control()
{
    TG_UdpSocket->close();
}


void TG_UDP_Control::Send_UDP_Data(QByteArray Data)
{
    QHostAddress mmmmm;
    mmmmm.setAddress("192.168.0.92");
    qint64 SendResult=0;
    for (int i=0;i<10; i++)
    {
        SendResult = TG_UdpSocket->writeDatagram(Data, mmmmm , 9999);
        if (SendResult>0) return;
    }
}

void TG_UDP_Control::Send_UDP_Data2(QByteArray Data)
{

    QHostAddress mmmmm;
    mmmmm.setAddress("192.168.0.92");
    qint64 SendResult=0;

    unsigned int index =0;

    unsigned int PackCount =0;


    for (int j=0;j<1000000; j++)
    {

       if (index==0) QThread::msleep(10);
       index++;
       if (index>100)index=0;

       *reinterpret_cast<unsigned int*> (Data.data())  = PackCount;

        for (int i=0;i<10000; i++)
        {

            SendResult = TG_UdpSocket->writeDatagram(Data, mmmmm , 9998);
            TG_UdpSocket->flush();
            if (SendResult>0)  break;

        }
    PackCount++;
    }

std::cout << "PackCount " << PackCount << std::endl;
}

void TG_UDP_Control::Start_UDP_Control()
{
    TG_UdpSocket = new QUdpSocket(this);
    TG_UdpSocket->bind(3000);
    TG_UdpSocket->setPauseMode(TG_UdpSocket->PauseNever);
}
