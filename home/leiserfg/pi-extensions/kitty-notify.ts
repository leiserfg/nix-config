/**
 * Kitty Notification Extension
 * 
 * Sends a desktop notification via Kitty's OSC-99 protocol
 * every time Pi finishes processing a user command (only shows if kitty is not visible)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  /**
   * Send a notification by writing directly to stdout
   */
  const sendKittyNotification = (title: string, body: string) => {
    try {
      // Write OSC-99 notification directly to stdout
      // o=invisible: only show notification if window is not visible
      const notification = `\x1b]99;i=1:o=invisible;${title}: ${body}\x1b\\`;
      process.stdout.write(notification);
    } catch (error) {
      console.error("[kitty-notify] Failed to send notification:", error);
    }
  };

  // Listen for when the agent finishes processing
  pi.on("agent_end", async (event, ctx) => {
    // Count tool calls in this turn
    const toolCount = event.messages.filter(
      (msg) => msg.role === "toolResult"
    ).length;

    // Get the session file name for context
    const sessionFile = ctx.sessionManager.getSessionFile();
    const sessionName = sessionFile 
      ? sessionFile.split('/').pop()?.replace('.pi.jsonl', '') 
      : 'ephemeral';

    // Send notification
    if (toolCount > 0) {
      sendKittyNotification(
        "Pi Task Complete",
        `Executed ${toolCount} tool${toolCount === 1 ? '' : 's'} in ${sessionName}`
      );
    } else {
      sendKittyNotification(
        "Pi Response Ready",
        `Response ready in ${sessionName}`
      );
    }
  });
}
