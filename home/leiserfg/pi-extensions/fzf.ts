import { spawnSync } from "node:child_process";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("ctrl+f", {
    description: "Fuzzy-find files via rg+fzf (multi), preview with bat, append selection to prompt",
    handler: async (ctx) => {
      if (!ctx.hasUI) return;

      const result = await ctx.ui.custom<string | null>((tui, _theme, _kb, done) => {
        tui.stop();
        process.stdout.write("\x1b[2J\x1b[H");

        // Run rg -> fzf -m with bat preview
        const fzfCmd = [
          "rg --files --hidden --glob '!.git' | " +
          "fzf -m --preview 'bat --color=always --style=numbers --line-range=:100 {}' --preview-window=right:60%"
        ];
        // Use sh -c so shell pipes/arguments work
        const r = spawnSync(process.env.SHELL || "/bin/sh", ["-c", fzfCmd.join(" ")], { encoding: "utf-8" });

        tui.start();
        tui.requestRender(true);
        const selected = r.stdout?.trim();
        done(selected || null);

        return { render: () => [], invalidate: () => {} };
      });

      // Append only if something was selected
      if (result) {
        // fzf -m returns chosen lines separated by newline, join as space-separated list
        const selection = result.split("\n").filter(Boolean).join(" ");
        const current = ctx.ui.getEditorText() || "";
        ctx.ui.setEditorText(current + (current && selection ? " " : "") + selection);
      }
    },
  });
}
