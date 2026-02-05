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
        ListElement { name: "MouseArea (has bug)"; description: "Close using MouseArea - OSK becomes sticky" }
        ListElement { name: "Button (works)"; description: "Close using Button component - OSK behaves correctly" }
        ListElement { name: "focusPolicy + TapHandler"; description: "Item with focusPolicy: Qt.StrongFocus (Qt 6.7+)" }
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
                    text: "Select close button behavior:"
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
                    currentIndex: window.closeMode

                    delegate: Rectangle {
                        width: modeList.width
                        height: 50
                        color: index === modeList.currentIndex ? "#bbdefb" : "#fff"
                        border.color: index === modeList.currentIndex ? "#2196F3" : "#ccc"
                        border.width: index === modeList.currentIndex ? 2 : 1
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
                            onClicked: window.closeMode = index
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
