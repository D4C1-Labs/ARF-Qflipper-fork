pragma Singleton

import QtQuick 2.15

QtObject {
    readonly property var color: QtObject {
        readonly property color transparent: Qt.rgba(0, 0, 0, 0)

        readonly property color lightorange1: "#ff9722"
        readonly property color lightorange2: "#fe8a2c"
        readonly property color lightorange3: "#ce5300"
        readonly property color darkorange1: "#491d00"
        readonly property color darkorange2: "#3a1f10"
        readonly property color mediumorange1: "#9e5823"
        readonly property color mediumorange2: "#76380b"
        readonly property color mediumorange3: "#662c00"
        readonly property color mediumorange4: "#9b450b"
        readonly property color mediumorange5: "#9e4a12"

        readonly property color lightgreen: "#2ed832"
        readonly property color mediumgreen1: "#285b12"
        readonly property color mediumgreen2: "#203812"
        readonly property color darkgreen: "#0c160c"

        /* Legacy names kept for QML compatibility; values are ARF red (no blue UI). */
        readonly property color lightblue: "#ff5555"
        readonly property color mediumblue: "#601818"
        readonly property color darkblue1: "#401010"
        readonly property color darkblue2: "#240a0a"

        readonly property color buttonSurface: "#3a1515"
        readonly property color buttonSurfaceHover: "#552020"
        readonly property color buttonSurfaceDown: "#701818"
        readonly property color buttonSurfaceDisabled: "#180606"
        readonly property color textDisabled: "#8a7070"
        readonly property color strokeMuted: "#9a7070"
        readonly property color tabBg: "#2a0c0c"
        readonly property color tabBgHover: "#3e1818"
        readonly property color tabPressed: "#4a1818"
        readonly property color channelTagDev: "#c04040"
        readonly property color valueHighlight: "#f0d4d4"
        readonly property color selectionTint: "#2a1212"
        readonly property color statusBarIdle: "#241212"
        readonly property color keypadFace: "#1c1010"
        readonly property color closeHover: "#a04040"
        readonly property color closeDown: "#702020"

        readonly property color lightred1: "#ff4444"
        readonly property color lightred2: "#ff3333"
        readonly property color lightred3: "#ff1f00"
        readonly property color lightred4: "#ff2d2d"
        readonly property color mediumred1: "#952020"
        readonly property color mediumred2: "#671515"
        readonly property color darkred1: "#501010"
        readonly property color darkred2: "#2a0808"

        /* ARF theme: keep property names for compatibility; values are dark red / near-black */
        readonly property color bluepurple1: "#e8b8b8"
        readonly property color bluepurple2: "#c85858"
        readonly property color bluepurple3: "#a03030"
        readonly property color bluepurple4: "#701818"
        readonly property color bluepurple5: "#4a1010"
        readonly property color bluepurple6: "#1e0c0c"
        readonly property color bluepurple7: "#140a0a"
    }

    readonly property var timing: QtObject {
        readonly property int toolTipDelay: 500
    }
}
