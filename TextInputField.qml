import QtQuick

FocusScope {
    id: root

    property alias text: inputField.text
    property alias placeholderText: placeholder.text
    property bool passwordEdit: false

    implicitWidth: 300
    implicitHeight: 50

    Rectangle {
        anchors.fill: parent
        color: "#eee"
        border.color: inputField.activeFocus ? "#2196F3" : "#ccc"
        border.width: 2
        radius: 4
        clip: true

        TextInput {
            id: inputField
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            verticalAlignment: TextInput.AlignVCenter
            font.pixelSize: 18
            focus: true
            activeFocusOnTab: true
            Accessible.passwordEdit: root.passwordEdit
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText

            Text {
                id: placeholder
                anchors.fill: parent
                font: inputField.font
                verticalAlignment: Text.AlignVCenter
                color: "#999"
                visible: inputField.text.length === 0 && !inputField.activeFocus
            }
        }
    }
}
