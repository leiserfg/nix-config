import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Controls
PanelWindow {
    Keys.onPressed: {
        if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_Z) {
            paintCanvas.undo();
            event.accepted = true;
        } else if (event.key === Qt.Key_A) {
            paintCanvas.mode = "arrow";
            event.accepted = true;
        } else if (event.key === Qt.Key_R) {
            paintCanvas.mode = "rect";
            event.accepted = true;
        } else if (event.key === Qt.Key_P) {
            paintCanvas.mode = "rectPerimeter";
            event.accepted = true;
        } else if (event.key === Qt.Key_T) {
            paintCanvas.mode = "text";
            event.accepted = true;
        } else if (event.key === Qt.Key_Z) {
            paintCanvas.undo();
            event.accepted = true;
        }
    }

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
            text: "Arrow (A)"
            checkable: true
            checked: paintCanvas.mode === "arrow"
            onClicked: paintCanvas.mode = "arrow"
        }
        Button {
            text: "Rect (R)"
            checkable: true
            checked: paintCanvas.mode === "rect"
            onClicked: paintCanvas.mode = "rect"
        }
        Button {
            text: "Perimeter (P)"
            checkable: true
            checked: paintCanvas.mode === "rectPerimeter"
            onClicked: paintCanvas.mode = "rectPerimeter"
        }
        Button {
            text: "Text (T)"
            checkable: true
            checked: paintCanvas.mode === "text"
            onClicked: paintCanvas.mode = "text"
        }
        Button {
            text: "Undo (Z/Ctrl+Z)"
            onClicked: paintCanvas.undo()
        }
    }
    id: panel
    anchors {
        left: true
        bottom: true
        right: true
    }

        function drawRectangle(ctx, x1, y1, x2, y2, fill) {
            ctx.save();
            ctx.strokeStyle = "blue";
            ctx.lineWidth = 2;
            var rx = Math.min(x1, x2);
            var ry = Math.min(y1, y2);
            var rw = Math.abs(x2 - x1);
            var rh = Math.abs(y2 - y1);
            if (fill) {
                ctx.fillStyle = "rgba(0,0,255,0.2)";
                ctx.fillRect(rx, ry, rw, rh);
            }
            ctx.strokeRect(rx, ry, rw, rh);
            ctx.restore();
        }

        function drawText(ctx, x, y, text) {
            ctx.save();
            ctx.font = "16px sans-serif";
            ctx.fillStyle = "black";
            ctx.fillText(text, x, y);
            ctx.restore();
        }

        function undo() {
            if (paintCanvas.contextStack.length === 0)
                return;
            var last = paintCanvas.contextStack.pop();
            if (last.type === "arrow") {
                paintCanvas.arrows.pop();
            } else if (last.type === "rect") {
                paintCanvas.rectangles.pop();
            } else if (last.type === "rectPerimeter") {
                paintCanvas.rectanglePerimeters.pop();
            } else if (last.type === "text") {
                paintCanvas.texts.pop();
            }
            paintCanvas.requestPaint();
        }
    height: 300

    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Canvas {
        id: paintCanvas
        property var arrows: []
        property var rectangles: []
        property var rectanglePerimeters: []
        property var texts: []
        property var contextStack: []
        property var currentArrow: null
        property var currentRectangle: null
        property var currentRectanglePerimeter: null
        property var currentText: null
        property string mode: "arrow" // Modes: arrow, rect, rectPerimeter, text
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: btns.bottom
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            // Draw all arrows
            for (var i = 0; i < arrows.length; ++i) {
                drawArrow(ctx, arrows[i].x1, arrows[i].y1, arrows[i].x2, arrows[i].y2);
            }
            // Draw all rectangles
            for (var i = 0; i < rectangles.length; ++i) {
                drawRectangle(ctx, rectangles[i].x1, rectangles[i].y1, rectangles[i].x2, rectangles[i].y2, true);
            }
            // Draw all rectangle perimeters
            for (var i = 0; i < rectanglePerimeters.length; ++i) {
                drawRectangle(ctx, rectanglePerimeters[i].x1, rectanglePerimeters[i].y1, rectanglePerimeters[i].x2, rectanglePerimeters[i].y2, false);
            }
            // Draw all texts
            for (var i = 0; i < texts.length; ++i) {
                drawText(ctx, texts[i].x, texts[i].y, texts[i].text);
            }
            // Draw current shape if any
            if (paintCanvas.currentArrow && mode === "arrow") {
                drawArrow(ctx, currentArrow.x1, currentArrow.y1, currentArrow.x2, currentArrow.y2);
            }
            if (paintCanvas.currentRectangle && mode === "rect") {
                drawRectangle(ctx, currentRectangle.x1, currentRectangle.y1, currentRectangle.x2, currentRectangle.y2, true);
            }
            if (paintCanvas.currentRectanglePerimeter && mode === "rectPerimeter") {
                drawRectangle(ctx, currentRectanglePerimeter.x1, currentRectanglePerimeter.y1, currentRectanglePerimeter.x2, currentRectanglePerimeter.y2, false);
            }
            if (paintCanvas.currentText && mode === "text") {
                drawText(ctx, currentText.x, currentText.y, currentText.text);
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                if (paintCanvas.mode === "arrow") {
                    paintCanvas.currentArrow = {
                        x1: mouse.x,
                        y1: mouse.y,
                        x2: mouse.x,
                        y2: mouse.y
                    };
                } else if (paintCanvas.mode === "rect") {
                    paintCanvas.currentRectangle = {
                        x1: mouse.x,
                        y1: mouse.y,
                        x2: mouse.x,
                        y2: mouse.y
                    };
                } else if (paintCanvas.mode === "rectPerimeter") {
                    paintCanvas.currentRectanglePerimeter = {
                        x1: mouse.x,
                        y1: mouse.y,
                        x2: mouse.x,
                        y2: mouse.y
                    };
                } else if (paintCanvas.mode === "text") {
                    var text = prompt("Enter annotation text:", "");
                    if (text) {
                        paintCanvas.currentText = {
                            x: mouse.x,
                            y: mouse.y,
                            text: text
                        };
                        paintCanvas.texts.push(paintCanvas.currentText);
                        paintCanvas.contextStack.push({type: "text"});
                        paintCanvas.currentText = null;
                        paintCanvas.requestPaint();
                    }
                }
                paintCanvas.requestPaint();
            }
            onPositionChanged: {
                if (paintCanvas.mode === "arrow" && paintCanvas.currentArrow) {
                    paintCanvas.currentArrow.x2 = mouse.x;
                    paintCanvas.currentArrow.y2 = mouse.y;
                } else if (paintCanvas.mode === "rect" && paintCanvas.currentRectangle) {
                    paintCanvas.currentRectangle.x2 = mouse.x;
                    paintCanvas.currentRectangle.y2 = mouse.y;
                } else if (paintCanvas.mode === "rectPerimeter" && paintCanvas.currentRectanglePerimeter) {
                    paintCanvas.currentRectanglePerimeter.x2 = mouse.x;
                    paintCanvas.currentRectanglePerimeter.y2 = mouse.y;
                }
                paintCanvas.requestPaint();
            }
            onReleased: {
                if (paintCanvas.mode === "arrow" && paintCanvas.currentArrow) {
                    paintCanvas.arrows.push(paintCanvas.currentArrow);
                    paintCanvas.contextStack.push({type: "arrow"});
                    paintCanvas.currentArrow = null;
                } else if (paintCanvas.mode === "rect" && paintCanvas.currentRectangle) {
                    paintCanvas.rectangles.push(paintCanvas.currentRectangle);
                    paintCanvas.contextStack.push({type: "rect"});
                    paintCanvas.currentRectangle = null;
                } else if (paintCanvas.mode === "rectPerimeter" && paintCanvas.currentRectanglePerimeter) {
                    paintCanvas.rectanglePerimeters.push(paintCanvas.currentRectanglePerimeter);
                    paintCanvas.contextStack.push({type: "rectPerimeter"});
                    paintCanvas.currentRectanglePerimeter = null;
                }
                paintCanvas.requestPaint();
            }
        }

        function drawArrow(ctx, x1, y1, x2, y2) {
            ctx.save();
            ctx.strokeStyle = "black";
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(x1, y1);
            ctx.lineTo(x2, y2);
            ctx.stroke();

            // Arrowhead
            var angle = Math.atan2(y2 - y1, x2 - x1);
            var headlen = 15;
            var arrowAngle = Math.PI / 7;
            var x3 = x2 - headlen * Math.cos(angle - arrowAngle);
            var y3 = y2 - headlen * Math.sin(angle - arrowAngle);
            var x4 = x2 - headlen * Math.cos(angle + arrowAngle);
            var y4 = y2 - headlen * Math.sin(angle + arrowAngle);

            ctx.beginPath();
            ctx.moveTo(x2, y2);
            ctx.lineTo(x3, y3);
            ctx.moveTo(x2, y2);
            ctx.lineTo(x4, y4);
            ctx.stroke();
            ctx.restore();
        }
    }
}
