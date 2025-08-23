import QtQuick
import QtQuick.Window
import Quickshell
import qs.Services
import qs.Components

Item {
    id: root
    required property ShellScreen screen

    anchors.verticalCenter: parent.verticalCenter
    property int spacingBetweenPills: 8

    width: pillRow.width

    Row {
        id: pillRow
        spacing: root.spacingBetweenPills
        anchors.verticalCenter: parent.verticalCenter
        Repeater {
            id: workspaceRepeater
            model: Hyprland.workspaces
            HyprlandWorkspaceFragment {
                workspace: modelData
            }
        }
    }
}
