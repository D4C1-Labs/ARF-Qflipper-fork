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

        /* Legacy names kept for QML compatibility; values now mapped to gray ARF tones. */
        readonly property color lightblue: "#d8dce2"
        readonly property color mediumblue: "#525861"
        readonly property color darkblue1: "#2d3239"
        readonly property color darkblue2: "#181c22"

        readonly property color buttonSurface: "#2f343c"
        readonly property color buttonSurfaceHover: "#404650"
        readonly property color buttonSurfaceDown: "#545c68"
        readonly property color buttonSurfaceDisabled: "#171a1f"
        readonly property color textDisabled: "#7b828c"
        readonly property color strokeMuted: "#8e96a1"
        readonly property color tabBg: "#1e232a"
        readonly property color tabBgHover: "#2d333c"
        readonly property color tabPressed: "#3a414c"
        readonly property color channelTagDev: "#9aa2ad"
        readonly property color valueHighlight: "#d8dde4"
        readonly property color selectionTint: "#262c34"
        readonly property color statusBarIdle: "#20252d"
        readonly property color keypadFace: "#171b21"
        readonly property color closeHover: "#7c8794"
        readonly property color closeDown: "#5c6672"

        readonly property color lightred1: "#c6cbd3"
        readonly property color lightred2: "#b9c0ca"
        readonly property color lightred3: "#aeb6c1"
        readonly property color lightred4: "#d6dbe3"
        readonly property color mediumred1: "#6e7681"
        readonly property color mediumred2: "#565d67"
        readonly property color darkred1: "#2f353d"
        readonly property color darkred2: "#1c2026"

        /* Keep legacy property names for compatibility; values are neutral ARF dark gray. */
        readonly property color bluepurple1: "#e3e7ed"
        readonly property color bluepurple2: "#aeb6c1"
        readonly property color bluepurple3: "#838c98"
        readonly property color bluepurple4: "#5b6470"
        readonly property color bluepurple5: "#414852"
        readonly property color bluepurple6: "#21262d"
        readonly property color bluepurple7: "#15191f"
    }

    readonly property var timing: QtObject {
        readonly property int toolTipDelay: 500
    }
}
