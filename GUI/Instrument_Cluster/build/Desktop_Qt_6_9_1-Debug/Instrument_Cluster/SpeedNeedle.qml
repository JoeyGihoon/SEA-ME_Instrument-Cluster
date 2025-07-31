import QtQuick 2.15

Item {
    id: speedGauge
    width: 200; height: 200

    // 속도 프로퍼티 (0~maxSpeed)
    property int speed: 0
    property int maxSpeed: 180

    // 회전 각도 범위
    property real minAngle: 180
    property real maxAngle: 0

    // 속도 바늘
    Item{
        id: needleContainer
        width: needle.implicitWidth
        height: needle.implicitHeight
        x: -255  // 필요시 오프셋 조정
        y: -71      // 필요시 오프셋 조정
        antialiasing: true  //이미지 렌더링 시 경계선을 부드럽게 처리(계단 현상 최소화)
        transform: Rotation {
            id: needleRotation
            origin.x: needle.width/2
            origin.y: needle.height + 95
            angle: -speedGauge.minAngle
        }

        Image{
            id: needle
            source: "qrc:/images/needle-normal.png"
            anchors.fill: parent
            antialiasing: true
        }
        Image {
            id: highlight
            source: "qrc:/images/highlight-needle.png"
            antialiasing: true
            // 바늘 끝(컨테이너 상단 중앙)에 표시
            x: (parent.width - width)/2
            y: -height/2
        }
    }

    Text {
        id: speedText
        text: speedGauge.speed
        x: -280; y: 50

        font.pixelSize: 64
        font.bold: true
        color: "white"
    }

    // 속도 변경 시 바늘 회전
    Connections {
        target: speedController
        function onSpeedChanged() {
            var ratio = speedController.speed / speedGauge.maxSpeed;
            var newAngle = speedGauge.minAngle + ratio * (speedGauge.minAngle - speedGauge.maxAngle);
            needleRotation.angle = newAngle;
            speedText.text = speedController.speed
        }
    }
}
