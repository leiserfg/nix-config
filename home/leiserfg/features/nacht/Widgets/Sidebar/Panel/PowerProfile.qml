import QtQuick 
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.UPower
import qs.Settings
import qs.Components

Rectangle {
    id: card
    width: 200
    height: 70
    color: Theme.surface
    radius: 18

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        // Performance
        Rectangle {
            width: 36; height: 36
            radius: 18
            border.color: Theme.accentPrimary
            border.width: 1
            color: (typeof PowerProfiles !== 'undefined' && PowerProfiles.profile === PowerProfile.Performance)
                ? Theme.accentPrimary
                : (perfMouseArea.containsMouse ? Theme.accentPrimary : "transparent")
            opacity: (typeof PowerProfiles !== 'undefined' && !PowerProfiles.hasPerformanceProfile) ? 0.4 : 1

            Text {
                id: perfIcon
                anchors.centerIn: parent
                text: "speed"
                font.family: "Material Symbols Sharp"
                font.pixelSize: 22
                color: (typeof PowerProfiles !== 'undefined' && PowerProfiles.profile === PowerProfile.Performance) || perfMouseArea.containsMouse
                    ? Theme.backgroundPrimary
                    : Theme.accentPrimary
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                id: perfMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: typeof PowerProfiles !== 'undefined' && PowerProfiles.hasPerformanceProfile
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof PowerProfiles !== 'undefined')
                        PowerProfiles.profile = PowerProfile.Performance;
                }
                onEntered: perfTooltip.tooltipVisible = true
                onExited: perfTooltip.tooltipVisible = false
            }
            StyledTooltip {
                id: perfTooltip
                text: "Performance Profile"
                tooltipVisible: false
                targetItem: perfIcon
                delay: 200
            }
        }

        // Balanced
        Rectangle {
            width: 36; height: 36
            radius: 18
            border.color: Theme.accentPrimary
            border.width: 1
            color: (typeof PowerProfiles !== 'undefined' && PowerProfiles.profile === PowerProfile.Balanced)
                ? Theme.accentPrimary
                : (balMouseArea.containsMouse ? Theme.accentPrimary : "transparent")
            opacity: 1

            Text {
                id: balIcon
                anchors.centerIn: parent
                text: "balance"
                font.family: "Material Symbols Sharp"
                font.pixelSize: 22
                color: (typeof PowerProfiles !== 'undefined' && PowerProfiles.profile === PowerProfile.Balanced) || balMouseArea.containsMouse
                    ? Theme.backgroundPrimary
                    : Theme.accentPrimary
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                id: balMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof PowerProfiles !== 'undefined')
                        PowerProfiles.profile = PowerProfile.Balanced;
                }
                onEntered: balTooltip.tooltipVisible = true
                onExited: balTooltip.tooltipVisible = false
            }
            StyledTooltip {
                id: balTooltip
                text: "Balanced Profile"
                tooltipVisible: false
                targetItem: balIcon
                delay: 200
            }
        }

        // Power Saver
        Rectangle {
            width: 36; height: 36
            radius: 18
            border.color: Theme.accentPrimary
            border.width: 1
            color: (typeof PowerProfiles !== 'undefined' && PowerProfiles.profile === PowerProfile.PowerSaver)
                ? Theme.accentPrimary
                : (saveMouseArea.containsMouse ? Theme.accentPrimary : "transparent")
            opacity: 1

            Text {
                id: saveIcon
                anchors.centerIn: parent
                text: "eco"
                font.family: "Material Symbols Sharp"
                font.pixelSize: 22
                color: (typeof PowerProfiles !== 'undefined' && PowerProfiles.profile === PowerProfile.PowerSaver) || saveMouseArea.containsMouse
                    ? Theme.backgroundPrimary
                    : Theme.accentPrimary
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                id: saveMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof PowerProfiles !== 'undefined')
                        PowerProfiles.profile = PowerProfile.PowerSaver;
                }
                onEntered: saveTooltip.tooltipVisible = true
                onExited: saveTooltip.tooltipVisible = false
            }
            StyledTooltip {
                id: saveTooltip
                text: "Power Saver Profile"
                tooltipVisible: false
                targetItem: saveIcon
                delay: 200
            }
        }
    }
} 