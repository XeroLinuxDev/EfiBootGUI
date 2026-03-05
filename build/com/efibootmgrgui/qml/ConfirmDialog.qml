import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    property string actionTitle: "Confirm Action"
    property string message: ""
    property bool destructive: true

    modal: true
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: "#2a2a2e"
        border.color: "#3e3e48"
        border.width: 1
        radius: 12
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Icon + title
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 24
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            spacing: 12

            Label {
                text: root.destructive ? "⚠" : "✦"
                font.pixelSize: 28
                color: root.destructive ? "#d9534f" : "#5b9bd5"
            }

            Label {
                text: root.actionTitle
                font.pixelSize: 16
                font.bold: true
                color: "#e8e8e8"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }

        // Message
        Label {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            text: root.message
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            lineHeight: 1.5
            color: "#c8c8c8"
        }

        // Irreversibility warning
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            height: warningLabel.implicitHeight + 16
            color: root.destructive ? "#2a1010" : "#0f1e2a"
            border.color: root.destructive ? "#6e2020" : "#1e4a6e"
            border.width: 1
            radius: 6

            Label {
                id: warningLabel
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 10 }
                text: "⚠  This action cannot be reverted once applied."
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: root.destructive ? "#ff9090" : "#88b8d8"
            }
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 20
            Layout.bottomMargin: 24
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            spacing: 10

            Item { Layout.fillWidth: true }

            // Cancel
            Rectangle {
                height: 34
                implicitWidth: cancelLbl.implicitWidth + 28
                color: cancelMa.pressed ? "#464650" : cancelMa.containsMouse ? "#3e3e48" : "#383840"
                border.color: "#505058"
                border.width: 1
                radius: 6
                Behavior on color { ColorAnimation { duration: 100 } }
                Label {
                    id: cancelLbl
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.pixelSize: 13
                    color: "#e8e8e8"
                }
                MouseArea {
                    id: cancelMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.reject()
                }
            }

            // Confirm
            Rectangle {
                height: 34
                implicitWidth: confirmLbl.implicitWidth + 28
                color: {
                    if (confirmMa.pressed)
                        return root.destructive ? "#a03030" : "#3a7a3a"
                    if (confirmMa.containsMouse)
                        return root.destructive ? "#b03030" : "#3d8a3d"
                    return root.destructive ? "#8b2020" : "#2d6a2d"
                }
                border.color: root.destructive ? "#d9534f" : "#5cb85c"
                border.width: 1
                radius: 6
                Behavior on color { ColorAnimation { duration: 100 } }
                Label {
                    id: confirmLbl
                    anchors.centerIn: parent
                    text: root.destructive ? "Delete" : "Apply"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#ffffff"
                }
                MouseArea {
                    id: confirmMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.accept()
                }
            }
        }
    }
}
