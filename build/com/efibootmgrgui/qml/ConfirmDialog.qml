import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    property string actionTitle: "Confirm Action"
    property string message: ""
    property bool destructive: true

    width: 520
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
        width: root.width

        // Colored header block
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: headerRow.implicitHeight + 40
            color: root.destructive ? "#5a1a1a" : "#0f1e3a"
            radius: 12

            // Square bottom corners so it blends into dialog body
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: parent.radius
                color: parent.color
            }

            RowLayout {
                id: headerRow
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 28 }
                spacing: 14

                Label {
                    text: root.destructive ? "⚠" : "✦"
                    font.pixelSize: 32
                    color: root.destructive ? "#ff9090" : "#88b8e8"
                }

                Column {
                    spacing: 4
                    Layout.fillWidth: true
                    Label {
                        text: root.actionTitle
                        font.pixelSize: 17
                        font.bold: true
                        color: "#ffffff"
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        text: "Please review before continuing"
                        font.pixelSize: 11
                        color: root.destructive ? "#dd9090" : "#7898c8"
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3e3e48"
        }

        // Message
        Label {
            Layout.fillWidth: true
            Layout.topMargin: 20
            Layout.leftMargin: 28
            Layout.rightMargin: 28
            text: root.message
            wrapMode: Text.WordWrap
            font.pixelSize: 14
            lineHeight: 1.6
            color: "#d0d0d0"
        }

        // Irreversibility warning
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.leftMargin: 28
            Layout.rightMargin: 28
            height: warningLabel.implicitHeight + 18
            color: root.destructive ? "#2a1010" : "#0f1e2a"
            border.color: root.destructive ? "#6e2020" : "#1e4a6e"
            border.width: 1
            radius: 6

            Label {
                id: warningLabel
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 12 }
                text: "⚠  This action cannot be reverted once applied."
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                color: root.destructive ? "#ff9090" : "#88b8d8"
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 20
            height: 1
            color: "#3e3e48"
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.bottomMargin: 20
            Layout.leftMargin: 28
            Layout.rightMargin: 28
            spacing: 10

            Item { Layout.fillWidth: true }

            Rectangle {
                height: 36
                implicitWidth: cancelLbl.implicitWidth + 32
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

            Rectangle {
                height: 36
                implicitWidth: confirmLbl.implicitWidth + 32
                color: {
                    if (confirmMa.pressed)
                        return root.destructive ? "#a03030" : "#2a5ea0"
                    if (confirmMa.containsMouse)
                        return root.destructive ? "#b03030" : "#2f6ab0"
                    return root.destructive ? "#8b2020" : "#1e4a80"
                }
                border.color: root.destructive ? "#d9534f" : "#5b9bd5"
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
