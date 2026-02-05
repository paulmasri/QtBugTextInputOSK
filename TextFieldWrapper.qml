import QtQuick
import QtQuick.Controls

FocusScope {
    id: root

    property alias text: inputField.text
    property alias placeholderText: inputField.placeholderText

    implicitWidth: 300
    implicitHeight: 50

    Rectangle {
        anchors.fill: parent
        color: "#eee"
        border.color: inputField.activeFocus ? "#2196F3" : "#ccc"
        border.width: 2
        radius: 4

        TextField {
            id: inputField
            anchors.fill: parent
            anchors.margins: 2
            leftPadding: 8
            rightPadding: 8
            topPadding: 0
            bottomPadding: 0
            verticalAlignment: TextInput.AlignVCenter
            font.pixelSize: 18
            focus: true
            activeFocusOnTab: true
            placeholderTextColor: "#999"
            background: Rectangle { color: "transparent" }
        }
    }
}
