import QtQuick
import QtQuick.Controls
import QtQuick.Window

Window {
    id: window
    width: 1000
    height: 700
    visible: true
    title: "OSK on Focus Bug Reproducer (Windows Tablet Mode)"

    property string tapStatus: ""
    property int closeMode: 0  // 0=MouseArea, 1=Button, 2=MouseArea+focus

    ListModel {
        id: closeModes
        // Demonstrates the bug
        ListElement { mode: 0; name: "MouseArea (buggy)"; description: "Plain MouseArea with no focus handling" }
        // Known working solution
        ListElement { mode: 1; name: "Button (works)"; description: "Button from QtQuick.Controls" }
        // Failed attempts to fix without QtQuick.Controls
        ListElement { mode: 2; name: "focusPolicy + TapHandler (buggy)"; description: "Rectangle with focusPolicy: Qt.StrongFocus" }
        ListElement { mode: 3; name: "focusPolicy + MouseArea (buggy)"; description: "Rectangle with focusPolicy, MouseArea calls forceActiveFocus on press" }
        ListElement { mode: 4; name: "Control + TapHandler (buggy)"; description: "Control from QtQuick.Controls with TapHandler" }
        ListElement { mode: 6; name: "Control + Accessible.pressed (buggy)"; description: "Control with Accessible.pressed but no focusPolicy" }
        // Working solutions
        ListElement { mode: 5; name: "Rectangle + focusPolicy + Accessible.pressed (works)"; description: "Rectangle with focusPolicy and Accessible.pressed" }
        ListElement { mode: 7; name: "Control + focusPolicy + Accessible.pressed (works)"; description: "Control with focusPolicy and Accessible.pressed" }
    }

    Timer {
        id: tapTimer
        interval: 700
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
            width: Math.min(500, parent.width - 80)

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

            // Close mode selector
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Select input panel close button behaviour:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }

                ListView {
                    id: modeList
                    width: parent.width
                    height: contentHeight
                    model: closeModes
                    interactive: false

                    delegate: Rectangle {
                        width: modeList.width
                        height: 50
                        color: model.mode === window.closeMode ? "#bbdefb" : "#fff"
                        border.color: model.mode === window.closeMode ? "#2196F3" : "#ccc"
                        border.width: model.mode === window.closeMode ? 2 : 1
                        radius: 4

                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            Text {
                                text: model.name
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            Text {
                                text: model.description
                                font.pixelSize: 11
                                color: "#666"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: window.closeMode = model.mode
                        }
                    }
                }
            }

            // Show button with border
            Rectangle {
                width: 160
                height: 44
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !modalLayer.visible
                color: showMouseArea.containsMouse ? "#ccc" : "#ddd"
                border.color: "#999"
                border.width: 2
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "Show Input Panel"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: showMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modalLayer.showLayer()
                }
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
            modalLoader.sourceComponent = inputPanelComponent
            visible = true
            focus = true
        }

        function hideLayer() {
            Qt.inputMethod.hide()
            focus = false
            visible = false
            modalLoader.sourceComponent = null  // Unload the panel
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
        }

        Component {
            id: inputPanelComponent

            InputPanel {
                focus: true
                closeMode: window.closeMode
                onCloseTriggered: modalLayer.hideLayer()
            }
        }
    }
}
