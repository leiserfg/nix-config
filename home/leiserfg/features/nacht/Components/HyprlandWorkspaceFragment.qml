import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Settings
import qs.Components
import Quickshell.Hyprland

Item {
    id: tasks
    width: Math.max(runningAppsRow.width, Settings.settings.barHeight / 2)
    height: Settings.settings.barHeight
    visible: Settings.settings.showTaskbar
    property HyprlandWorkspace workspace

    // Attach custom tooltip
    StyledTooltip {
        id: styledTooltip
        positionAbove: false
    }

    function getAppIcon(toplevel: Toplevel): string {
        if (!toplevel)
            return "";

        let icon = Quickshell.iconPath(toplevel.appId?.toLowerCase(), true);
        if (!icon) {
            icon = Quickshell.iconPath(toplevel.appId, true);
        }
        if (!icon) {
            icon = Quickshell.iconPath(toplevel.title?.toLowerCase(), true);
        }
        if (!icon) {
            icon = Quickshell.iconPath(toplevel.title, true);
        }
        if (!icon) {
            icon = Quickshell.iconPath("application-x-executable", true);
        }

        return icon || "";
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceVariant
        radius: Math.max(4, Settings.settings.barHeight * 0.25)
        border.color: tasks.workspace.focused ? Qt.darker(Theme.accentPrimary, 1.2) : "transparent"
    }

    Row {
        id: runningAppsRow
        spacing: 8
        height: Settings.settings.barHeight - 2
        Repeater {
            model: tasks.workspace.toplevels

            delegate: Rectangle {
                id: appButton
                width: Settings.settings.barHeight
                height: Settings.settings.barHeight
                radius: Math.max(4, Settings.settings.barHeight * 0.25)
                color: isActive ? Theme.accentPrimary : (hovered ? Theme.surfaceVariant : "transparent")
                border.color: isActive ? Qt.darker(Theme.accentPrimary, 1.2) : "transparent"
                border.width: 1
                property Toplevel waylandToplevel: modelData.wayland

                property bool isActive: modelData?.activated && tasks.workspace.focused
                property bool hovered: mouseArea.containsMouse
                property string appId: waylandToplevel ? waylandToplevel.appId : ""
                property string appTitle: waylandToplevel ? waylandToplevel.title : ""

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                IconImage {
                    id: appIcon
                    width: Math.max(12, Settings.settings.barHeight * 0.625)
                    height: Math.max(12, Settings.settings.barHeight * 0.625)
                    anchors.centerIn: parent
                    source: getAppIcon(waylandToplevel)
                    visible: source.toString() !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: !appIcon.visible
                    text: appButton.appId ? appButton.appId.charAt(0).toUpperCase() : "?"
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.max(10, Settings.settings.barHeight * 0.4375)
                    font.bold: true
                    color: appButton.isActive && tasks.workspace.focused ? Theme.onAccent : Theme.textPrimary
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: {
                        var text = appTitle || appId;
                        styledTooltip.text = text.length > 60 ? text.substring(0, 60) + "..." : text;
                        styledTooltip.targetItem = appButton;
                        styledTooltip.tooltipVisible = true;
                    }

                    onExited: {
                        styledTooltip.tooltipVisible = false;
                    }

                    onClicked: function (mouse) {
                        if (mouse.button === Qt.MiddleButton) {
                            if (waylandToplevel && waylandToplevel.close) {
                                waylandToplevel.close();
                            }
                        }

                        if (mouse.button === Qt.LeftButton) {
                            if (waylandToplevel && waylandToplevel.activate) {
                                waylandToplevel.activate();
                            }
                        }
                    }

                    onPressed: mouse => {
                        if (mouse.button === Qt.RightButton)
                        // context menu logic (optional)
                        {}
                    }
                }

                Rectangle {
                    visible: isActive
                    width: 4
                    height: 4
                    radius: 2
                    color: Theme.onAccent
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: -6
                }
            }
        }
    }

    // Rectangle {
    //     id: badge
    //     anchors.bottom: parent.bottom
    //     anchors.right: parent.right
    //     width: Settings.settings.barHeight * 0.5
    //     height: Settings.settings.barHeight / 2
    //     color: Theme.surfaceVariant
    //     radius: Math.max(4, Settings.settings.barHeight * 0.25)
    //     Text {
    //         anchors.horizontalCenter: badge.horizontalCenter
    //         text: workspace.name
    //         font.pixelSize: Settings.settings.barHeight * 0.5
    //         color: Qt.darker(Theme.accentPrimary, 1.2)
    //     }
    // }
}
