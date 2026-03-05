import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.efibootmgrgui 1.0

ApplicationWindow {
    id: root

    readonly property color cBg:       "#2a2a2e"
    readonly property color cSurface:  "#202024"
    readonly property color cDark:     "#161618"
    readonly property color cBorder:   "#3e3e48"
    readonly property color cText:     "#e8e8e8"
    readonly property color cTextSub:  "#888890"
    readonly property color cBtn:      "#383840"
    readonly property color cBtnHov:   "#464650"
    readonly property color cBtnBord:  "#505058"
    readonly property color cGreen:    "#5cb85c"
    readonly property color cRed:      "#d9534f"
    readonly property color cBlue:     "#5b9bd5"

    width: 920
    height: 700
    minimumWidth: 800
    minimumHeight: 560
    visible: true
    title: "EFI Boot Manager"
    color: root.cBg

    BootManager {
        id: mgr
        onOperationFinished: (success, message) => toast.show(success, message)
    }

    ColumnLayout {
        anchors { fill: parent; margins: 0 }
        spacing: 0

        // ── Toolbar ──────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 52
            color: root.cSurface

            RowLayout {
                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                spacing: 12

                Image {
                    width: 32; height: 32
                    source: "image://icon/distributor-logo-archlinux"
                    sourceSize: Qt.size(32, 32)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Row {
                    spacing: 6
                    Rectangle {
                        width: 8; height: 8
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: mgr.loading ? root.cBlue : root.cGreen
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: mgr.loading ? "Working…" : "Ready"
                        font.pixelSize: 13
                        color: root.cTextSub
                    }
                }

                BusyIndicator {
                    running: mgr.loading
                    width: 20; height: 20
                    visible: running
                }

                Item { Layout.fillWidth: true }

                ToolButton {
                    icon.name: "view-refresh"
                    icon.color: root.cText
                    icon.width: 18; icon.height: 18
                    implicitWidth: 34; implicitHeight: 34
                    enabled: !mgr.loading
                    ToolTip.visible: hovered
                    ToolTip.text: "Refresh boot entries"
                    onClicked: mgr.refresh()
                    background: Rectangle {
                        color: parent.pressed ? root.cBtnHov
                             : parent.hovered ? root.cBtn : "transparent"
                        border.color: parent.hovered ? root.cBtnBord : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                }

                Rectangle {
                    width: 34; height: 34
                    color: aboutMa.pressed ? root.cBtnHov : aboutMa.containsMouse ? root.cBtn : "transparent"
                    border.color: aboutMa.containsMouse ? root.cBtnBord : "transparent"
                    border.width: 1
                    Behavior on color        { ColorAnimation { duration: 100 } }
                    Behavior on border.color { ColorAnimation { duration: 100 } }
                    Label {
                        anchors.centerIn: parent
                        text: "ℹ"
                        font.pixelSize: 20
                        font.bold: true
                        color: root.cText
                    }
                    MouseArea {
                        id: aboutMa; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: aboutDialog.open()
                    }
                    ToolTip.visible: aboutMa.containsMouse
                    ToolTip.text: "About"
                }
            }
        }

        // ── Divider ──────────────────────────────────────────────────
        Rectangle { Layout.fillWidth: true; height: 1; color: root.cBorder }

        // ── Boot order bar ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 52
            color: "transparent"

            RowLayout {
                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                spacing: 12

                Label {
                    text: "Boot Order:"
                    font.pixelSize: 13
                    color: root.cTextSub
                }
                Label {
                    text: mgr.bootOrder || "—"
                    font.family: "monospace"
                    font.pixelSize: 12
                    color: root.cText
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Rectangle {
                    height: 30; implicitWidth: aLbl.implicitWidth + 26
                    color: aMa.pressed ? root.cBtnHov : aMa.containsMouse ? root.cBtn : root.cBtn
                    border.color: root.cBtnBord; border.width: 1
                    opacity: mgr.loading ? 0.4 : 1.0
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Label { id: aLbl; anchors.centerIn: parent; text: "Apply Boot Order"; font.pixelSize: 13; color: root.cText }
                    MouseArea {
                        id: aMa; anchors.fill: parent; hoverEnabled: true
                        enabled: !mgr.loading; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            applyConfirm.actionTitle = "Apply Boot Order"
                            applyConfirm.message = "You are about to write the current entry order to the EFI BootOrder variable.\n\nThis will change which entries your firmware tries first on the next boot."
                            applyConfirm.destructive = false
                            applyConfirm.open()
                        }
                    }
                    ToolTip.visible: aMa.containsMouse
                    ToolTip.delay: 600
                    ToolTip.text: "Save the current entry order to the EFI BootOrder variable.\nThis determines which entry the firmware tries first on boot."
                }
            }
        }

        // ── Divider ──────────────────────────────────────────────────
        Rectangle { Layout.fillWidth: true; height: 1; color: root.cBorder }

        // ── Warning pill ─────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 44
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                height: 30
                width: warningRow.implicitWidth + 32
                color: "#3a1010"
                border.color: root.cRed
                border.width: 1
                radius: 15

                Row {
                    id: warningRow
                    anchors.centerIn: parent
                    spacing: 4

                    Label {
                        text: "⚠  Warning : Use this at"
                        font.pixelSize: 13
                        color: "#ff9090"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: "YOUR OWN RISK !"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#ff4444"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: " Might break boot if used incorrectly."
                        font.pixelSize: 13
                        color: "#ff9090"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ── Entry list ───────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.cSurface

            ListView {
                id: listView
                anchors.fill: parent
                model: mgr
                spacing: 0
                clip: true
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Label {
                    visible: listView.count === 0 && !mgr.loading
                    anchors.centerIn: parent
                    text: "No EFI boot entries found.\nMake sure efibootmgr is installed and this system uses UEFI."
                    horizontalAlignment: Text.AlignHCenter
                    color: root.cTextSub
                    font.pixelSize: 15
                    lineHeight: 1.6
                }

                delegate: BootEntryDelegate {
                    cText:    root.cText
                    cTextSub: root.cTextSub
                    cBorder:  root.cBorder
                    cBtn:     root.cBtn
                    cBtnHov:  root.cBtnHov
                    cGreen:   root.cGreen
                    cRed:     root.cRed
                    cBlue:    root.cBlue

                    onToggleActive:         (num, state) => mgr.setActive(num, state)
                    onMoveUpRequested:      (idx)        => mgr.moveUp(idx)
                    onMoveDownRequested:    (idx)        => mgr.moveDown(idx)
                    onSetBootNextRequested: (num)        => mgr.setBootNext(num)
                    onDeleteRequested: (num, nm) => {
                        deleteConfirm.actionTitle = "Delete Boot Entry"
                        deleteConfirm.message = "You are about to delete:\n\nBoot" + num + " — " + nm
                        deleteConfirm.destructive = true
                        deleteConfirm._bootNum = num
                        deleteConfirm.open()
                    }
                }
            }
        }

        // ── Divider ──────────────────────────────────────────────────
        Rectangle { Layout.fillWidth: true; height: 1; color: root.cBorder }

        // ── Log area ─────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 95
            color: root.cDark

            Label {
                anchors { left: parent.left; top: parent.top; margins: 8 }
                text: "LOG"
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 2
                color: root.cBorder
            }

            Flickable {
                id: logFlick
                anchors { fill: parent; margins: 8; topMargin: 24 }
                contentHeight: logText.implicitHeight
                contentWidth: width
                clip: true
                onContentHeightChanged: {
                    if (contentHeight > height) contentY = contentHeight - height
                }
                Label {
                    id: logText
                    width: logFlick.width
                    text: mgr.log || "Ready."
                    font.family: "monospace"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    color: root.cTextSub
                }
            }
        }
    }

    // ── Dialogs ──────────────────────────────────────────────────────
    AboutWindow {
        id: aboutDialog
        anchors.centerIn: parent
    }

    ConfirmDialog {
        id: deleteConfirm
        property string _bootNum: ""
        anchors.centerIn: parent
        onAccepted: mgr.deleteEntry(_bootNum)
    }
    ConfirmDialog {
        id: applyConfirm
        anchors.centerIn: parent
        onAccepted: mgr.applyBootOrder()
    }

    // ── Toast ─────────────────────────────────────────────────────────
    Rectangle {
        id: toast
        x: (parent.width - width) / 2
        y: parent.height - height - 16
        width: toastLabel.implicitWidth + 32
        height: 34
        color: toastSuccess ? "#3a5a3a" : "#5a3a3a"
        border.color: toastSuccess ? root.cGreen : root.cRed
        border.width: 1
        visible: false; opacity: 0
        property bool toastSuccess: true

        Label {
            id: toastLabel
            anchors.centerIn: parent
            font.pixelSize: 13; color: root.cText
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toast; property: "opacity"; to: 1.0; duration: 150 }
            PauseAnimation  { duration: 2500 }
            NumberAnimation { target: toast; property: "opacity"; to: 0.0; duration: 250 }
            ScriptAction    { script: toast.visible = false }
        }

        function show(success, msg) {
            toastSuccess = success
            toastLabel.text = (success ? "✓  " : "✗  ") + msg
            visible = true
            toastAnim.restart()
        }
    }
}
