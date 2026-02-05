import QtQuick

Item {
    id: root

    MultiPointTouchArea {
        // prevent any mouse/touch events reaching items beneath
        anchors.fill: parent
        mouseEnabled: true

        // including Flickable and its descendents ListView & GridView
        onGestureStarted: gesture => gesture.grab()
    }

    HoverHandler {
        // enforce default cursor shape and attempt to prevent touch events
        // from causing hover events on items beneath
        cursorShape: Qt.ArrowCursor
        blocking: true
    }
}
