// canreader.cpp
#include "canreader.h"
#include <QCanBus>
#include <QCanBusFrame>
#include <QDebug>
#include <cmath>

CanReader::CanReader(QObject* parent)
    : QObject(parent)
{
    auto instance = QCanBus::instance();
    qDebug() << "Available CAN plugins:" << instance->plugins();

    m_device = instance->createDevice("socketcan", "can1", nullptr);
    if (!m_device) {
        qFatal("❌ Cannot create CAN device. Check plugin name.");
    }

    if (!m_device->connectDevice()) {
        qFatal("❌ Failed to connect CAN device: %s",
               qPrintable(m_device->errorString()));
    }
    qDebug() << "✅ CAN device connected on can1";

    connect(m_device, &QCanBusDevice::framesReceived,
            this, &CanReader::handleFrames);

    //////////////////////////////////////
    m_zeroTimer.setInterval(100);		//100ms 간격으로 체크
    connect(&m_zeroTimer, &QTimer::timeout,
	    this, &CanReader::checkTimeout);
    m_lastInputTimer.start();
    m_zeroTimer.start();
    /*
    m_resumeTimer.setSingleShot(true);
    m_resumeTimer.setInterval(800);
    connect(&m_resumeTimer, &QTimer::timeout,
	    this,[&](){
		m_paused = false;
	    });
    */////////////////////////////////////
}

void CanReader::handleFrames()
{
    //if(m_paused) return;

    const auto frames = m_device->readAllFrames();
    for (const QCanBusFrame &f : frames) {
        // Qt5 hex 모드: Qt::hex / Qt::dec
        qDebug() << "Received frame ID="
                 << Qt::hex << f.frameId()
                 << Qt::dec
                 << "payload=" << f.payload().toHex();

        // Arduino가 0x100 ID로 2바이트 속도 보내는 경우
        if (f.frameId() == 0x631 && f.payload().size() >= 2) {
            m_lastInputTimer.restart();

	    const auto &b = f.payload();
            int raw = (quint8(b[0]) << 8) | quint8(b[1]);
            double rawSpeed = (raw * 0.01);

	    if(rawSpeed > 0.01) m_lastInputTimer.restart();

	    if(rawSpeed <= 5.0) m_ema = 0.0;
	    else if(rawSpeed < m_ema-10.0) m_ema = 0.0;
	    else m_ema = m_alpha * m_ema + (1.0 - m_alpha) * rawSpeed;

	    int newSpeed = qRound(m_ema);

	    if (newSpeed != m_speed) {
                m_speed = newSpeed;
                emit speedChanged();
            }
        }
    }
}

void CanReader::checkTimeout()
{
    //x초 넘게 입력이 없었다면 즉시 0으로
    if (m_lastInputTimer.hasExpired(1000)) {
	m_ema = 0.0;
	if(m_speed != 0){
	    m_speed = 0;
	    emit speedChanged();
	}
	//m_paused = true;
	//m_resumeTimer.start();
    }
}
