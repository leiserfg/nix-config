import QtQuick
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Settings

Item {
    id: brightnessDisplay
    property int brightness: -1
    property int previousBrightness: -1
    property var screen: (typeof modelData !== 'undefined' ? modelData : null)
    property string monitorName: screen ? screen.name : "DP-1"
    property bool isSettingBrightness: false
    property bool hasPendingSet: false
    property int pendingSetValue: -1
    property bool firstChange: true

    width: pill.width
    height: pill.height

    Process {
        id: getBrightnessProcess
        command: ["brillo"]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                const val = parseFloat(output);
                if (isNaN(val))
                    return;
                if (val < 0) {
                    brightnessDisplay.visible = false;
                } else if (val >= 0 && val !== previousBrightness) {
                    brightnessDisplay.visible = true;
                    previousBrightness = brightness;
                    brightness = val;
                    // pill.text = brightness + "%";

                    if (firstChange) {
                        firstChange = false;
                    } else {
                        pill.show();
                    }
                }
            }
        }
    }

    function getBrightness() {
        getBrightnessProcess.running = true;
    }

    Process {
        id: setBrightnessProcess
        property int targetValue: -1
        command: ["brillo", "-S", targetValue.toString()]
        onExited: status_code => {
            if (status_code == 0) {
                brightnessDisplay.brightness = parseFloat(targetValue);
            }
        }
    }

    function setBrightness(newValue) {
        newValue = Math.max(0, Math.min(100, newValue));
        setBrightnessProcess.targetValue = newValue;
        setBrightnessProcess.running = true;
    }

    PillIndicator {
        id: pill
        icon: "brightness_high"
        text: brightnessDisplay.brightness >= 0 ? brightnessDisplay.brightness + "%" : "--"
        pillColor: Theme.surfaceVariant
        iconCircleColor: Theme.accentPrimary
        iconTextColor: Theme.backgroundPrimary
        textColor: Theme.textPrimary
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                brightnessDisplay.getBrightness();
                brightnessTooltip.tooltipVisible = true;
                pill.showDelayed();
            }
            onExited: {
                brightnessTooltip.tooltipVisible = false;
                pill.hide();
            }

            onWheel: function (wheel) {
                const delta = wheel.angleDelta.y > 0 ? 5 : -5;
                const newBrightness = brightness + delta;
                setBrightness(newBrightness);
            }
        }
        StyledTooltip {
            id: brightnessTooltip
            text: "Brightness: " + brightness + "%"
            positionAbove: false
            tooltipVisible: false
            targetItem: pill
            delay: 1500
        }
    }

    Component.onCompleted: {
        getBrightness();
    }
}
