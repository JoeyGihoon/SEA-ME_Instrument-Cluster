#pragma once
#include <QObject>
#include <QTimer>

class VoltageReader : public QObject {
    Q_OBJECT
    Q_PROPERTY(double voltage READ voltage NOTIFY voltageChanged)
public:
    VoltageReader(QObject* parent = nullptr);
    double voltage() const { return m_voltage; }
signals:
    void voltageChanged();
private slots:
    void sampleVoltage();
private:
    int     m_fd = -1;
    double  m_voltage = 0.0;
    QTimer  m_timer;
    static constexpr int   I2C_ADDR = 0x41;  // ADS1115 기본 주소
    static constexpr const  char* I2C_DEV  = "/dev/i2c-1";
};
