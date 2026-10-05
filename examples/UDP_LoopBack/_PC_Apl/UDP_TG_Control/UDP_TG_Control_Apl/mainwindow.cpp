#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "CRC32.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    UDP_thread_0 = new QThread();
    TG_UDP_Control_Cli = new TG_UDP_Control();

    TG_UDP_Control_Cli->moveToThread(UDP_thread_0);

    connect(UDP_thread_0, &QThread::started, TG_UDP_Control_Cli, &TG_UDP_Control::Start_UDP_Control,Qt::QueuedConnection);
    connect(this, &MainWindow::Send_UDP_Data, TG_UDP_Control_Cli, &TG_UDP_Control::Send_UDP_Data);
    connect(this, &MainWindow::Send_UDP_Data2, TG_UDP_Control_Cli, &TG_UDP_Control::Send_UDP_Data2);

    UDP_thread_0->start();
}

MainWindow::~MainWindow()
{
    connect(UDP_thread_0, &QThread::finished, TG_UDP_Control_Cli, &QObject::deleteLater);
    UDP_thread_0->quit();
    UDP_thread_0->wait();
    UDP_thread_0->deleteLater();

    delete ui;
}


void MainWindow::on_pushButton_clicked()
{
    static int Index=0;
    Index++;

    TG_Start_Command.CommandCode =0x1;
    TG_Start_Command.CommandParam=0x0;
    TG_Start_Command.CommandSize=sizeof(TG_Start_Command);
    TG_Start_Command.CommandUniqConstant=0xAFBEADDE;
    TG_Start_Command.CommandReserve =0;

    TG_Start_Command.PayloadMagicConstant = 0xAAAAAAAA;
    TG_Start_Command.TG_PacketSize =1024;
    TG_Start_Command.TG_PacketGap  =65500;
    TG_Start_Command.TG_PacketGap  =200;
    TG_Start_Command.TG_PacketCount  =1000000;

    for (int i=0;i<16; i++)
    {
        TG_Start_Command.DataReserve[i]= Index + i;
    }

    TG_Start_Command.DataReserve[0] =crc32_(0x0,(unsigned char *)&TG_Start_Command.CommandCode, 16);
    TG_Start_Command.HeaderCRC      =crc32_(0x0,(unsigned char *)&TG_Start_Command.CommandCode, 12);


    TG_Start_Command.FullCommandCRC=crc32_(0x0,(unsigned char *)&TG_Start_Command.CommandCode, TG_Start_Command.CommandSize-4);


    QByteArray Data = QByteArray::fromRawData( (char*)&TG_Start_Command, TG_Start_Command.CommandSize);

    emit Send_UDP_Data(Data);
}


void MainWindow::on_pushButton_2_clicked()
{
    QByteArray Data;
    Data.resize(1024);
    emit Send_UDP_Data2(Data);

}


