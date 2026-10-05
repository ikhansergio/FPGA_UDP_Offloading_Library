#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QThread>

#include "tg_udp_control.h"
#include "TG_UDP_Control_Types.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

    TG_Start_Struct TG_Start_Command;
    RequestTelemetry_Struct RequestTelemetry_Command;
private slots:
    void on_pushButton_clicked();

    void on_pushButton_2_clicked();

signals:
    void Send_UDP_Data(QByteArray Data);
    void Send_UDP_Data2(QByteArray Data);
private:
    Ui::MainWindow *ui;

    QThread *UDP_thread_0;
    TG_UDP_Control *TG_UDP_Control_Cli;

};
#endif // MAINWINDOW_H
