import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// Notify for Kitty, OSC-99 protocol
function sendKittyNotification(title: string, body: string) {
    try {
        const notification = `\x1b]99;i=1:o=invisible;${title}: ${body}\x1b\\`;
        process.stdout.write(notification);
    } catch (error) {
        console.error("[kitty-notify] Failed to send notification:", error);
    }
}

// Notify for non-kitty terminals, OSC-777 protocol
function sendNonKittyNotification(title: string, body: string) {
    process.stdout.write(`\x1b]777;notify;${title};${body}\x07`);
}

// Detect if running inside kitty
function isKitty() {
    return process.env.TERM === "xterm-kitty" || process.env.KITTY_WINDOW_ID !== undefined;
}

function notify(title: string, body: string) {
    if (isKitty()) {
        sendKittyNotification(title, body);
    } else {
        sendNonKittyNotification(title, body);
    }
}

export default function (pi: ExtensionAPI) {
    pi.on("agent_end", async () => {
        notify("Pi", "Ready for input");
    });
}
