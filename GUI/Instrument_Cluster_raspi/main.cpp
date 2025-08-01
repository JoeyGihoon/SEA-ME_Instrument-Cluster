#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QObject>
#include "timeprovider.h"
#include "canreader.h"
class SpeedProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)
public:
    SpeedProvider(QObject *parent = nullptr)
        : QObject(parent), m_speed(0), m_step(5)
    {
        auto timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &SpeedProvider::updateSpeed);
        timer->start(50);
    }

    int speed() const { return m_speed; }

signals:
    void speedChanged(int newSpeed);

private slots:
    void updateSpeed() {
        m_speed += m_step;
        if (m_speed >= 180) {
            m_speed = 180;
            m_step = -m_step;
        } else if (m_speed <= 0) {
            m_speed = 0;
            m_step = -m_step;
        }
        emit speedChanged(m_speed);
    }

private:
    int m_speed;
    int m_step;
};

class BatteryProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(int level READ level NOTIFY levelChanged)
public:
    BatteryProvider(QObject *parent = nullptr)
        : QObject(parent), m_level(0), m_step(5)
    {
        auto timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &BatteryProvider::updateLevel);
        timer->start(100);
    }

    int level() const { return m_level; }

signals:
    void levelChanged(int newLevel);

private slots:
    void updateLevel() {
        m_level += m_step;
        if (m_level >= 100) {
            m_level = 100;
            m_step = -m_step;
        } else if (m_level <= 0) {
            m_level = 0;
            m_step = -m_step;
        }
        emit levelChanged(m_level);
    }

private:
    int m_level;
    int m_step;
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    CanReader can;
    
    // C++ 객체를 QML에 등록
   // SpeedProvider speedProvider;
    engine.rootContext()->setContextProperty("canReader", &can);

    BatteryProvider batteryProvider;
    engine.rootContext()->setContextProperty("batteryController", &batteryProvider);

    TimeProvider timeProvider;
    engine.rootContext()->setContextProperty("timeProvider", &timeProvider);

    // Main.qml 로드
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && objUrl == url)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}

#include "main.moc"
