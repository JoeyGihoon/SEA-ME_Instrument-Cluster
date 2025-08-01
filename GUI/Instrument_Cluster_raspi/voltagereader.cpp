#include "voltagereader.h"
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <unistd.h>
#include <cmath>
#include <QDebug>

static constexpr double MULTIPLIER = 5.76;  // 분압비 보정
static constexpr double EPS        = 0.02;  // 20 mV 변화만 반영

VoltageReader::VoltageReader(QObject* parent)
    : QObject(parent)
{
    // 1) open & select
    m_fd = open(I2C_DEV, O_RDWR);
    if (m_fd < 0 || ioctl(m_fd, I2C_SLAVE, I2C_ADDR) < 0) {
        qWarning() << "I2C open/select failed";
        m_fd = -1;
        return;
    }
    connect(&m_timer, &QTimer::timeout, this, &VoltageReader::sampleVoltage);
    m_timer.start(500);
}

void VoltageReader::sampleVoltage()
{
    if (m_fd < 0) return;

    // 2) 구성 레지스터에 MSB/LSB 직접 쓰기
    //    pointer=0x01, value = 0xE383 (AIN2, ±4.096V, single-shot)
    uint8_t buf[3] = { 0x01, 0xE3, 0x83 };
    if (write(m_fd, buf, 3) != 3) {
        qWarning() << "I2C write config failed";
        return;
    }
    usleep(8000);

    // 3) 변환 레지스터(0x00) 읽기
    uint8_t ptr = 0x00;
    if (write(m_fd, &ptr, 1) != 1) {
        qWarning() << "I2C set pointer failed";
        return;
    }
    uint8_t data[2];
    if (read(m_fd, data, 2) != 2) {
        qWarning() << "I2C read failed";
        return;
    }

    // 4) 값 계산
    int16_t raw = (data[0] << 8) | data[1];
    double adcV = raw * 4.096 / 32768.0;
    double battV = adcV * MULTIPLIER;

    if (std::fabs(battV - m_voltage) > EPS) {
        m_voltage = battV;
        emit voltageChanged();
        qDebug() << "Voltage changed to:" << battV;
    }
}
