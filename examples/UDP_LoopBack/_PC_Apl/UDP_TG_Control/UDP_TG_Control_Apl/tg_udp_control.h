#ifndef TG_UDP_CONTROL_H
#define TG_UDP_CONTROL_H

#include <QObject>
#include <QUdpSocket>
#include <QByteArray>
#include <QThread>

class TG_UDP_Control : public QObject
{
    Q_OBJECT
public:
    QUdpSocket *TG_UdpSocket;
    TG_UDP_Control(QObject *parent = 0);
    ~TG_UDP_Control();

    void Start_UDP_Control(void);

    int Counter =0;
    int TG_Counter =0;

signals:
    void TG_Pack_Received(int index);

private:
    QByteArray UDP_Buffer;

public slots:
    void Send_UDP_Data(QByteArray Data);
    void Send_UDP_Data2(QByteArray Data);
    void Read_UDP_Data();
};

#endif // TG_UDP_CONTROL_H
