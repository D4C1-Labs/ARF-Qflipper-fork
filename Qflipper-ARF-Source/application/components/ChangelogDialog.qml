import QtQuick 2.15
import QtQuick.Controls 2.15

import Theme 1.0
import QFlipper 1.0

CustomDialog {
    id: control

    closable: true
    invertTitle: true
    title: qsTr("ARF LAST DEV")

    contentWidget: Item {
        implicitWidth: control.width - 70
        implicitHeight: control.height - 160

        Column {
            anchors.fill: parent
            spacing: 10

            Text {
                width: parent.width
                text: qsTr("First Release")
                color: Theme.color.bluepurple1
                wrapMode: Text.WordWrap
                font.pixelSize: 18
                font.bold: true
            }

            Text {
                width: parent.width
                text: qsTr("ARF LAST DEV build")
                color: Theme.color.bluepurple2
                wrapMode: Text.WordWrap
                font.pixelSize: 13
            }

            Text {
                width: parent.width
                text: qsTr("Stability fixes, clean branding, secure web installer delivery.")
                color: Theme.color.bluepurple3
                wrapMode: Text.WordWrap
                font.pixelSize: 12
            }
        }
    }
}
