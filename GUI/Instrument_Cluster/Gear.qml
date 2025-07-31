import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: gearIndicator
    property string gear: "N"    // "D", "R", "N" 중 하나

    width: 100; height: 100

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }
    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -50
        text: gear
        font.pixelSize: 120
        font.bold: true
        color: "white"
    }
}
