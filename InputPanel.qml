import QtQuick

FocusScope {
    id: root

    signal closeTriggered()

    // Keys.onPressed that swallows all events (like BbSignInLayer)
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

            // Close button using MouseArea
            Rectangle {
                id: closeButton
                width: 80
                height: 32
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: closeMouseArea.containsMouse ? "#ccc" : "#ddd"
                border.color: "#999"
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeTriggered()
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
        }
    }

    // focusDummy (like BbSignInLayer)
    Item {
        id: focusDummy
        focus: true
    }
}
