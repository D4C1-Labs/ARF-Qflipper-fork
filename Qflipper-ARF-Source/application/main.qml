import QtQuick 2.15
import QtQuick.Window 2.15

import QFlipper 1.0
import Theme 1.0

import "components"

Window {
    id: root
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.NoDropShadowWindowHint
    title: Qt.application.displayName

    /* Same numbers as MainWindow (baseWidth/baseHeight/shadowSize) so size does not depend on child init order. */
    readonly property int _appW: 830
    readonly property int _appH: 500
    readonly property int _shadow: 16

    width: _appW + _shadow * 2
    height: _appH + _shadow * 2

    minimumWidth: width
    minimumHeight: height

    maximumWidth: minimumWidth
    maximumHeight: minimumHeight

    color: "transparent"

    Item {
        id: stage
        anchors.fill: parent

        MainWindow {
            id: mainWindow
            opacity: 0

            onExpandStarted: {
                root.maximumHeight = baseHeight + logHeight + shadowSize * 2;
                root.height = root.maximumHeight;
            }

            onExpandFinished: {
                root.minimumHeight = root.maximumHeight;
            }

            onCollapseStarted: {
                root.minimumHeight = baseHeight + shadowSize * 2;
            }

            onCollapseFinished: {
                root.height = root.minimumHeight;
                root.maximumHeight = root.minimumHeight;
            }

            onResizeStarted: {
                root.maximumHeight = root.Screen.height - root.y;
                root.height = root.maximumHeight;
            }

            onResizeFinished: {
                root.height = mainWindow.height + mainWindow.shadowSize * 2;
                root.maximumHeight = root.height;
                root.minimumHeight = root.height;
            }
        }

        /* Splash: same outer geometry and chrome as MainWindow.bg (radius 10, border 3). */
        Item {
            id: splash
            z: 2000
            x: mainWindow.x
            y: mainWindow.y
            width: mainWindow.width
            height: mainWindow.height
            opacity: 1

            Rectangle {
                id: splashChrome
                anchors.fill: parent
                radius: 10
                color: Theme.color.bluepurple7
                border.width: 3
                border.color: Theme.color.bluepurple5
                clip: true

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: parent.border.width
                    radius: Math.max(0, parent.radius - parent.border.width)
                    color: "#151a20"

                    gradient: Gradient {
                        GradientStop { position: 0; color: "#1a2027" }
                        GradientStop { position: 1; color: "#252d37" }
                    }

                    Canvas {
                        id: splashGrid
                        anchors.fill: parent
                        opacity: 0.24

                        onPaint: {
                            const numCells = 28;
                            const cellSize = width / numCells;
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = "#4f5966";
                            ctx.lineWidth = 2;
                            for (let ypos = cellSize; ypos < height; ypos += cellSize) {
                                const pos = Math.floor(ypos);
                                ctx.moveTo(0, pos);
                                ctx.lineTo(width, pos);
                            }
                            for (let xpos = cellSize; xpos < width; xpos += cellSize) {
                                const pos = Math.floor(xpos);
                                ctx.moveTo(pos, 0);
                                ctx.lineTo(pos, height);
                            }
                            ctx.stroke();
                        }

                        Component.onCompleted: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }
                }

                Item {
                    id: splashContent
                    anchors.fill: parent
                    opacity: 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 20
                        width: parent.width - 48

                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: "qrc:/assets/icons/ARF-splash.png"
                            width: 176
                            height: 176
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            asynchronous: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: qsTr("ARF Firmware")
                            color: Theme.color.lightred4
                            font.family: "Born2bSportyV2"
                            font.pixelSize: 36
                            font.letterSpacing: 0.5
                        }

                        Item {
                            width: 40
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/assets/gfx/images/spinner.svg"
                                width: 36
                                height: 36
                                sourceSize: Qt.size(36, 36)

                                RotationAnimator on rotation {
                                    running: splash.visible && splashContent.opacity > 0.15
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 850
                                }
                            }
                        }
                    }
                }
            }

            SequentialAnimation {
                id: splashAnim
                running: false

                NumberAnimation {
                    target: splashContent
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 420
                    easing.type: Easing.OutCubic
                }
                PauseAnimation { duration: 1280 }
                ParallelAnimation {
                    NumberAnimation {
                        target: splash
                        property: "opacity"
                        to: 0
                        duration: 520
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: mainWindow
                        property: "opacity"
                        to: 1
                        duration: 520
                        easing.type: Easing.OutCubic
                    }
                }
                ScriptAction {
                    script: {
                        splash.visible = false;
                        mainWindow.opacity = 1;
                    }
                }
            }

            Component.onCompleted: splashAnim.start()
        }
    }

    function alert(message) {
        root.requestActivate();
        root.raise();
    }

    Component.onCompleted: {
        App.messageReceived.connect(alert);
        mainWindow.controls.minimizeRequested.connect(root.showMinimized);
        mainWindow.controls.closeRequested.connect(Qt.quit);
    }
}
