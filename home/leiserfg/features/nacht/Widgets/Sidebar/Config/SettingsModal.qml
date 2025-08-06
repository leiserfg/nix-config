import QtQuick 
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Settings
import qs.Services
import qs.Components

PanelWindow {
    id: settingsModal
    implicitWidth: 480
    implicitHeight: 780
    visible: false
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins.right: 0
    margins.top: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundPrimary
        radius: 20
        z: 0

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 32
            spacing: 24

            // Header
            ColumnLayout {
                id: header
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    Text {
                        text: "settings"
                        font.family: "Material Symbols Sharp"
                        font.pixelSize: 32
                        color: Theme.accentPrimary
                    }
                    Text {
                        text: "Settings"
                        font.pixelSize: 26
                        font.bold: true
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: closeButtonArea.containsMouse ? Theme.accentPrimary : "transparent"
                        border.color: Theme.accentPrimary
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "close"
                            font.family: closeButtonArea.containsMouse ? "Material Symbols Rounded" : "Material Symbols Sharp"
                            font.pixelSize: 20
                            color: closeButtonArea.containsMouse ? Theme.onAccent : Theme.accentPrimary
                        }
                        MouseArea {
                            id: closeButtonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: settingsModal.closeSettings()
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.outline
                    opacity: 0.12
                }
            }

            // Tabs bar (reordered)
            Tabs {
                id: settingsTabs
                Layout.fillWidth: true
                tabsModel: [
                    { icon: "settings", label: "System" },
                    { icon: "wallpaper", label: "Wallpaper" },
                    { icon: "cloud", label: "Weather" }
                ]
            }

            // Scrollable settings area
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: content.height - settingsTabs.height - header.height - 128
                color: "transparent"
                border.width: 0
                radius: 20

                Flickable {
                    id: flick
                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: tabContentLoader.item ? tabContentLoader.item.implicitHeight : 0
                    clip: true

                    Loader {
                        id: tabContentLoader
                        anchors.top: parent.top
                        width: parent.width
                        sourceComponent: settingsTabs.currentIndex === 0 ? systemTab : settingsTabs.currentIndex === 1 ? wallpaperTab : weatherTab
                    }
                }

                Component {
                    id: systemTab
                    ColumnLayout {
                        anchors.fill: parent
                        ProfileSettings {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            anchors.margins: 16
                        }
                    }
                }

                Component {
                    id: wallpaperTab
                    ColumnLayout {
                        anchors.fill: parent
                        WallpaperSettings {
                            id: wallpaperSettings
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            anchors.margins: 16
                        }
                    }
                }

                Component {
                    id: weatherTab
                    ColumnLayout {
                        anchors.fill: parent
                        WeatherSettings {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            anchors.margins: 16
                        }
                    }
                }
            }
        }
    }

    // Function to open the modal and initialize temp values
    function openSettings() {        
        visible = true;
        focusTimer.start();
    }

    // Function to close the modal and release focus
    function closeSettings() {
        visible = false;
    }

    Timer {
        id: focusTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (visible) {
                // Focus logic can go here if needed
            }
        }
    }

    // Refresh weather data when hidden
    onVisibleChanged: {
        if (!visible && typeof weather !== 'undefined' && weather !== null && weather.fetchCityWeather) {
            weather.fetchCityWeather();
        }
    }
}
