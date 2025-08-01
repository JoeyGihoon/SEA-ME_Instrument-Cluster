import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 1280; height: 400

    /* -------- 실시간 상태 (Python 백엔드 → Flask) -------- */
    property real  batteryVoltage: 0   // /status.voltage (V)
    property string gearState: "N"     // /status.gear (F/R/N)

    /* 1초마다 192.168.86.54:5000/status 호출해 전압·기어 갱신 */
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "http://192.168.86.54:5000/status");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    var obj = JSON.parse(xhr.responseText);
                    root.batteryVoltage = obj.voltage;
                    root.gearState      = obj.gear;
                }
            }
            xhr.send();
        }
    }

    /* ================= 속도 게이지 (Arduino → CAN → canReader.speed) ================= */
    Image {
        id: speedGauge
        source: "qrc:/images/dial.png"
        scale: 1.2
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -350

        Item {
            anchors.centerIn: parent
            width: parent.width; height: parent.height
            rotation: (canReader.speed / 300) * 270 - 135      // 0~300 cm/s 매핑
            Image {
                source: "qrc:/images/needle-normal.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height * 0.28
                width: parent.width * 0.05
                height: parent.height * 0.45
            }
        }
        Text {
            text: Math.round(canReader.speed) + " cm/s"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 30
            font.pixelSize: 20; color: "#7C9392"
        }
    }

    /* ================= 배터리 게이지 ================= */
    Image {
        id: batteryGauge
        source: "qrc:/images/dial.png"
        scale: 1.2
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 350
        transform: Rotation { origin.x: width/2; origin.y: height/2; angle: 180 }
    }

    Item {
        anchors.centerIn: batteryGauge
        width: batteryGauge.width; height: batteryGauge.height
        rotation: {
            const minV = 10, maxV = 13;
            var v = Math.max(minV, Math.min(maxV, batteryVoltage));
            return ((v - minV)/(maxV - minV))*270 - 135;
        }
        Image {
            source: "qrc:/images/needle-normal.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: parent.height * 0.28
            width: parent.width * 0.05
            height: parent.height * 0.45
        }
    }

    Text {
        text: batteryVoltage.toFixed(2) + " V"
        anchors.centerIn: batteryGauge
        anchors.verticalCenterOffset: 30
        font.pixelSize: 20; color: "#7C9392"
    }

    /* ================= 기어 표시 (센터) ================= */
    Rectangle {
        id: gearDisplay
        width: 150; height: 150; radius: 75
        anchors.centerIn: parent
        color: "#333333"
        Text {
            anchors.centerIn: parent
            text: gearState
            font.pixelSize: 96; font.bold: true
            color: gearState === "F" ? "#00FF70" : (gearState === "R" ? "#FF5050" : "#E0E0E0")
        }
    }

    /* (차량 이미지·기타 요소 원본대로 유지) */
    Image { source: "qrc:/images/car_back.png"; anchors.centerIn: parent; anchors.verticalCenterOffset: 90 }
    Image { source: "qrc:/images/car-highlights.png"; anchors.centerIn: parent; anchors.verticalCenterOffset: 90; z: 2 }
}
