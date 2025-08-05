import QtQuick 2.15
import QtQuick.Controls 2.15
Item {
    id: centerGauge
    property string gearState: "N"

    // 주기적으로 /status 호출
    Timer {
        interval: 1000    // 100ms
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "http://192.168.86.54:5000/status")  // Flask 서버 주소
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        try {
                            var resp = JSON.parse(xhr.responseText)
                            gearState = resp.gear
                        } catch(e) {
                            console.warn("Failed to parse /status response:", e)
                        }
                    } else {
                        //console.warn("/status returned", xhr.status)
                    }
                }
            }
            xhr.send()
        }
    }
   
    Image{
	id: dial
	source: "/images/dial.png"
	anchors.centerIn: parent
	anchors.verticalCenterOffset: 50
	scale: 1.5
	rotation: 90
    }

    Rectangle {
        id: gearDisplay
        width: 150; height: 150
        radius: 75
        anchors.centerIn: parent
        color: "transparent"
        Text {
            anchors.centerIn: parent
            text: gearState === "D"
		 ? "D"
		 : (gearState === "R" ? "R" : "N")
            font.pixelSize: 96; font.bold: true
            color: gearState === "D" ? "#00FF70" : (gearState === "R" ? "#FF5050" : "#E0E0E0")
        }
    }
}
