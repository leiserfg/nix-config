/**
 * Llama-cpp Integration Extension
 *
 * Dynamically connects to a local llama-cpp server (default: http://localhost:8000)
 * and registers all available models as pi providers.
 *
 * Features:
 * - Auto-discovers llama-cpp models via /api/tags endpoint
 * - Infers token context and max output limits from model info
 * - Detects image support capabilities
 * - Handles OpenAI-compatible API (openai-completions)
 * - Graceful fallback if server is unavailable
 *
 * Environment Variables:
 * - LLAMA_CPP_BASE_URL: URL of llama-cpp server (default: http://localhost:8000)
 * - LLAMA_CPP_MAX_TIMEOUT: Timeout for requests in ms (default: 5000)
 *
 * Usage:
 *   # Enable with default localhost:8000
 *   pi
 *
 *   # Enable with custom server
 *   LLAMA_CPP_BASE_URL=http://192.168.1.100:8080 pi
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface LlamaCppModel {
	name: string;
	details?: {
		parent_model?: string;
		format?: string;
		family?: string;
		families?: string[];
		parameter_size?: string;
		quantization_level?: string;
	};
	model?: string;
	modified_at?: string;
	size?: number | string;
	digest?: string;
	type?: string;
	capabilities?: string[];
	meta?: {
		vocab_type?: number;
		n_vocab?: number;
		n_ctx_train?: number;
		n_embd?: number;
		n_params?: number;
		size?: number;
	};
}

interface LlamaCppTagsResponse {
	models: LlamaCppModel[];
	object?: string;
	data?: Array<{ id: string; meta?: any }>;
}

interface ModelInfo {
	name: string;
	model: string;
	size?: number;
	format?: string;
	family?: string;
	quantization?: string;
}

interface ModelCapabilities {
	supportsImages: boolean;
	contextWindow: number;
	maxTokens: number;
	estimatedFamily: string;
}

class LlamaCppClient {
	private baseUrl: string;
	private timeout: number;
	private isAvailable = false;
	private lastCheckTime = 0;
	private checkCacheDuration = 60000; // 1 minute cache

	constructor(baseUrl: string = "http://localhost:8000", timeout: number = 5000) {
		this.baseUrl = baseUrl.replace(/\/$/, ""); // Remove trailing slash
		this.timeout = timeout;
	}

	async checkHealth(): Promise<boolean> {
		const now = Date.now();
		if (this.lastCheckTime + this.checkCacheDuration > now) {
			return this.isAvailable;
		}

		try {
			const controller = new AbortController();
			const timeoutId = setTimeout(() => controller.abort(), this.timeout);

			const response = await fetch(`${this.baseUrl}/api/tags`, {
				signal: controller.signal,
				headers: { "Content-Type": "application/json" },
			});

			clearTimeout(timeoutId);
			this.isAvailable = response.ok;
			this.lastCheckTime = now;
			return this.isAvailable;
		} catch {
			this.isAvailable = false;
			this.lastCheckTime = now;
			return false;
		}
	}

	async getModels(): Promise<LlamaCppModel[]> {
		if (!(await this.checkHealth())) {
			return [];
		}

		try {
			const controller = new AbortController();
			const timeoutId = setTimeout(() => controller.abort(), this.timeout);

			const response = await fetch(`${this.baseUrl}/api/tags`, {
				signal: controller.signal,
				headers: { "Content-Type": "application/json" },
			});

			clearTimeout(timeoutId);

			if (!response.ok) {
				return [];
			}

			const data = (await response.json()) as LlamaCppTagsResponse;
			
			// Merge meta from data array into models
			const metaMap = new Map((data.data || []).map(d => [d.id, d.meta]));
			
			return (data.models || []).map(model => ({
				...model,
				meta: metaMap.get(model.name) || model.meta
			}));
		} catch {
			return [];
		}
	}
}

/**
 * Infer token limits based on model name/family
 */
