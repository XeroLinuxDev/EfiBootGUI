import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    property string message: ""

    title: "Confirm"
    modal: true
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: "#2a2a2e"
        border.color: "#3e3e48"
        border.width: 1
    }

    header: Rectangle {
        color: "#242428"
        height: 40
        Label {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
            text: root.title
            font.pixelSize: 13
            font.bold: true
            color: "#e8e8e8"
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: "#3e3e48"
        }
    }

    contentItem: Item {
        implicitWidth: 380
        implicitHeight: msgLabel.implicitHeight + 32
        Label {
            id: msgLabel
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            text: root.message
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            lineHeight: 1.5
            color: "#e8e8e8"
        }
    }

    footer: Rectangle {
        color: "#242428"
        height: 50
        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 1
            color: "#3e3e48"
        }
        RowLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 8
            Item { Layout.fillWidth: true }

            Rectangle {
                height: 28; implicitWidth: cancelLbl.implicitWidth + 24
                color: cancelMa.pressed ? "#464650" : cancelMa.containsMouse ? "#383840" : "#383840"
                border.color: "#505058"; border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Label { id: cancelLbl; anchors.centerIn: parent; text: "Cancel"; font.pixelSize: 11; color: "#e8e8e8" }
                MouseArea { id: cancelMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.reject() }
            }

            Rectangle {
                height: 28; implicitWidth: confirmLbl.implicitWidth + 24
                color: confirmMa.pressed ? "#464650" : confirmMa.containsMouse ? "#383840" : "#383840"
                border.color: "#505058"; border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Label { id: confirmLbl; anchors.centerIn: parent; text: "Confirm"; font.pixelSize: 11; font.bold: true; color: "#e8e8e8" }
                MouseArea { id: confirmMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.accept() }
            }
        }
    }
}
