import QtQuick
import QtQuick.Window 2.15
import qs.Settings

Window {
    id: tooltipWindow
    property string text: ""
    property bool tooltipVisible: false
    property Item targetItem: null
    property int delay: 300

    // New property to control positioning: true => above, false => below
    property bool positionAbove: true

    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    property var _timerObj: null

    onTooltipVisibleChanged: {
        if (tooltipVisible) {
            if (delay > 0) {
                if (_timerObj) { _timerObj.destroy(); _timerObj = null; }
                _timerObj = Qt.createQmlObject(
                    'import QtQuick 2.0; Timer { interval: ' + delay + '; running: true; repeat: false; onTriggered: tooltipWindow._showNow() }',
                    tooltipWindow);
            } else {
                _showNow();
            }
        } else {
            _hideNow();
        }
    }

    function _showNow() {
        width = Math.max(50, tooltipText.implicitWidth + 24)
        height = Math.max(50, tooltipText.implicitHeight + 16)

        if (!targetItem) return;

        if (positionAbove) {
            // Position tooltip above the target item
            var pos = targetItem.mapToGlobal(0, 0);
            x = pos.x - width / 2 + targetItem.width / 2;
            y = pos.y - height - 12; // 12 px margin above
        } else {
            // Position tooltip below the target item
            var pos = targetItem.mapToGlobal(0, targetItem.height);
            x = pos.x - width / 2 + targetItem.width / 2;
            y = pos.y + 12; // 12 px margin below
        }
        visible = true;
    }

    function _hideNow() {
        visible = false;
        if (_timerObj) { _timerObj.destroy(); _timerObj = null; }
    }

    Connections {
        target: tooltipWindow.targetItem
        function onXChanged() {
            if (tooltipWindow.visible) tooltipWindow._showNow();
        }
        function onYChanged() {
            if (tooltipWindow.visible) tooltipWindow._showNow();
        }
        function onWidthChanged() {
            if (tooltipWindow.visible) tooltipWindow._showNow();
        }
        function onHeightChanged() {
            if (tooltipWindow.visible) tooltipWindow._showNow();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Theme.backgroundTertiary || "#222"
        border.color: Theme.outline || "#444"
        border.width: 1
        opacity: 0.97
        z: 1
    }

    Text {
        id: tooltipText
        text: tooltipWindow.text
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        padding: 8
        z: 2
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: tooltipWindow.tooltipVisible = false
        cursorShape: Qt.ArrowCursor
    }

    onTextChanged: {
        width = Math.max(minimumWidth, tooltipText.implicitWidth + 24);
        height = Math.max(minimumHeight, tooltipText.implicitHeight + 16);
    }
}