function inferTokenLimits(modelInfo: ModelInfo, meta?: LlamaCppModel["meta"]): {
	contextWindow: number;
	maxTokens: number;
	estimatedFamily: string;
} {
	const name = modelInfo.name.toLowerCase();
	const family = modelInfo.family?.toLowerCase() || "";

	// If meta has context info, use it
	if (meta?.n_ctx_train) {
		return {
			contextWindow: meta.n_ctx_train,
			maxTokens: meta.n_ctx_train,
			estimatedFamily: "META",
		};
	}
	// Common model families and their typical limits
	const familyLimits: Record<string, { context: number; maxOut: number }> = {
		llama3: { context: 8192, maxOut: 2048 },
		"llama3.1": { context: 128000, maxOut: 8192 },
		"llama3.2": { context: 128000, maxOut: 8192 },
		"llama3.3": { context: 128000, maxOut: 8192 },
		"llama2": { context: 4096, maxOut: 2048 },
		mistral: { context: 32768, maxOut: 8192 },
		mixtral: { context: 32768, maxOut: 8192 },
		neural: { context: 4096, maxOut: 2048 },
		phi: { context: 4096, maxOut: 2048 },
		gemma: { context: 8192, maxOut: 4096 },
		"gemma2": { context: 8192, maxOut: 4096 },
		qwen: { context: 32768, maxOut: 8192 },
		"qwen2": { context: 128000, maxOut: 8192 },
		deepseek: { context: 4096, maxOut: 2048 },
		openchat: { context: 8192, maxOut: 2048 },
		zephyr: { context: 4096, maxOut: 2048 },
		solar: { context: 4096, maxOut: 2048 },
		starling: { context: 4096, maxOut: 2048 },
		dolphin: { context: 4096, maxOut: 2048 },
	};

	// Try to match family first
	for (const [familyKey, limits] of Object.entries(familyLimits)) {
		if (family.includes(familyKey)) {
			return {
				contextWindow: limits.context,
				maxTokens: limits.maxOut,
				estimatedFamily: familyKey.toUpperCase(),
			};
		}
	}

	// Try to match in name
	for (const [familyKey, limits] of Object.entries(familyLimits)) {
		if (name.includes(familyKey)) {
			return {
				contextWindow: limits.context,
				maxTokens: limits.maxOut,
				estimatedFamily: familyKey.toUpperCase(),
			};
		}
	}

	// Extract size from name if available (8b, 13b, 70b, etc.)
	const sizeMatch = name.match(/(\d+)[bm]?(?:[-_]|$)/);
	if (sizeMatch) {
		const size = parseInt(sizeMatch[1], 10);
		if (size <= 8) {
			return { contextWindow: 4096, maxTokens: 1024, estimatedFamily: "SMALL" };
		} else if (size <= 20) {
			return { contextWindow: 8192, maxTokens: 2048, estimatedFamily: "MEDIUM" };
		} else if (size <= 40) {
			return { contextWindow: 8192, maxTokens: 2048, estimatedFamily: "LARGE" };
		} else {
			return { contextWindow: 32768, maxTokens: 8192, estimatedFamily: "XLARGE" };
		}
	}

	// Default fallback
	return { contextWindow: 4096, maxTokens: 1024, estimatedFamily: "UNKNOWN" };
}

/**
 * Detect if model supports image input based on API capabilities
 */
function detectImageSupport(modelInfo: ModelInfo, capabilities?: string[]): boolean {
	// Use API capabilities if available
	if (capabilities && Array.isArray(capabilities)) {
		return capabilities.includes("multimodal");
	}
	
	// Fallback to name-based detection if no capabilities provided
	const name = modelInfo.name.toLowerCase();
	const visionModels = [
		"llava",
		"moondream",
		"bakllava",
		"minicpm",
		"deepseek-vl",
		"qwen-vl",
		"clip",
		"siglip",
	];

	for (const visionModel of visionModels) {
		if (name.includes(visionModel)) {
			return true;
		}
	}

	// Check format hints (e.g., gguf often has model-specific metadata)
	if (modelInfo.format) {
		const format = modelInfo.format.toLowerCase();
		// These formats are commonly used for vision models
		if (format.includes("vision") || format.includes("vl")) {
			return true;
		}
	}

	return false;
}

function sanitizeModelName(name: string): string {
	// Remove special characters and normalize for model IDs
	return name.toLowerCase().replace(/[^a-z0-9._-]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "");
}

function parseModelSize(sizeBytes: number | string | undefined): string {
	if (!sizeBytes) return "unknown";
	const bytes = typeof sizeBytes === "string" ? parseInt(sizeBytes, 10) : sizeBytes;
	if (isNaN(bytes) || bytes === 0) return "unknown";
	const gb = bytes / (1024 * 1024 * 1024);
	if (gb >= 1) {
		return `${gb.toFixed(1)}GB`;
	}
	const mb = bytes / (1024 * 1024);
	return `${mb.toFixed(0)}MB`;
}

