import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import "."
ApplicationWindow {
    visible: true
    flags: Qt.FramelessWindowHint
    visibility: Window.FullScreen
    width: 1280
    height: 400
    title: "Instrument Cluster"
    color: "black"

    property string gearState: "N"

    Timer {
        interval: 100
        repeat: true
        running: true
        onTriggered: {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "http://192.18.86.54:5000/gear")
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    gearState = xhr.responseText
                }
            }
            xhr.send()
        }
    }
    
    SpeedNeedle {
        id: speed
        anchors.centerIn: parent
        z:2
    }

    BatteryNeedle {
        id: battery
        anchors.centerIn: parent
	anchors.horizontalCenterOffset: -20
        z:2
    }

    Gear {
        id: gear
        anchors.centerIn: parent
        z:2
    }

    //time
    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            Text {
                text: timeProvider.currentDateTime || ""
                font.pixelSize: 20
                color: "#7C9392"
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 70  // 원하는 만큼 여백 조절
            }
        }
    }

    //label
    Text {
        text: "Team 5"
        font.pixelSize: 20            // 작게
        color: "white"              // 흐린 회색
        opacity: 0.4                  // 투명도 조절
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10       // 좌측 여백
        anchors.topMargin: 10        // 상단 여백
        z:10
    }
    Image{
        id: seame
        visible: true
        scale: 0.05
        opacity: 0.4                  // 투명도 조절
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: -970       // 좌측 여백
        anchors.bottomMargin: -150        // 상단 여백
        source: "qrc:/images/sea_me_white_text.png"
        z:10
    }
}
