import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 1280
    height: 400
    property real value: 0    // 외부에서 필요 시 사용

    // -------------------- 속도계 --------------------
    Image {
        id: speedGauge
        source: "/images/dial.png"
        scale: 1.2
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -350

        // 바늘 피벗 (다이얼 중심)
        Item {
            id: speedPivot
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            // 0~240 km/h  =>  -135° ~ +135°
            rotation: (canReader.speed / 240) * 270 - 135

            Image {
                id: speedNeedle
                source: "/images/needle.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height * 0.28   // 핀 위치 보정
                width: parent.width * 0.05
                height: parent.height * 0.45
            }
        }

        // 속도 숫자 표시
        Text {
            id: speedText
            text: canReader.speed + " cm/s"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 30
            font.pixelSize: 20
            color: "#7C9392"
        }
    }

    // -------------------- 배터리 잔량 --------------------
    Image {
        id: batteryGauge
        source: "/images/dial.png"
        scale: 1.2
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 350
        transform: Rotation {
            origin.x: batteryGauge.width / 2
            origin.y: batteryGauge.height / 2
            angle: 180
        }

        // 바늘 피벗
        Item {
            id: batteryPivot
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            rotation: (canReader.battery / 100) * 270 - 135   // 0~100% 매핑

            Image {
                id: batteryNeedle
                source: "/images/needle.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height * 0.28
                width: parent.width * 0.05
                height: parent.height * 0.45
            }
        }
    }

    // 배터리 텍스트
    Text {
        id: batteryText
        text: canReader.battery + "%"
        anchors.centerIn: batteryGauge
        anchors.horizontalCenterOffset: -30
        anchors.verticalCenterOffset: 30
        font.pixelSize: 20
        color: "#7C9392"
    }

    // -------------------- 가운데 디스플레이 --------------------
    Image {
        id: display
        source: "/images/dial.png"
        scale: 1.5
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        transform: Rotation {
            origin.x: display.width / 2
            origin.y: display.height / 2
            angle: 90
        }
    }

    // -------------------- 차량 이미지 --------------------
    Image {
        id: car_back
        source: "/images/car_back.png"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 90
    }
    Image {
        id: car_highlight
        source: "/images/car-highlights.png"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 90
        z: 2
    }
}
