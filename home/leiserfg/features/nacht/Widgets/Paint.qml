import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Controls

import "PaintLogic.js" as PaintLogic

PanelWindow {
    id: panel

    anchors {
        left: true
        bottom: true
        right: true
    }

    implicitHeight: 300

    WlrLayershell.exclusionMode: ExclusionMode.Auto
    focusable: true

    Column {
        id: controls
        spacing: 8
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 12
            topMargin: 12
        }

        Row {
            id: btns
            spacing: 8

            ButtonGroup {
                id: toolGroup
            }

            Button {
                text: "Arrow"
                checkable: true
                checked: paintCanvas.paintState.mode === "arrow"
                ButtonGroup.group: toolGroup
                onClicked: {
                    PaintLogic.commitCurrentItem(paintCanvas);
                    paintCanvas.paintState.mode = "arrow";
                }
            }
            Button {
                text: "Rect"
                checkable: true
                checked: paintCanvas.paintState.mode === "rect"
                ButtonGroup.group: toolGroup
                onClicked: {
                    PaintLogic.commitCurrentItem(paintCanvas);
                    paintCanvas.paintState.mode = "rect";
                }
            }
            Button {
                text: "Undo"
                onClicked: PaintLogic.undo(paintCanvas)
            }
        }

        Row {
            id: attributeControls
            spacing: 8

            property var currentTool: PaintLogic.getTool(paintCanvas.paintState.mode)

            Repeater {
                model: attributeControls.currentTool ? attributeControls.currentTool.visibleAttributes : []
                delegate: Row {
                    spacing: 4
                    Text {
                        text: modelData.charAt(0).toUpperCase() + modelData.slice(1).replace(/([A-Z])/g, ' $1') + ":"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TextField {
                        text: paintCanvas.paintState.toolArgs[modelData] || (attributeControls.currentTool ? attributeControls.currentTool.defaultArgs[modelData] || "" : "")
                        onTextChanged: {
                            paintCanvas.paintState.toolArgs[modelData] = text;
                        }
                    }
                }
            }
        }
    }

    Canvas {
        id: paintCanvas
        property var paintState: ({
                arrows: [],
                rectangles: [],
                contextStack: [],
                mode: "arrow",
                handlerDrag: null,
                currentTool: null,
                currentItem: null,
                toolArgs: {
                    lineColor: "black",
                    fillColor: "rgba(0,0,255,0.2)",
                    borderColor: "blue"
                }
            })

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: controls.bottom
        anchors.topMargin: 8

        onPaint: {
            PaintLogic.paintCanvas(paintCanvas);
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPressed: mouse => {
                PaintLogic.onPressed(paintCanvas, mouse);
            }
            onPositionChanged: mouse => {
                PaintLogic.onPositionChanged(paintCanvas, mouse);
            }
            onReleased: {
                PaintLogic.onReleased(paintCanvas);
            }
        }
    }
}
