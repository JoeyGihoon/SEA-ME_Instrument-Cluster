// BatteryNeedle_Madmax.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 200
    height: 200

    property real    batteryVoltage: 0
    property string  gearState: "N"

    property real minBat: 10
    property real maxBat: 12.5

    // 배치/표시 옵션
    property real scaleFactor: 0.6    // 다이얼/게이지 스케일
    property int  offsetX: 370        // 오른쪽 이동량
    property bool mirror: true        // 좌우 반전

    function fracFromVoltage(v) {
        if (maxBat <= minBat) return 0;
        var vv = Math.max(minBat, Math.min(maxBat, v));
        return (vv - minBat) / (maxBat - minBat); // 0~1
    }
    function lerp(a,b,t){ return a + (b-a)*t; }
    function colorForFraction(f) {
        f = Math.max(0, Math.min(1, f));
        if (f <= 0.5) {
            var t = f / 0.5;
            var r = Math.round(lerp(0,   255, t));
            return "rgb(" + r + ",255,0)";
        } else {
            var t2 = (f - 0.5) / 0.5;
            var g2 = Math.round(lerp(255, 0, t2));
            return "rgb(255," + g2 + ",0)";
        }
    }

    // 1초마다 값 갱신
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "http://192.168.86.22:5000/status");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    var obj = JSON.parse(xhr.responseText);
                    batteryVoltage = obj.voltage;
                    gearState      = obj.gear;
                }
            }
            xhr.send();
        }
    }

    // 배경 다이얼
    Image {
        id: dial
        source: "qrc:/images/Madmax_dial_mirror.png"
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: offsetX
        scale: scaleFactor
        z: 0
    }
/*
    // 게이지(남에서 시작, 북이 100%, 반시계 진행)
    Canvas {
        id: gaugeCanvas
        anchors.centerIn: dial
        width:  dial.paintedWidth
        height: dial.paintedHeight
        z: 1

        // 마우스/터치 이벤트 절대 안 받게
        acceptedButtons: Qt.NoButton
        enabled: true  // 그리기는 해야 하므로 true 유지

        // 거울 모드
        transform: Scale {
            x: mirror ? -1 : 1
            origin.x: gaugeCanvas.width / 2   // ← 오타(widht) 수정
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;
            var radius  = Math.min(width, height) / 2.3;

            var startAngle = Math.PI / 2; // 남(아래)
            var sweep      = Math.PI;     // 180도(남→북)

            // 배경 원호
            ctx.beginPath();
            ctx.strokeStyle = "#333";
            ctx.lineWidth = 20;
            ctx.lineCap = "round";
            ctx.arc(centerX, centerY, radius,
                    startAngle, startAngle - sweep, true);
            ctx.stroke();

            // 채워진 원호
            var f = fracFromVoltage(batteryVoltage);
            var end = startAngle - sweep * f;

            ctx.beginPath();
            ctx.strokeStyle = colorForFraction(f);
            ctx.lineWidth = 20;
            ctx.lineCap = "round";
            ctx.arc(centerX, centerY, radius,
                    startAngle, end, true);
            ctx.stroke();
        }

        Component.onCompleted: requestPaint()
    }

    // 값 바뀌면 다시 그림
    onBatteryVoltageChanged: gaugeCanvas.requestPaint()
    onMinBatChanged: gaugeCanvas.requestPaint()
    onMaxBatChanged: gaugeCanvas.requestPaint()
*/
    // 텍스트
    Text {
        id: batteryText
        property real percent: Math.round(fracFromVoltage(batteryVoltage) * 100)
        text: percent + "%"
        anchors.centerIn: dial
        anchors.horizontalCenterOffset: -50
        font.pixelSize: 75
        color: "white"
        z: 2
    }
    Text {
        text: "battery"
        anchors.centerIn: batteryText
        anchors.verticalCenterOffset: 50
        anchors.horizontalCenterOffset: -20
        font.pixelSize: 40
        color: "#7C9392"
        z: 2
    }
}

