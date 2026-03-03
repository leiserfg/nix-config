import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { copyToClipboard } from "@mariozechner/pi-coding-agent";
import { Key, matchesKey, Text, truncateToWidth } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("cp", {
		description:
			"Copy last assistant response or one of its markdown code fences to clipboard (interactive). When copying a fence, markers are removed.",
		handler: async (_args, ctx) => {
			const branch = ctx.sessionManager.getBranch();
			let lastAssistantText: string | undefined;

			// find last assistant message
			for (let i = branch.length - 1; i >= 0; i--) {
				const entry = branch[i];
				if (entry.type === "message") {
					const msg = entry.message;
					if ("role" in msg && msg.role === "assistant") {
						if (msg.stopReason && msg.stopReason !== "stop") {
							if (ctx.hasUI) ctx.ui.notify("Last assistant message incomplete", "warning");
							return;
						}
						const textParts = msg.content
							.filter((c: any): c is { type: "text"; text: string } => c.type === "text")
							.map((c: any) => c.text);
						if (textParts.length > 0) {
							lastAssistantText = textParts.join("\n");
							break;
						}
					}
				}
			}

			if (!lastAssistantText) {
				if (ctx.hasUI) ctx.ui.notify("No assistant message found", "error");
				return;
			}

			// regex: capture optional info-string (language) and inner code
			const fenceRe = /```([^\n]*)\n([\s\S]*?)```/g;
			const codeblocks: { info: string; inner: string; raw: string }[] = [];
			let m: RegExpExecArray | null;
			while ((m = fenceRe.exec(lastAssistantText)) !== null) {
				const info = (m[1] ?? "").trim();
				const inner = m[2];
				codeblocks.push({ info, inner, raw: m[0] });
			}

			// If no UI or no fences: copy full text directly
			if (!ctx.hasUI || codeblocks.length === 0) {
				try {
					await copyToClipboard(lastAssistantText);
					if (ctx.hasUI) ctx.ui.notify("Copied full assistant response to clipboard", "success");
				} catch (err: any) {
					if (ctx.hasUI) ctx.ui.notify(`Copy failed: ${err?.message ?? String(err)}`, "error");
				}
				return;
			}

			// Prepare labels and previews
			const items: string[] = [];
			items.push("Full response");
			for (const cb of codeblocks) {
				// small preview: language + first non-empty line
				const firstLine = cb.inner
					.split(/\r?\n/)
					.map((s) => s.trim())
					.filter(Boolean)[0] ?? "(empty)";
				const label = cb.info ? `${cb.info} ${firstLine}` : firstLine;
				items.push(label);
			}

			// Use custom UI to show selectable list + live preview
			const result = await ctx.ui.custom<number | null>((tui, theme, _kb, done) => {
				let index = 0;
				let cachedLines: string[] | undefined;

				function refresh() {
					cachedLines = undefined;
					tui.requestRender();
				}

				function render(width: number): string[] {
					if (cachedLines) return cachedLines;

					const lines: string[] = [];
					const add = (s: string) => lines.push(truncateToWidth(s, width));

					add(theme.fg("accent", "─".repeat(width)));
					add(theme.fg("text", " Choose what to copy (Enter = copy, Esc = cancel):"));
					lines.push("");

					// list
					for (let i = 0; i < items.length; i++) {
						const selected = i === index;
						const prefix = selected ? theme.fg("accent", "> ") : "  ";
						const txt = selected ? theme.fg("accent", items[i]) : theme.fg("text", items[i]);
						add(prefix + txt);
					}

					lines.push("");
					add(theme.fg("muted", "Preview:"));
					lines.push("");

					// preview box - show either full response first N lines or code block inner
					const previewLines: string[] = [];
					if (index === 0) {
						const fullLines = lastAssistantText!.split(/\r?\n/).slice(0, 12);
						for (const l of fullLines) previewLines.push(l);
					} else {
						const cb = codeblocks[index - 1];
						const innerLines = cb.inner.replace(/^\n+|\n+$/g, "").split(/\r?\n/).slice(0, 20);
						// show language header if present
						if (cb.info) previewLines.push(`// ${cb.info}`);
						for (const l of innerLines) previewLines.push(l);
					}

					if (previewLines.length === 0) previewLines.push("(empty)");

					// render preview with muted color, ellipsize lines to width
					for (const pl of previewLines) {
						add(theme.fg("muted", pl));
					}

					lines.push("");
					add(theme.fg("dim", " ↑/↓ navigate • Enter copy • Esc cancel "));
					add(theme.fg("accent", "─".repeat(width)));

					cachedLines = lines;
					return lines;
				}

				function handleInput(data: string) {
					if (matchesKey(data, Key.up)) {
						index = Math.max(0, index - 1);
						refresh();
						return;
					}
					if (matchesKey(data, Key.down)) {
						index = Math.min(items.length - 1, index + 1);
						refresh();
						return;
					}

					// accept number keys
					for (let k = 0; k < items.length; k++) {
						if (data === String(k + 1)) {
							index = k;
							done(k);
							return;
						}
					}

					if (matchesKey(data, Key.enter)) {
						done(index);
						return;
					}

					if (matchesKey(data, Key.escape)) {
						done(null);
						return;
					}
				}

				return { render, handleInput, invalidate: () => (cachedLines = undefined) };
			});

			if (result === null) {
				if (ctx.hasUI) ctx.ui.notify("Cancelled", "info");
				return;
			}

			let toCopy = "";
			if (result === 0) {
				toCopy = lastAssistantText;
			} else {
				const cb = codeblocks[result - 1];
				if (cb) toCopy = cb.inner.replace(/^\n+|\n+$/g, "");
			}

			if (!toCopy) {
				if (ctx.hasUI) ctx.ui.notify("Nothing to copy", "warning");
				return;
			}

			try {
				await copyToClipboard(toCopy);
				if (ctx.hasUI) ctx.ui.notify("Copied to clipboard", "success");
			} catch (err: any) {
				if (ctx.hasUI) ctx.ui.notify(`Copy failed: ${err?.message ?? String(err)}`, "error");
			}
		},
	});
}
