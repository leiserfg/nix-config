.pragma library

// Base Tool class
class Tool {
    constructor() {
        this.name = "";
        this.defaultArgs = {};
        this.visibleAttributes = [];
    }

    draw(ctx, item) {
        // Override in subclasses
    }

    createItem(x, y, args = {}) {
        // Override in subclasses
        return null;
    }

    updateItem(item, x, y) {
        // Override in subclasses
    }

    getHandlers(item) {
        // Override in subclasses - return array of handler objects with x, y, name
        return [];
    }

    updateHandler(item, handlerName, x, y) {
        // Override in subclasses
    }

    isNearHandler(item, x, y) {
        // Returns handler name if near one, null otherwise
        const handlers = this.getHandlers(item);
        for (let i = 0; i < handlers.length; i++) {
            const handler = handlers[i];
            if (Math.abs(x - handler.x) < 10 && Math.abs(y - handler.y) < 10) {
                return handler.name;
            }
        }
        return null;
    }

    drawHandlers(ctx, item) {
        const handlers = this.getHandlers(item);
        for (let i = 0; i < handlers.length; i++) {
            const handler = handlers[i];
            drawHandler(ctx, handler.x, handler.y);
        }
    }

    // New methods for undo and commit
    undo(state) {
        // Override in subclasses
    }

    commit(state, item) {
        // Override in subclasses
    }

    drawAll(ctx, state) {
        // Override in subclasses
    }
}

// Arrow Tool
class ArrowTool extends Tool {
    constructor() {
        super();
        this.name = "arrow";
        this.defaultArgs = {
            lineColor: "black"
        };
        this.visibleAttributes = ["lineColor"];
    }

    draw(ctx, item) {
        drawArrow(ctx, item.x1, item.y1, item.x2, item.y2, item.lineColor || this.defaultArgs.lineColor);
    }

    createItem(x, y, args = {}) {
        return {
            x1: x,
            y1: y,
            x2: x,
            y2: y,
            lineColor: args.lineColor || this.defaultArgs.lineColor
        };
    }

    updateItem(item, x, y) {
        item.x2 = x;
        item.y2 = y;
    }

    getHandlers(item) {
        return [
            { x: item.x1, y: item.y1, name: "start" },
            { x: item.x2, y: item.y2, name: "end" }
        ];
    }

    updateHandler(item, handlerName, x, y) {
        if (handlerName === "start") {
            item.x1 = x;
            item.y1 = y;
        } else if (handlerName === "end") {
            item.x2 = x;
            item.y2 = y;
        }
    }

    undo(state) {
        state.arrows.pop();
    }

    commit(state, item) {
        state.arrows.push(item);
    }

    drawAll(ctx, state) {
        for (let i = 0; i < state.arrows.length; ++i) {
            this.draw(ctx, state.arrows[i]);
        }
    }
}

// Rectangle Tool
class RectangleTool extends Tool {
    constructor() {
        super();
        this.name = "rect";
        this.defaultArgs = {
            fillColor: "rgba(0,0,255,0.2)",
            borderColor: "blue"
        };
        this.visibleAttributes = ["fillColor", "borderColor"];
    }

    draw(ctx, item) {
        drawRectangle(ctx, item.x1, item.y1, item.x2, item.y2, 
                     item.fillColor || this.defaultArgs.fillColor, 
                     item.borderColor || this.defaultArgs.borderColor);
    }

    createItem(x, y, args = {}) {
        return {
            x1: x,
            y1: y,
            x2: x,
            y2: y,
            fillColor: args.fillColor || this.defaultArgs.fillColor,
            borderColor: args.borderColor || this.defaultArgs.borderColor
        };
    }

    updateItem(item, x, y) {
        item.x2 = x;
        item.y2 = y;
    }

    getHandlers(item) {
        return [
            { x: item.x1, y: item.y1, name: "tl" },
            { x: item.x2, y: item.y1, name: "tr" },
            { x: item.x1, y: item.y2, name: "bl" },
            { x: item.x2, y: item.y2, name: "br" }
        ];
    }

    updateHandler(item, handlerName, x, y) {
        switch (handlerName) {
            case "tl":
                item.x1 = x;
                item.y1 = y;
                break;
            case "tr":
                item.x2 = x;
                item.y1 = y;
                break;
            case "bl":
                item.x1 = x;
                item.y2 = y;
                break;
            case "br":
                item.x2 = x;
                item.y2 = y;
                break;
        }
    }

    undo(state) {
        state.rectangles.pop();
    }

    commit(state, item) {
        state.rectangles.push(item);
    }

    drawAll(ctx, state) {
        for (let i = 0; i < state.rectangles.length; ++i) {
            this.draw(ctx, state.rectangles[i]);
        }
    }
}

