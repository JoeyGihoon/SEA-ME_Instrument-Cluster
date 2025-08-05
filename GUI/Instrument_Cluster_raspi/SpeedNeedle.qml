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
            rotation: (canReader.speed / 240) * 270 + 5
	    
	    Behavior on rotation {
		/*NumberAnimation {
		duration: 150  // 속도 조절 가능 (ms)
		easing.type: Easing.InOutQuad
		}*/
		SpringAnimation {
		spring:3
		damping:0.4
		}
	    }

            Image {
                id: speedNeedle
                source: "/images/needle-normal.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height * 0.28   // 핀 위치 보정
                width: parent.width * 0.05
                height: parent.height * 0.45

		rotation: 180
		scale: 0.8
            }
            Image {
		id: highlightNeedle
		source: "/images/highlight-needle.png"
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: speedNeedle.top
		//anchors.verticalCenterOffset: parent.height * 0.28  // 동일한 피벗 위치
		anchors.verticalCenterOffset: 128
		rotation: 180
		width: parent.width * 0.2
		height: parent.height * 0.12
		
		z: 4 
	     }
	}

        // 속도 숫자 표시
	Text {
	    id: speedText1
            text: canReader.speed
	    anchors.centerIn: parent
	    font.pixelSize: 64
	    color: "white"
	}
        Text {
            id: speedText
            text: " cm/s"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 40
            font.pixelSize: 20
            color: "#7C9392"
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



