import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root //
    width: 200; height: 200

    /* -------- 실시간 상태 (Python Flask /status) -------- */
    property real    batteryVoltage: 0   // obj.voltage
    property string  gearState: "N"     // obj.gear (F/R/N)

    /* 1초마다 전압·기어 갱신 */
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "http://192.168.86.54:5000/status")
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    var obj = JSON.parse(xhr.responseText)
                    batteryVoltage = obj.voltage
                    gearState      = obj.gear
                }
            }
            xhr.send()
        }
    }

    // 외부에서 주입할 배터리 전압 (V)
    property real level: 0

    // 측정 범위 (예: 10~13V)
    property real minBat: 10
    property real maxBat: 12.5

    // 회전 각도 범위 (0V->-135°, max->+135°)
    property real minAngle: -135
    property real maxAngle: 135
    
    // 배경 다이얼
    Image {
        id: dial
        source: "qrc:/images/dial.png"
        //anchors.fill: parent
	scale: 1.2
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 350
	rotation: 180
    }

    // 바늘 중심 회전 컨테이너
    Item {
        anchors.centerIn: dial
        width: dial.width; height: dial.height
        rotation: {
            var v = Math.max(minBat, Math.min(maxBat, batteryVoltage));
            return -180 * ((v - minBat)/(maxBat - minBat));
	    //return ((v - minBat)/(maxBat - minBat)) * (minAngle - maxAngle) + maxAngle;
        }
        // 바늘 이미지
        Image {
	    id:batteryNeedle
            source: "qrc:/images/needle-normal.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: parent.height * 0.28
            width: parent.width * 0.05
            height: parent.height * 0.45
	    rotation: 180
        }
	Image {
            id: highlightNeedle
            source: "/images/highlight-needle.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: batteryNeedle.top
            anchors.verticalCenterOffset: 157 //조정 필요
            rotation: 180
            width: parent.width * 0.2
            height: parent.height * 0.13
            z:4
        }
    }
    Text {
        id: batteryText
        text: (batteryVoltage.toFixed(2)*40-400).toFixed(0) + "%"
        anchors.centerIn: dial
        //anchors.horizontalCenterOffset: -50
        //anchors.verticalCenterOffset: 40
        font.pixelSize: 64; color: "white"
    }
    Text {
        text:"battery"
        anchors.centerIn: batteryText
        anchors.verticalCenterOffset: 40
        font.pixelSize: 20; color: "#7C9392"
    }
  
}
