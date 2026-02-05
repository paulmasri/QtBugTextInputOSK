import QtQuick
import QtQuick.Controls

FocusScope {
    id: root

    property int closeMode: 0  // 0=MouseArea, 1=Button, 2=MouseArea+focus

    signal closeTriggered()

    // Keys.onPressed that swallows all events
    Keys.onPressed: (event) => {
        switch (event.key) {
        case Qt.Key_Escape:
            root.closeTriggered()
            break
        case Qt.Key_Tab:
            if (focusDummy.activeFocus)
                input1.focus = true
            break
        }
        event.accepted = true // Swallow all key events
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#f5f5f5"
        border.color: "#90a4ae"
        border.width: 2
        radius: 8
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Item {
            width: parent.width
            height: 40

            Text {
                text: "Text Input Tests"
                font.pixelSize: 20
                font.bold: true
                color: "#333"
                anchors.verticalCenter: parent.verticalCenter
            }

            // Close button - MouseArea variant (mode 0)
            Rectangle {
                width: 80
                height: 32
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.closeMode === 0
                color: closeMouseArea0.containsMouse ? "#ccc" : "#ddd"
                border.color: "#999"
                border.width: 1
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: closeMouseArea0
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeTriggered()
                }
            }

            // Close button - Button variant (mode 1)
            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.closeMode === 1
                text: "Close"
                onClicked: root.closeTriggered()
            }

            // Close button - focusPolicy + TapHandler variant (mode 2)
            Rectangle {
                width: 80
                height: 32
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.closeMode === 2
                color: hoverHandler2.hovered ? "#ccc" : "#ddd"
                border.color: "#999"
                border.width: 1
                radius: 4
                focusPolicy: Qt.StrongFocus

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 14
                }

                HoverHandler {
                    id: hoverHandler2
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.closeTriggered()
                }
            }

            // Close button - focusPolicy + MouseArea variant (mode 3)
            Rectangle {
                id: closeButton3
                width: 80
                height: 32
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.closeMode === 3
                color: closeMouseArea3.containsMouse ? "#ccc" : "#ddd"
                border.color: "#999"
                border.width: 1
                radius: 4
                focusPolicy: Qt.StrongFocus

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: closeMouseArea3
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: closeButton3.forceActiveFocus()
                    onClicked: root.closeTriggered()
                }
            }

            // Close button - Control + TapHandler variant (mode 4)
            Control {
                width: 80
                height: 32
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.closeMode === 4

                background: Rectangle {
                    color: parent.hovered ? "#ccc" : "#ddd"
                    border.color: "#999"
                    border.width: 1
                    radius: 4
                }

                contentItem: Text {
                    text: "Close"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                TapHandler {
                    onTapped: root.closeTriggered()
                }
            }

        }

        // 1. Plain TextInput
        TextInputField {
            id: input1
            width: parent.width
            placeholderText: "1. Plain TextInput"
        }

        // 2. TextInput with Accessible.passwordEdit
        TextInputField {
            id: input2
            width: parent.width
            placeholderText: "2. TextInput + Accessible.passwordEdit"
            passwordEdit: true
        }

        // 3. TextField (from QuickControls)
        TextFieldWrapper {
            id: input3
            width: parent.width
            placeholderText: "3. TextField (QuickControls)"
        }

        // 4. ReadOnly TextInput (focus sink)
        Rectangle {
            width: parent.width
            height: 50
            color: "#eee"
            border.color: input4.activeFocus ? "#2196F3" : "#ccc"
            border.width: 2
            radius: 4

            TextInput {
                id: input4
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 18
                readOnly: true
                text: "4. ReadOnly TextInput (focus sink)"
                color: "#666"
            }
        }

        // Test buttons
        Row {
            spacing: 10

            Rectangle {
                width: 120
                height: 32
                color: clearFocusMouseArea.containsMouse ? "#ccc" : "#ddd"
                border.color: "#999"
                border.width: 1
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "Clear Focus"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: clearFocusMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: focusDummy.forceActiveFocus()
                }
            }

            Rectangle {
                width: 120
                height: 32
                color: commitMouseArea.containsMouse ? "#ccc" : "#ddd"
                border.color: "#999"
                border.width: 1
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "Commit"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: commitMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.inputMethod.commit()
                }
            }
        }

        // Diagnostic info
        Column {
            spacing: 4
            topPadding: 10

            Text {
                font.pixelSize: 12
                color: "#666"
                text: "1. Plain TextInput — activeFocus: " + input1.activeFocus
            }
            Text {
                font.pixelSize: 12
                color: "#666"
                text: "2. Accessible.passwordEdit — activeFocus: " + input2.activeFocus
            }
            Text {
                font.pixelSize: 12
                color: "#666"
                text: "3. TextField — activeFocus: " + input3.activeFocus
            }
            Text {
                font.pixelSize: 12
                color: "#666"
                text: "4. ReadOnly — activeFocus: " + input4.activeFocus
            }
        }
    }

    // focusDummy
    Item {
        id: focusDummy
        focus: true
    }
}
