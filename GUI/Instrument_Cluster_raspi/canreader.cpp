// canreader.cpp
#include "canreader.h"
#include <QCanBus>
#include <QCanBusFrame>
#include <QDebug>

CanReader::CanReader(QObject* parent)
    : QObject(parent)
{
    auto instance = QCanBus::instance();
    qDebug() << "Available CAN plugins:" << instance->plugins();

    m_device = instance->createDevice("socketcan", "can1", nullptr);
    if (!m_device) {
        qFatal("❌ Cannot create CAN device. Check plugin name.");
    }

    // ❌ bitrate 설정 코드는 외부에서 처리하므로 제거했습니다.

    if (!m_device->connectDevice()) {
        // ⚠ qFatal은 printf 스타일이므로, %s + qPrintable()
        qFatal("❌ Failed to connect CAN device: %s",
               qPrintable(m_device->errorString()));
    }
    qDebug() << "✅ CAN device connected on can1";

    connect(m_device, &QCanBusDevice::framesReceived,
            this, &CanReader::handleFrames);
}

void CanReader::handleFrames()
{
    const auto frames = m_device->readAllFrames();
    for (const QCanBusFrame &f : frames) {
        // Qt5 hex 모드: Qt::hex / Qt::dec
        qDebug() << "Received frame ID="
                 << Qt::hex << f.frameId()
                 << Qt::dec
                 << "payload=" << f.payload().toHex();

        // Arduino가 0x100 ID로 2바이트 속도 보내는 경우
        if (f.frameId() == 0x631 && f.payload().size() >= 2) {
            const auto &b = f.payload();
            int raw = (quint8(b[0]) << 8) | quint8(b[1]);
            int newSpeed = qRound(raw * 0.01);
            if (newSpeed != m_speed) {
                m_speed = newSpeed;
                emit speedChanged();
            }
        }
    }
}
