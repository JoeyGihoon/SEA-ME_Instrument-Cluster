import QtQuick 2.15

Item {
    id: batteryGauge
    width: 200; height: 200

    // 배터리 프로퍼티 (0~maxSpeed)
    property int minBat: 0
    property int maxBat: 100

    // 회전 각도 범위
    property real minAngle: 0
    property real maxAngle: 180

    // 배터리 바늘
    Item{
        id: needleContainer
        width: needle.implicitWidth
        height: needle.implicitHeight
        x: 443  // 필요시 오프셋 조정
        y: -72      // 필요시 오프셋 조정
        antialiasing: true  //이미지 렌더링 시 경계선을 부드럽게 처리(계단 현상 최소화)
        transform: Rotation {
            id: needleRotation
            origin.x: needle.width/2
            origin.y: needle.height + 95
            angle: batteryGauge.minAngle
        }

        Image{
            id: needle
            anchors.fill: parent
            antialiasing: true
            source: "qrc:/images/needle-normal.png"
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
        id: batteryText
        text: batteryGauge.level
        x: 380; y: 50

        font.pixelSize: 64
        font.bold: true
        color: "white"
    }

    // 배터리 변경 시 바늘 회전
    Connections {
        target: batteryController
        function onLevelChanged() {
            var ratio = batteryController.level / batteryGauge.maxBat;
            // minAngle → maxAngle 선형 매핑
            var newAngle = batteryGauge.minAngle + ratio * (batteryGauge.maxAngle - batteryGauge.minAngle);
            needleRotation.angle = newAngle;
            batteryText.text = batteryGauge.maxBat - batteryController.level + "%"
            // 레벨 기준으로 색상 변경
            if (batteryGauge.maxBat - batteryController.level <= 10) {
                batteryText.color = "red";
            } else if (batteryGauge.maxBat - batteryController.level >= 80) {
                batteryText.color = "lime";
            } else {
                batteryText.color = "white";
            }
        }
    }
}
