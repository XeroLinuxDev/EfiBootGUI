import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    modal: true
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: "#2a2a2e"
        border.color: "#3e3e48"
        border.width: 1
        radius: 8
    }

    contentItem: Item {
        implicitWidth: 580
        implicitHeight: mainCol.implicitHeight + 32

        Column {
            id: mainCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 28 }
            spacing: 0

            // Logo
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100; height: 100
                source: "qrc:/com/efibootmgrgui/assets/logo.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Item { width: 1; height: 14 }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "EFI Boot Manager"
                font.pixelSize: 22
                font.bold: true
                color: "#e8e8e8"
            }

            Item { width: 1; height: 5 }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Version 1.0.0"
                font.pixelSize: 13
                color: "#888890"
            }

            Item { width: 1; height: 18 }

            Rectangle { width: parent.width; height: 1; color: "#3e3e48" }

            Item { width: 1; height: 18 }

            Label {
                width: parent.width
                text: "A simple, clean interface for managing UEFI/EFI boot entries on Linux.\n" +
                      "View, reorder, enable, disable, or delete boot entries.\n" +
                      "All without ever touching Terminal."
                wrapMode: Text.WordWrap
                font.pixelSize: 15
                lineHeight: 1.6
                color: "#c8c8c8"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 18 }

            Rectangle { width: parent.width; height: 1; color: "#3e3e48" }

            Item { width: 1; height: 18 }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Developed by  DarkXero"
                font.pixelSize: 15
                color: "#e8e8e8"
            }

            Item { width: 1; height: 18 }

            // Links row
            RowLayout {
                width: parent.width
                spacing: 10

                Item { Layout.fillWidth: true }

                // Main Site
                Rectangle {
                    height: 30; implicitWidth: siteLbl.implicitWidth + 22
                    color: siteMa.pressed ? "#464650" : siteMa.containsMouse ? "#383840" : "#303038"
                    border.color: "#505058"; border.width: 1
                    radius: 4
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Label {
                        id: siteLbl
                        anchors.centerIn: parent
                        text: "🌐  Main Site"
                        font.pixelSize: 14
                        color: "#e8e8e8"
                    }
                    MouseArea {
                        id: siteMa; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://xerolinux.xyz")
                    }
                    ToolTip.visible: siteMa.containsMouse
                    ToolTip.text: "https://xerolinux.xyz"
                }

                // GitHub — ⎇ is the branch/merge Unicode symbol, always available
                Rectangle {
                    height: 30; implicitWidth: ghLbl.implicitWidth + 22
                    color: ghMa.pressed ? "#464650" : ghMa.containsMouse ? "#383840" : "#303038"
                    border.color: "#505058"; border.width: 1
                    radius: 4
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Label {
                        id: ghLbl
                        anchors.centerIn: parent
                        text: "⎇  GitHub"
                        font.pixelSize: 14
                        color: "#ffffff"
                    }
                    MouseArea {
                        id: ghMa; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://github.com/XeroLinuxDev")
                    }
                    ToolTip.visible: ghMa.containsMouse
                    ToolTip.text: "https://github.com/XeroLinuxDev"
                }

                // Donate
                Rectangle {
                    height: 30; implicitWidth: donateLbl.implicitWidth + 22
                    color: donateMa.pressed ? "#464650" : donateMa.containsMouse ? "#383840" : "#303038"
                    border.color: "#505058"; border.width: 1
                    radius: 4
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Label {
                        id: donateLbl
                        anchors.centerIn: parent
                        text: "☕  Donate"
                        font.pixelSize: 14
                        color: "#e8e8e8"
                    }
                    MouseArea {
                        id: donateMa; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://ko-fi.com/xerolinux")
                    }
                    ToolTip.visible: donateMa.containsMouse
                    ToolTip.text: "https://ko-fi.com/xerolinux"
                }

                Item { Layout.fillWidth: true }
            }

            Item { width: 1; height: 22 }

            // Close button
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                height: 30; implicitWidth: closeLbl.implicitWidth + 40
                color: closeMa.pressed ? "#464650" : closeMa.containsMouse ? "#464650" : "#383840"
                border.color: "#505058"; border.width: 1
                radius: 4
                Behavior on color { ColorAnimation { duration: 100 } }
                Label {
                    id: closeLbl
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 14
                    color: "#e8e8e8"
                }
                MouseArea {
                    id: closeMa; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }

            Item { width: 1; height: 4 }
        }
    }
}
