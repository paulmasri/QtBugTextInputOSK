import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: window
    width: 800
    height: 500
    visible: true
    title: "OSK on Focus Bug Reproducer (Windows Tablet Mode)"

    property string tapStatus: ""

    Timer {
        id: tapTimer
        interval: 1000
        onTriggered: window.tapStatus = ""
    }

    // Main content area (tappable rectangle that fills window)
    Rectangle {
        id: mainContent
        anchors.fill: parent
        color: "#e0e0e0"

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.ArrowCursor
        }

        TapHandler {
            onTapped: {
                window.tapStatus = "Tapped!"
                tapTimer.restart()
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 20
            width: parent.width - 80

            Text {
                width: parent.width
                text: "This is the main content area.\n\nTap anywhere. It should not trigger the OSK."
                font.pixelSize: 18
                color: "#333"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: window.tapStatus
                font.pixelSize: 28
                font.bold: true
                color: "#2196F3"
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "Show Input Panel"
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !modalLayer.visible
                onClicked: modalLayer.showLayer()
            }
        }
    }

    // Modal layer
    Item {
        id: modalLayer
        anchors.fill: parent
        visible: false

        onFocusChanged: {
            if (focus)
                modalLoader.focus = true
        }

        function showLayer() {
            visible = true
            focus = true
        }

        function hideLayer() {
            focus = false
            visible = false
        }

        // Semi-opaque background overlay
        Rectangle {
            id: modalBackgroundOverlay
            anchors.fill: parent
            color: "white"
            opacity: 0.7

            TapHoverBlocker {
                anchors.fill: parent
            }
        }

        // Modal content loader
        Loader {
            id: modalLoader
            anchors.centerIn: parent
            width: 400
            height: 420
            focus: true

            sourceComponent: inputPanelComponent
        }

        Component {
            id: inputPanelComponent

            InputPanel {
                focus: true
                onCloseTriggered: modalLayer.hideLayer()
            }
        }
    }
}
