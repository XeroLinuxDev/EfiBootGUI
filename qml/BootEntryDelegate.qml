import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property color cText:    "#e8e8e8"
    property color cTextSub: "#888890"
    property color cBorder:  "#3e3e48"
    property color cBtn:     "#383840"
    property color cBtnHov:  "#464650"
    property color cGreen:   "#5cb85c"
    property color cRed:     "#d9534f"
    property color cBlue:    "#5b9bd5"

    // Slow breathing for the running entry
    property real glow: 0.0
    SequentialAnimation {
        running: entryCurrent
        loops:   Animation.Infinite
        NumberAnimation { target: root; property: "glow"; to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "glow"; to: 0.0; duration: 2000; easing.type: Easing.InOutSine }
    }

    readonly property string entryName:    model.name       ?? ""
    readonly property string entryNum:     model.bootNum    ?? ""
    readonly property bool   entryActive:  model.active     ?? false
    readonly property bool   entryNext:    model.isBootNext ?? false
    readonly property bool   entryCurrent: model.isCurrent  ?? false

    readonly property bool isGeneric: {
        var s = entryName.toLowerCase().trim()
        return s === "uefi os" || s === "hard drive" || s === "boot" ||
               s === "uefi fallback" || s === "linux boot manager" ||
               s === "windows boot manager" || s.startsWith("boot00")
    }

    readonly property bool isFirst: index === 0
    readonly property bool isLast:  index === ListView.view.count - 1

    signal toggleActive(string num, bool newState)
    signal deleteRequested(string num, string nm)
    signal moveUpRequested(int idx)
    signal moveDownRequested(int idx)
    signal setBootNextRequested(string num)

    function displayName(n) {
        switch (n.toLowerCase().trim()) {
            case "uefi os":              return "XeroLinux — UEFI Fallback"
            case "hard drive":           return "Legacy Hard Drive"
            case "boot":                 return "EFI Fallback Boot"
            case "linux boot manager":   return "Linux Boot Manager"
            case "windows boot manager": return "Windows Boot Manager"
            default:                     return n
        }
    }

    function osIconName(n) {
        var s = n.toLowerCase().trim()
        if (s === "uefi os" || s.indexOf("xerolinux") >= 0 || s.indexOf("xero") >= 0 || s.indexOf("arch") >= 0)
            return "distributor-logo-archlinux"
        if (s === "hard drive" || s === "boot" || s === "linux boot manager")
            return "drive-harddisk"
        if (s.indexOf("windows") >= 0)  return "windows"
        if (s.indexOf("kubuntu") >= 0)  return "distributor-logo-kubuntu"
        if (s.indexOf("ubuntu")  >= 0)  return "distributor-logo-ubuntu"
        if (s.indexOf("fedora")  >= 0)  return "distributor-logo-fedora"
        if (s.indexOf("nobara")  >= 0)  return "distributor-logo-fedora"
        if (s.indexOf("manjaro") >= 0)  return "distributor-logo-manjaro"
        if (s.indexOf("debian")  >= 0)  return "distributor-logo-debian"
        if (s.indexOf("suse")    >= 0)  return "distributor-logo-opensuse"
        if (s.indexOf("mint")    >= 0)  return "distributor-logo-linux-mint"
        if (s.indexOf("grub")    >= 0)  return "drive-harddisk"
        if (s.indexOf("network") >= 0)  return "network-wired"
        if (s.indexOf("shell")   >= 0)  return "utilities-terminal"
        if (s.indexOf("linux")   >= 0)  return "distributor-logo-archlinux"
        return "drive-harddisk"
    }

    width:  ListView.view.width
    height: 62

    // Row background
    Rectangle {
        anchors.fill: parent
        color: entryCurrent
               ? Qt.rgba(0.18 + 0.04 * root.glow, 0.18 + 0.04 * root.glow, 0.26 + 0.04 * root.glow, 1.0)
               : (index % 2 === 0 ? "#202024" : "#242428")
        opacity: entryActive ? 1.0 : 0.5
        Behavior on color { ColorAnimation { duration: 300 } }
    }

    // Left accent — thin, white-ish, only for running entry
    Rectangle {
        visible: entryCurrent
        width: 3; height: parent.height
        anchors.left: parent.left
        color: Qt.rgba(1.0, 1.0, 1.0, 0.5 + 0.4 * root.glow)
    }

    // Bottom separator
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width; height: 1
        color: root.cBorder
        opacity: 0.5
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 14; rightMargin: 6 }
        spacing: 10

        Image {
            width: 28; height: 28
            source: "image://icon/" + osIconName(entryName)
            sourceSize: Qt.size(28, 28)
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: entryActive ? 1.0 : 0.35
        }

        Column {
            Layout.fillWidth: true
            spacing: 3

            Label {
                width: parent.width
                text: displayName(entryName)
                font.pixelSize: 14
                font.bold: entryCurrent
                elide: Text.ElideRight
                color: entryActive ? root.cText : root.cTextSub
                opacity: isGeneric ? 0.7 : 1.0
            }

            RowLayout {
                spacing: 10
                Label {
                    text: "Boot" + entryNum
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: root.cTextSub
                }
                Label {
                    visible: entryCurrent
                    text: "● running"
                    font.pixelSize: 11
                    font.bold: true
                    color: root.cGreen
                }
                Label {
                    visible: entryNext
                    text: "● next"
                    font.pixelSize: 11
                    font.bold: true
                    color: root.cBlue
                }
            }
        }

        // Move Up
        ToolButton {
            icon.name: "go-up"
            icon.color: root.cText
            icon.width: 14; icon.height: 14
            implicitWidth: 28; implicitHeight: 28
            enabled: !root.isFirst
            visible: !isGeneric || entryCurrent
            opacity: root.isFirst ? 0.2 : 0.8
            ToolTip.visible: hovered; ToolTip.delay: 600
            ToolTip.text: "Move this entry earlier in the boot order."
            onClicked: root.moveUpRequested(index)
            background: Rectangle {
                color: parent.pressed ? root.cBtnHov : parent.hovered ? root.cBtn : "transparent"
                border.color: parent.hovered ? root.cBorder : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
            }
        }

        // Move Down
        ToolButton {
            icon.name: "go-down"
            icon.color: root.cText
            icon.width: 14; icon.height: 14
            implicitWidth: 28; implicitHeight: 28
            enabled: !root.isLast
            visible: !isGeneric || entryCurrent
            opacity: root.isLast ? 0.2 : 0.8
            ToolTip.visible: hovered; ToolTip.delay: 600
            ToolTip.text: "Move this entry later in the boot order."
            onClicked: root.moveDownRequested(index)
            background: Rectangle {
                color: parent.pressed ? root.cBtnHov : parent.hovered ? root.cBtn : "transparent"
                border.color: parent.hovered ? root.cBorder : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
            }
        }

        // Enable / Disable
        ToolButton {
            icon.name: entryActive ? "dialog-cancel" : "dialog-ok-apply"
            icon.color: entryActive ? root.cRed : root.cGreen
            icon.width: 14; icon.height: 14
            implicitWidth: 28; implicitHeight: 28
            visible: !isGeneric
            ToolTip.visible: hovered; ToolTip.delay: 600
            ToolTip.text: entryActive
                ? "Disable this entry — the firmware will skip it during boot."
                : "Enable this entry — the firmware will include it in the boot sequence."
            onClicked: root.toggleActive(entryNum, !entryActive)
            background: Rectangle {
                color: parent.pressed ? root.cBtnHov : parent.hovered ? root.cBtn : "transparent"
                border.color: parent.hovered ? root.cBorder : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
            }
        }

        // Boot Once
        ToolButton {
            icon.name: "media-skip-forward"
            icon.color: root.cBlue
            icon.width: 14; icon.height: 14
            implicitWidth: 28; implicitHeight: 28
            visible: !isGeneric
            ToolTip.visible: hovered; ToolTip.delay: 600
            ToolTip.text: "Set as BootNext — boot this entry once on next reboot,\nthen revert to the normal boot order automatically."
            onClicked: root.setBootNextRequested(entryNum)
            background: Rectangle {
                color: parent.pressed ? root.cBtnHov : parent.hovered ? root.cBtn : "transparent"
                border.color: parent.hovered ? root.cBorder : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
            }
        }

        // Delete
        ToolButton {
            icon.name: "edit-delete"
            icon.color: root.cRed
            icon.width: 14; icon.height: 14
            implicitWidth: 28; implicitHeight: 28
            ToolTip.visible: hovered; ToolTip.delay: 600
            ToolTip.text: "Permanently delete this EFI entry.\nThis cannot be undone without recreating it manually."
            onClicked: root.deleteRequested(entryNum, entryName)
            background: Rectangle {
                color: parent.pressed ? Qt.rgba(0.85, 0.33, 0.31, 0.3) : parent.hovered ? Qt.rgba(0.85, 0.33, 0.31, 0.15) : "transparent"
                border.color: parent.hovered ? root.cRed : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
            }
        }

        Item { width: 2 }
    }
}
