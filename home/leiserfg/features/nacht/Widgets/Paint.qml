import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Controls

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
                paintCanvas.commitCurrentItem();
                paintCanvas.mode = "arrow";
            }
        }
        Button {
            text: "Rect"
            checkable: true
            checked: paintCanvas.mode === "rect"
            onClicked: {
                paintCanvas.commitCurrentItem();
                paintCanvas.mode = "rect";
            }
        }
        Button {
            text: "Perimeter"
            checkable: true
            checked: paintCanvas.mode === "rectPerimeter"
            onClicked: {
                paintCanvas.commitCurrentItem();
                paintCanvas.mode = "rectPerimeter";
            }
        }
        Button {
            text: "Undo"
            onClicked: undo()
        }
    }
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
        }
        paintCanvas.requestPaint();
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
        function commitCurrentItem() {
            if (currentArrow) {
                arrows.push(currentArrow);
                contextStack.push({
                    type: "arrow"
                });
                currentArrow = null;
            } else if (currentRectangle) {
                rectangles.push(currentRectangle);
                contextStack.push({
                    type: "rect"
                });
                currentRectangle = null;
            } else if (currentRectanglePerimeter) {
                rectanglePerimeters.push(currentRectanglePerimeter);
                contextStack.push({
                    type: "rectPerimeter"
                });
                currentRectanglePerimeter = null;
            }
            requestPaint();
        }
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

            {
                ctx.save();
                ctx.lineWidth = 1;
                ctx.fillStyle = "white";
                ctx.strokeStyle = "black";
                function drawHandler(x, y) {
                    ctx.beginPath();
                    ctx.arc(x, y, 3, 0, 2 * Math.PI);
                    ctx.fill();
                    ctx.stroke();
                }
                if (paintCanvas.currentArrow && mode === "arrow") {
                    drawHandler(currentArrow.x1, currentArrow.y1);
                    drawHandler(currentArrow.x2, currentArrow.y2);
                }
                if (paintCanvas.currentRectangle && mode === "rect") {
                    var rx1 = currentRectangle.x1, ry1 = currentRectangle.y1, rx2 = currentRectangle.x2, ry2 = currentRectangle.y2;
                    drawHandler(rx1, ry1);
                    drawHandler(rx2, ry1);
                    drawHandler(rx1, ry2);
                    drawHandler(rx2, ry2);
                }
                if (paintCanvas.currentRectanglePerimeter && mode === "rectPerimeter") {
                    var px1 = currentRectanglePerimeter.x1, py1 = currentRectanglePerimeter.y1, px2 = currentRectanglePerimeter.x2, py2 = currentRectanglePerimeter.y2;
                    drawHandler(px1, py1);
                    drawHandler(px2, py1);
                    drawHandler(px1, py2);
                    drawHandler(px2, py2);
                }
                ctx.restore();
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => {
                // Handler drag logic
                if (paintCanvas.mode === "arrow" && paintCanvas.currentArrow) {
                    // Check if near endpoints
                    if (Math.abs(mouse.x - paintCanvas.currentArrow.x1) < 10 && Math.abs(mouse.y - paintCanvas.currentArrow.y1) < 10) {
                        paintCanvas.handlerDrag = {
                            type: "arrow",
                            point: "start"
                        };
                    } else if (Math.abs(mouse.x - paintCanvas.currentArrow.x2) < 10 && Math.abs(mouse.y - paintCanvas.currentArrow.y2) < 10) {
                        paintCanvas.handlerDrag = {
                            type: "arrow",
                            point: "end"
                        };
                    }
                } else if ((paintCanvas.mode === "rect" && paintCanvas.currentRectangle) || (paintCanvas.mode === "rectPerimeter" && paintCanvas.currentRectanglePerimeter)) {
                    var rect = paintCanvas.mode === "rect" ? paintCanvas.currentRectangle : paintCanvas.currentRectanglePerimeter;
                    // Check corners
                    var corners = [
                        {
                            x: rect.x1,
                            y: rect.y1,
                            name: "tl"
                        },
                        {
                            x: rect.x2,
                            y: rect.y1,
                            name: "tr"
                        },
                        {
                            x: rect.x1,
                            y: rect.y2,
                            name: "bl"
                        },
                        {
                            x: rect.x2,
                            y: rect.y2,
                            name: "br"
                        }
                    ];
                    for (var i = 0; i < corners.length; ++i) {
                        if (Math.abs(mouse.x - corners[i].x) < 10 && Math.abs(mouse.y - corners[i].y) < 10) {
                            paintCanvas.handlerDrag = {
                                type: paintCanvas.mode,
                                corner: corners[i].name
                            };
                            break;
                        }
                    }

                    // Draw handlers for current item
                } else {
                    // Start new item
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
                    }
                }
                paintCanvas.requestPaint();
            }
            onPositionChanged: mouse => {
                if (paintCanvas.handlerDrag) {
                    if (paintCanvas.handlerDrag.type === "arrow" && paintCanvas.currentArrow) {
                        if (paintCanvas.handlerDrag.point === "start") {
                            paintCanvas.currentArrow.x1 = mouse.x;
                            paintCanvas.currentArrow.y1 = mouse.y;
                        } else if (paintCanvas.handlerDrag.point === "end") {
                            paintCanvas.currentArrow.x2 = mouse.x;
                            paintCanvas.currentArrow.y2 = mouse.y;
                        }
                    } else if ((paintCanvas.handlerDrag.type === "rect" || paintCanvas.handlerDrag.type === "rectPerimeter") && (paintCanvas.currentRectangle || paintCanvas.currentRectanglePerimeter)) {
                        var rect = paintCanvas.handlerDrag.type === "rect" ? paintCanvas.currentRectangle : paintCanvas.currentRectanglePerimeter;
                        switch (paintCanvas.handlerDrag.corner) {
                        case "tl":
                            rect.x1 = mouse.x;
                            rect.y1 = mouse.y;
                            break;
                        case "tr":
                            rect.x2 = mouse.x;
                            rect.y1 = mouse.y;
                            break;
                        case "bl":
                            rect.x1 = mouse.x;
                            rect.y2 = mouse.y;
                            break;
                        case "br":
                            rect.x2 = mouse.x;
                            rect.y2 = mouse.y;
                            break;
                        }
                    }
                } else {
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
                }
                paintCanvas.requestPaint();
            }
            onReleased: {
                paintCanvas.handlerDrag = null;
                paintCanvas.requestPaint();
            }
            onDoubleClicked: {
                paintCanvas.commitCurrentItem();
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
