// canreader.h
#ifndef CANREADER_H
#define CANREADER_H

#include <QObject>
#include <QtSerialBus/QCanBusDevice>

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

private:
    QCanBusDevice *m_device = nullptr;
    int m_speed = 0;
};

#endif // CANREADER_H
