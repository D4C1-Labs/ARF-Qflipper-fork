import QtQuick 2.15
import QtQuick.Layouts 1.15

import Theme 1.0

Item {
    id: root
    width: parent ? parent.width : 280
    implicitHeight: column.implicitHeight + 20
    implicitWidth: 280

    ColumnLayout {
        id: column
        width: parent.width
        spacing: 8

        TextLabel {
            id: titleLabel
            text: qsTr("OmniCore Firmware")
            font.family: "Born2bSportyV2"
            font.pixelSize: 26
            color: Theme.color.lightred4
            capitalized: false
            elide: Text.ElideNone
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.maximumWidth: column.width
            Layout.alignment: Qt.AlignHCenter
        }

        TextLabel {
            id: subtitle1
            text: qsTr("Custom OmniCore-Flipper Build")
            font.pixelSize: 14
            color: Theme.color.bluepurple2
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideNone
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.maximumWidth: column.width
            Layout.alignment: Qt.AlignHCenter
        }

        TextLabel {
            text: qsTr("Made By Amau_Zero for OmniCore Firmware")
            font.pixelSize: 12
            color: Theme.color.bluepurple1
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideNone
            Layout.fillWidth: true
            Layout.maximumWidth: column.width
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