// Tool Registry
const tools = {
    "arrow": new ArrowTool(),
    "rect": new RectangleTool()
};

function getTool(name) {
    return tools[name];
}

// Drawing functions
function drawRectangle(ctx, x1, y1, x2, y2, fillColor, borderColor) {
    ctx.save();
    ctx.strokeStyle = borderColor;
    ctx.lineWidth = 2;
    const rx = Math.min(x1, x2);
    const ry = Math.min(y1, y2);
    const rw = Math.abs(x2 - x1);
    const rh = Math.abs(y2 - y1);
    if (fillColor && fillColor !== "transparent") {
        ctx.fillStyle = fillColor;
        ctx.fillRect(rx, ry, rw, rh);
    }
    ctx.strokeRect(rx, ry, rw, rh);
    ctx.restore();
}

function drawArrow(ctx, x1, y1, x2, y2, lineColor) {
    ctx.save();
    ctx.strokeStyle = lineColor;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();

    // Arrowhead
    const angle = Math.atan2(y2 - y1, x2 - x1);
    const headlen = 15;
    const arrowAngle = Math.PI / 7;
    const x3 = x2 - headlen * Math.cos(angle - arrowAngle);
    const y3 = y2 - headlen * Math.sin(angle - arrowAngle);
    const x4 = x2 - headlen * Math.cos(angle + arrowAngle);
    const y4 = y2 - headlen * Math.sin(angle + arrowAngle);

    ctx.beginPath();
    ctx.moveTo(x2, y2);
    ctx.lineTo(x3, y3);
    ctx.moveTo(x2, y2);
    ctx.lineTo(x4, y4);
    ctx.stroke();
    ctx.restore();
}

function drawHandler(ctx, x, y) {
    ctx.beginPath();
    ctx.arc(x, y, 3, 0, 2 * Math.PI);
    ctx.fill();
    ctx.stroke();
}

// Main functions
function undo(paintCanvas) {
    const state = paintCanvas.paintState;
    if (state.contextStack.length === 0)
        return;
    const last = state.contextStack.pop();
    const tool = getTool(last.type);
    if (tool) {
        tool.undo(state);
    }
    paintCanvas.requestPaint();
}

function commitCurrentItem(paintCanvas) {
    const state = paintCanvas.paintState;
    if (state.currentItem && state.currentTool) {
        state.currentTool.commit(state, state.currentItem);
        state.contextStack.push({
            type: state.currentTool.name
        });
        state.currentItem = null;
    }
    paintCanvas.requestPaint();
}

function onPressed(paintCanvas, mouse) {
    const state = paintCanvas.paintState;
    const tool = getTool(state.mode);
    if (!tool) return;

    state.currentTool = tool;

    // Handle left-click for handlers and drawing
    if (mouse.button === Qt.LeftButton) {
        // Handler drag logic
        if (state.currentItem) {
            const handlerName = tool.isNearHandler(state.currentItem, mouse.x, mouse.y);
            if (handlerName) {
                state.handlerDrag = handlerName;
                paintCanvas.requestPaint();
                return;
            }
        }

        // Start new item only if no current item exists
        if (!state.currentItem) {
            state.currentItem = tool.createItem(mouse.x, mouse.y, state.toolArgs);
            paintCanvas.requestPaint();
        }
    } 
    // Handle right-click for committing
    else if (mouse.button === Qt.RightButton) {
        if (state.currentItem) {
            commitCurrentItem(paintCanvas);
        }
    }
}

function onPositionChanged(paintCanvas, mouse) {
    const state = paintCanvas.paintState;
    if (!state.currentTool || !state.currentItem) return;

    if (state.handlerDrag) {
        state.currentTool.updateHandler(state.currentItem, state.handlerDrag, mouse.x, mouse.y);
    } else {
        state.currentTool.updateItem(state.currentItem, mouse.x, mouse.y);
    }
    paintCanvas.requestPaint();
}

function onReleased(paintCanvas) {
    const state = paintCanvas.paintState;
    state.handlerDrag = null;
    paintCanvas.requestPaint();
}

function paintCanvas(paintCanvas) {
    const ctx = paintCanvas.getContext("2d");
    ctx.clearRect(0, 0, paintCanvas.width, paintCanvas.height);

    const state = paintCanvas.paintState;

    // Draw all items using tool-specific drawAll methods
    for (const toolName in tools) {
        tools[toolName].drawAll(ctx, state);
    }

    // Draw current item if any
    if (state.currentItem && state.currentTool) {
        state.currentTool.draw(ctx, state.currentItem);

        // Draw handlers
        ctx.save();
        ctx.lineWidth = 1;
        ctx.fillStyle = "white";
        ctx.strokeStyle = "black";
        state.currentTool.drawHandlers(ctx, state.currentItem);
        ctx.restore();
    }
}
