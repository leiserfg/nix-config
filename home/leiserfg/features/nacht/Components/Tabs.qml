import QtQuick
import QtQuick.Layouts
import qs.Settings

Item {
    id: root
    property var tabsModel: []
    property int currentIndex: 0
    signal tabChanged(int index)

    RowLayout {
        id: tabBar
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        Repeater {
            model: root.tabsModel
            delegate: Rectangle {
                id: tabWrapper
                implicitHeight: tab.height
                implicitWidth: 56
                color: "transparent"

                property bool hovered: false

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (currentIndex !== index) {
                            currentIndex = index;
                            tabChanged(index);
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                }

                ColumnLayout {
                    id: tab
                    spacing: 2
                    anchors.centerIn: parent
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Icon
                    Text {
                        text: modelData.icon
                        font.family: "Material Symbols Sharp"
                        font.pixelSize: 22
                        color: index === root.currentIndex ? (Theme ? Theme.accentPrimary : "#7C3AED") : tabWrapper.hovered ? (Theme ? Theme.accentPrimary : "#7C3AED") : (Theme ? Theme.textSecondary : "#444")
                        Layout.alignment: Qt.AlignCenter
                    }

                    // Label
                    Text {
                        text: modelData.label
                        font.pixelSize: 12
                        font.bold: index === root.currentIndex
                        color: index === root.currentIndex ? (Theme ? Theme.accentPrimary : "#7C3AED") : tabWrapper.hovered ? (Theme ? Theme.accentPrimary : "#7C3AED") : (Theme ? Theme.textSecondary : "#444")
                        Layout.alignment: Qt.AlignCenter
                    }

                    // Underline for active tab
                    Rectangle {
                        width: 24
                        height: 2
                        radius: 1
                        color: index === root.currentIndex ? (Theme ? Theme.accentPrimary : "#7C3AED") : "transparent"
                        Layout.alignment: Qt.AlignCenter
                    }
                }
            }
        }
    }
}
