// canreader.h
#ifndef CANREADER_H
#define CANREADER_H

#include <QObject>
#include <QtSerialBus/QCanBusDevice>
#include <QTimer>
#include <QElapsedTimer>

class CanReader : public QObject {
    Q_OBJECT
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)
public:
    explicit CanReader(QObject* parent = nullptr);
    int speed() const { return m_speed; }

signals:
    void speedChanged();

private slots:
    void handleFrames();
    void checkTimeout();
private:
    QCanBusDevice *m_device = nullptr;
    int m_speed = 0;
    bool m_paused = false;              //중단 상태 플래그
    QTimer m_resumeTimer;

    //EMA filter
    double m_alpha = 0.2;		//EMA 계수(0<α<1)
    double m_ema = 0.0;			//EMA 상태

    //타임아웃 검사
    QTimer m_zeroTimer;			//주기적 체크 타이머
    QElapsedTimer m_lastInputTimer;	//마지막 입력 시간 기록
};

#endif // CANREADER_H
