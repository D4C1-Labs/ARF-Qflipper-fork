import QtQuick 2.15
import QtQuick.Controls 2.15

import Theme 1.0
import QFlipper 1.0

CustomDialog {
    id: control

    closable: true
    invertTitle: true
    title: qsTr("ARF Firmware — commit history")

    onOpened: Backend.refreshArfCommitLog()

    contentWidget: Item {
        implicitWidth: control.width - 70
        implicitHeight: control.height - 160

        BusyIndicator {
            id: busy
            anchors.centerIn: parent
            running: Backend.arfCommitsRefreshing
            visible: Backend.arfCommitsRefreshing
            width: 48
            height: 48
        }

        ScrollView {
            id: scroll
            anchors.fill: parent
            visible: !Backend.arfCommitsRefreshing
            clip: true

            ListView {
                id: listView
                model: Backend.arfCommitLog
                spacing: 12

                delegate: Column {
                    width: listView.width
                    spacing: 4

                    Text {
                        width: parent.width
                        text: model.message
                        color: Theme.color.bluepurple1
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                    }
                    Text {
                        width: parent.width
                        text: "%1 — %2".arg(model.author).arg(model.date)
                        color: Theme.color.bluepurple3
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.color.bluepurple5
                        visible: index < listView.count - 1
                    }
                }
            }
        }

        Label {
            anchors.centerIn: parent
            visible: !Backend.arfCommitsRefreshing && listView.count === 0
            text: qsTr("No data (check your internet connection)")
            color: Theme.color.bluepurple2
            wrapMode: Text.WordWrap
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
