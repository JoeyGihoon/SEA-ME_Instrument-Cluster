// OtherScreen.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import "."

Item {
    id: other
    objectName: "OtherScreen"
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.9
    }

    // 예시: 기존 C++ 객체 사용 (context property로 등록되어 있다면)
    // Text { text: canReader.lastSpeed; color: "white"; anchors.centerIn: parent }

    Button {
        text: "Back"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        onClicked: stackView.pop()
	z:999
        visible: false
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
        z:999
	fillMode: Image.PreserveAspectFit
        MouseArea {
            anchors.fill: parent
            preventStealing: true
	    onClicked: stackView.pop()
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    /*property string backendURL: "http://192.168.86.22:5000"  // ← Pi의 실제 IP/포트

    function setMode(m) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", backendURL + "/mode")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.send(JSON.stringify({ mode: m }))
    }

    // 페이지가 켜질 때 madmax, 닫힐 때 normal
    Component.onCompleted: setMode("madmax")
    Component.onDestruction: setMode("normal")
    */
    
    SpeedNeedle_madmax {
	id: speed_mm
	anchors.centerIn: parent
	z:2
    }    

    BatteryNeedle_madmax {
	id: battery_mm
	anchors.centerIn: parent
        anchors.horizontalCenterOffset: -20
        z:2
    }

    Image {
	id: immotan
	source: "qrc:/images/immotan_.png"
	anchors.centerIn: parent
	//anchors.horizontalCenterOffset: offsetX
        scale: 1.5
	z:4
    }

    FontLoader {
        id: customFont
        source: "qrc:/fonts/MadHomie-K7RPA.ttf"
    }

    Text {
        text: "Maxmax mode activated"
        font.family: customFont.name
	anchors.centerIn: parent
	anchors.verticalCenterOffset: 170
        font.pixelSize: 32
        color: "yellow"
	z:5
    }

    Row {
        id: iconBar
        spacing: 40
        z: 5
        anchors.horizontalCenter: immotan.horizontalCenter
        anchors.bottom: immotan.top
        anchors.bottomMargin: 40

        property int iconSize: 40

        Image {
            source: "qrc:/icons/search_.png"
            sourceSize.width: iconBar.iconSize
            sourceSize.height: iconBar.iconSize
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Image {
            source: "qrc:/icons/home_.png"
            sourceSize.width: iconBar.iconSize
            sourceSize.height: iconBar.iconSize
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Image {
            source: "qrc:/icons/menu_.png"
            sourceSize.width: iconBar.iconSize
            sourceSize.height: iconBar.iconSize
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Image {
            source: "qrc:/icons/close_.png"
            sourceSize.width: iconBar.iconSize
            sourceSize.height: iconBar.iconSize
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }    
}
