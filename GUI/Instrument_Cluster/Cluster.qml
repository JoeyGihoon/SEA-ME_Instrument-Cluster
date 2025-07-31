import QtQuick 2.15

Item {
    id: root
    width: 1280; height: 400
    property real value: 0

    // 속도계
    Image {
        id: speedGauge
        source: "/images/dial.png"
        scale: 1.2
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -350
        Text {
            id: speedText
            text: " cm/s"
            anchors.centerIn: speedGauge
            //anchors.horizontalCenterOffset: 5
            anchors.verticalCenterOffset: 30
            font.pixelSize: 20; color: "#7C9392"
        }

    }

    // 배터리 잔량 표시
    Image {
        id: batteryGauge
        source: "/images/dial.png"
        scale: 1.2
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 350
        transform: Rotation {
            origin.x: batteryGauge.width  / 2
            origin.y: batteryGauge.height / 2
            angle: 180
        }
    }
    Text {
        id: batteryText
        text: "Battery"
        anchors.centerIn: batteryGauge
        anchors.horizontalCenterOffset: -30
        anchors.verticalCenterOffset: 30
        font.pixelSize: 20; color: "#7C9392"
    }

    //가운데 디스플레이
    Image {
        id: display
        source: "/images/dial.png"
        scale: 1.5
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        transform: Rotation {
            origin.x: batteryGauge.width  / 2
            origin.y: batteryGauge.height / 2
            angle: 90
        }
    }

    //차
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
        z:2
    }

}
