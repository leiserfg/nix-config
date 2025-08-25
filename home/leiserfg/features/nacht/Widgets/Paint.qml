import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Controls
import "PaintLogic.js" as PaintLogic

PanelWindow {
    id: panel

    Row {
        id: btns
        spacing: 8
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 12
            topMargin: 12
        }
        Button {
            text: "Arrow"
            checkable: true
            checked: paintCanvas.mode === "arrow"
            onClicked: {
                PaintLogic.commitCurrentItem(paintCanvas);
                paintCanvas.mode = "arrow";
            }
        }
        Button {
            text: "Rect"
            checkable: true
            checked: paintCanvas.mode === "rect"
            onClicked: {
                PaintLogic.commitCurrentItem(paintCanvas);
                paintCanvas.mode = "rect";
            }
        }
        Button {
            text: "Perimeter"
            checkable: true
            checked: paintCanvas.mode === "rectPerimeter"
            onClicked: {
                PaintLogic.commitCurrentItem(paintCanvas);
                paintCanvas.mode = "rectPerimeter";
            }
        }
        Button {
            text: "Undo"
            onClicked: PaintLogic.undo(paintCanvas)
        }
    }
    anchors {
        left: true
        bottom: true
        right: true
    }

    implicitHeight: 300

    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Canvas {
        id: paintCanvas
        property var arrows: []
        property var rectangles: []
        property var rectanglePerimeters: []
        property var contextStack: []
        property var currentArrow: null
        property var currentRectangle: null
        property var currentRectanglePerimeter: null
        property string mode: "arrow" // Modes: arrow, rect, rectPerimeter
        property var handlerDrag: null

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: btns.bottom
        onPaint: {
            PaintLogic.paintCanvas(paintCanvas);
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => {
                PaintLogic.onPressed(paintCanvas, mouse);
            }
            onPositionChanged: mouse => {
                PaintLogic.onPositionChanged(paintCanvas, mouse);
            }
            onReleased: {
                PaintLogic.onReleased(paintCanvas);
            }
            onDoubleClicked: {
                PaintLogic.onDoubleClicked(paintCanvas);
            }
        }
    }
}
