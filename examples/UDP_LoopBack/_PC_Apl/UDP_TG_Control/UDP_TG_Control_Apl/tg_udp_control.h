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


public slots:
    void Send_UDP_Data(QByteArray Data);
    void Send_UDP_Data2(QByteArray Data);
};

#endif // TG_UDP_CONTROL_H
