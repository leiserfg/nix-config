.pragma library

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

function undo(paintCanvas) {
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

function commitCurrentItem(paintCanvas) {
    if (paintCanvas.currentArrow) {
        paintCanvas.arrows.push(paintCanvas.currentArrow);
        paintCanvas.contextStack.push({
            type: "arrow"
        });
        paintCanvas.currentArrow = null;
    } else if (paintCanvas.currentRectangle) {
        paintCanvas.rectangles.push(paintCanvas.currentRectangle);
        paintCanvas.contextStack.push({
            type: "rect"
        });
        paintCanvas.currentRectangle = null;
    } else if (paintCanvas.currentRectanglePerimeter) {
        paintCanvas.rectanglePerimeters.push(paintCanvas.currentRectanglePerimeter);
        paintCanvas.contextStack.push({
            type: "rectPerimeter"
        });
        paintCanvas.currentRectanglePerimeter = null;
    }
    paintCanvas.requestPaint();
}

function onPressed(paintCanvas, mouse) {
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

function onPositionChanged(paintCanvas, mouse) {
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

function onReleased(paintCanvas) {
    paintCanvas.handlerDrag = null;
    paintCanvas.requestPaint();
}

function onDoubleClicked(paintCanvas) {
    commitCurrentItem(paintCanvas);
}

function paintCanvas(paintCanvas) {
    var ctx = paintCanvas.getContext("2d");
    ctx.clearRect(0, 0, paintCanvas.width, paintCanvas.height);
    
    // Draw all arrows
    for (var i = 0; i < paintCanvas.arrows.length; ++i) {
        drawArrow(ctx, paintCanvas.arrows[i].x1, paintCanvas.arrows[i].y1, paintCanvas.arrows[i].x2, paintCanvas.arrows[i].y2);
    }
    
    // Draw all rectangles
    for (var i = 0; i < paintCanvas.rectangles.length; ++i) {
        drawRectangle(ctx, paintCanvas.rectangles[i].x1, paintCanvas.rectangles[i].y1, paintCanvas.rectangles[i].x2, paintCanvas.rectangles[i].y2, true);
    }
    
    // Draw all rectangle perimeters
    for (var i = 0; i < paintCanvas.rectanglePerimeters.length; ++i) {
        drawRectangle(ctx, paintCanvas.rectanglePerimeters[i].x1, paintCanvas.rectanglePerimeters[i].y1, paintCanvas.rectanglePerimeters[i].x2, paintCanvas.rectanglePerimeters[i].y2, false);
    }
    
    // Draw current shape if any
    if (paintCanvas.currentArrow && paintCanvas.mode === "arrow") {
        drawArrow(ctx, paintCanvas.currentArrow.x1, paintCanvas.currentArrow.y1, paintCanvas.currentArrow.x2, paintCanvas.currentArrow.y2);
    }
    if (paintCanvas.currentRectangle && paintCanvas.mode === "rect") {
        drawRectangle(ctx, paintCanvas.currentRectangle.x1, paintCanvas.currentRectangle.y1, paintCanvas.currentRectangle.x2, paintCanvas.currentRectangle.y2, true);
    }
    if (paintCanvas.currentRectanglePerimeter && paintCanvas.mode === "rectPerimeter") {
        drawRectangle(ctx, paintCanvas.currentRectanglePerimeter.x1, paintCanvas.currentRectanglePerimeter.y1, paintCanvas.currentRectanglePerimeter.x2, paintCanvas.currentRectanglePerimeter.y2, false);
    }

    // Draw handlers
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
    
    if (paintCanvas.currentArrow && paintCanvas.mode === "arrow") {
        drawHandler(paintCanvas.currentArrow.x1, paintCanvas.currentArrow.y1);
        drawHandler(paintCanvas.currentArrow.x2, paintCanvas.currentArrow.y2);
    }
    if (paintCanvas.currentRectangle && paintCanvas.mode === "rect") {
        var rx1 = paintCanvas.currentRectangle.x1, ry1 = paintCanvas.currentRectangle.y1, rx2 = paintCanvas.currentRectangle.x2, ry2 = paintCanvas.currentRectangle.y2;
        drawHandler(rx1, ry1);
        drawHandler(rx2, ry1);
        drawHandler(rx1, ry2);
        drawHandler(rx2, ry2);
    }
    if (paintCanvas.currentRectanglePerimeter && paintCanvas.mode === "rectPerimeter") {
        var px1 = paintCanvas.currentRectanglePerimeter.x1, py1 = paintCanvas.currentRectanglePerimeter.y1, px2 = paintCanvas.currentRectanglePerimeter.x2, py2 = paintCanvas.currentRectanglePerimeter.y2;
        drawHandler(px1, py1);
        drawHandler(px2, py1);
        drawHandler(px1, py2);
        drawHandler(px2, py2);
    }
    ctx.restore();
}