export default function (pi: ExtensionAPI) {
	const baseUrl = process.env.LLAMA_CPP_BASE_URL || "http://127.0.0.1:8080";
	const timeout = parseInt(process.env.LLAMA_CPP_MAX_TIMEOUT || "5000", 10);
	const client = new LlamaCppClient(baseUrl, timeout);

	let modelsRegistered = false;
	let lastModelCount = 0;

	async function discoverAndRegisterModels() {
		const response = await client.getModels();

		if (response.length === 0) {
			return;
		}

		// Check if models changed
		if (modelsRegistered && response.length === lastModelCount) {
			return; // No changes, skip re-registration
		}

		lastModelCount = response.length;

		// Register provider if we have models
		const providerModels = response.map((model) => {
			// Use meta.size if size field is empty/missing
			const modelSize = model.size || model.meta?.size || undefined;
			
			const modelInfo: ModelInfo = {
				name: model.name,
				model: model.name,
				size: typeof modelSize === "string" ? parseInt(modelSize, 10) : modelSize,
				format: model.details?.format,
				family: model.details?.family,
				quantization: model.details?.quantization_level,
			};
			const tokenLimits = inferTokenLimits(modelInfo, model.meta);
			const supportsImages = detectImageSupport(modelInfo, model.capabilities);

			// Create display name with useful info
			const sizeStr = parseModelSize(model.size);
			const quantStr = modelInfo.quantization ? ` (${modelInfo.quantization})` : "";
			const imageStr = supportsImages ? " [images]" : "";
			const displayName = `${model.name}${quantStr}${imageStr} - ${sizeStr}`;

			return {
				id: sanitizeModelName(model.name),
				name: displayName,
				reasoning: false, // Most local models don't support reasoning
				input: supportsImages
					? (["text", "image"] as const)
					: (["text"] as const),
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, // Local = no cost
				contextWindow: tokenLimits.contextWindow,
				maxTokens: tokenLimits.maxTokens,
				// Add compatibility settings for OpenAI-compatible endpoint
				compat: {
					supportsDeveloperRole: false, // llama.cpp uses system role
					supportsReasoningEffort: false,
					supportsUsageInStreaming: true,
					maxTokensField: "max_tokens",
				},
			};
		});

		pi.registerProvider("llama-cpp", {
			baseUrl: baseUrl,
			apiKey: "dummy", // llama.cpp doesn't require auth
			api: "openai-completions",
			models: providerModels,
		});

		modelsRegistered = true;
		// Silently registered models
	}

	// Initial discovery on session start
	pi.on("session_start", async (event, ctx) => {
		// Defer discovery to avoid blocking session start
		setImmediate(async () => {
			try {
				await discoverAndRegisterModels();
			} catch (error) {
				// Silently skip on startup errors
			}
		});
	});

	// Register command to manually refresh models

	// Register command to reload models into pi
	pi.registerCommand("llama-cpp-reload", {
		description: "Reload and register llama-cpp models (for runtime model additions)",
		handler: async (_args, ctx) => {
			ctx.ui.notify("Reloading models from llama-cpp...", "info");
			lastModelCount = 0; // Reset cache
			modelsRegistered = false;

			try {
				await discoverAndRegisterModels();
				if (modelsRegistered) {
					ctx.ui.notify(`✓ Reloaded ${lastModelCount} models from ${baseUrl}`, "success");
				} else {
					ctx.ui.notify("⚠️  No models found. Check server status with /llama-cpp-status", "warning");
				}
			} catch (error) {
				ctx.ui.notify(
					`❌ Error reloading models: ${error instanceof Error ? error.message : String(error)}`,
					"error",
				);
			}
		},
	});

	// Register command to check server status
	pi.registerCommand("llama-cpp-status", {
		description: "Check llama-cpp server status",
		handler: async (_args, ctx) => {
			const isHealthy = await client.checkHealth();

			if (isHealthy) {
				const models = await client.getModels();
				const status = `✓ llama-cpp server is running at ${baseUrl}\n\nModels: ${models.length}`;
				if (models.length > 0) {
					const modelList = models
						.slice(0, 10)
						.map((m) => `  • ${m.name}${m.size ? ` (${parseModelSize(m.size)})` : ""}`)
						.join("\n");
					ctx.ui.notify(
						`${status}\n\n${modelList}${models.length > 10 ? `\n  ... and ${models.length - 10} more` : ""}`,
						"info",
					);
				} else {
					ctx.ui.notify(status, "info");
				}
			} else {
				ctx.ui.notify(
					`❌ Cannot reach llama-cpp server at ${baseUrl}\n\nMake sure it's running:\n  ollama serve (if using ollama)\n  or your llama.cpp server with --server flag`,
					"error",
				);
			}
		},
	});
}
