#!/usr/bin/env node

import { Readability } from "@mozilla/readability";
import { JSDOM } from "jsdom";
import TurndownService from "turndown";
import { gfm } from "turndown-plugin-gfm";

const [,, subcommand, ...args] = process.argv;

function printMainHelp() {
  console.log(`Usage: script.js <subcommand> [...args]

Subcommands:
  search <query> [options]    Search Brave API, see below for details.
  content <url>               Extract readable content as markdown from a web page.

Run 'script.js search --help' or 'script.js content --help' for more info.
`);
}

async function contentMain(contentArgs) {
  const url = contentArgs[0];
  if (!url || contentArgs.includes('--help') || contentArgs.includes('-h')) {
    console.log(`Usage: script.js content <url>

Extracts readable content from a webpage as markdown.\n`);
    console.log('Example:');
    console.log('  script.js content https://example.com/article\n');
    process.exit(url ? 0 : 1);
  }
  // content.js logic
  function htmlToMarkdown(html) {
    const turndown = new TurndownService({ headingStyle: "atx", codeBlockStyle: "fenced" });
    turndown.use(gfm);
    turndown.addRule("removeEmptyLinks", {
      filter: (node) => node.nodeName === "A" && !node.textContent?.trim(),
      replacement: () => "",
    });
    return turndown
      .turndown(html)
      .replace(/\[\\?\[\s*\\?\]\]\([^)]*\)/g, "")
      .replace(/ +/g, " ")
      .replace(/\s+,/g, ",")
      .replace(/\s+\./g, ".")
      .replace(/\n{3,}/g, "\n\n")
      .trim();
  }
  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
      },
      signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) {
      console.error(`HTTP ${response.status}: ${response.statusText}`);
      process.exit(1);
    }
    const html = await response.text();
    const dom = new JSDOM(html, { url });
    const reader = new Readability(dom.window.document);
    const article = reader.parse();
    if (article && article.content) {
      if (article.title) {
        console.log(`# ${article.title}\n`);
      }
      console.log(htmlToMarkdown(article.content));
      process.exit(0);
    }
    // Fallback
    const fallbackDoc = new JSDOM(html, { url });
    const body = fallbackDoc.window.document;
    body.querySelectorAll("script, style, noscript, nav, header, footer, aside").forEach(el => el.remove());
    const title = body.querySelector("title")?.textContent?.trim();
    const main = body.querySelector("main, article, [role='main'], .content, #content") || body.body;
    if (title) {
      console.log(`# ${title}\n`);
    }
    const text = main?.innerHTML || "";
    if (text.trim().length > 100) {
      console.log(htmlToMarkdown(text));
    } else {
      console.error("Could not extract readable content from this page.");
      process.exit(1);
    }
  } catch (e) {
    console.error(`Error: ${e.message}`);
    process.exit(1);
  }
}

async function searchMain(searchArgs) {
  if (searchArgs.length === 0 || searchArgs.includes('--help') || searchArgs.includes('-h')) {
    console.log(`Usage: script.js search <query> [-n <num>] [--content] [--country <code>] [--freshness <period>]

Options:
  -n <num>              Number of results (default: 5, max: 20)
  --content             Fetch readable content as markdown
  --country <code>      Country code for results (default: US)
  --freshness <period>  Filter by time: pd (day), pw (week), pm (month), py (year)

Environment:
  BRAVE_API_KEY         Required. Your Brave Search API key.

Examples:
  script.js search 'javascript async await'
  script.js search 'climate change' --content
`);
    process.exit(0);
  }
  let numResults = 5;
  const nIndex = searchArgs.indexOf("-n");
  if (nIndex !== -1 && searchArgs[nIndex + 1]) {
    numResults = parseInt(searchArgs[nIndex + 1], 10);
    searchArgs.splice(nIndex, 2);
  }
  let country = "US";
  const countryIndex = searchArgs.indexOf("--country");
  if (countryIndex !== -1 && searchArgs[countryIndex + 1]) {
    country = searchArgs[countryIndex + 1].toUpperCase();
    searchArgs.splice(countryIndex, 2);
  }
  let freshness = null;
  const freshnessIndex = searchArgs.indexOf("--freshness");
  if (freshnessIndex !== -1 && searchArgs[freshnessIndex + 1]) {
    freshness = searchArgs[freshnessIndex + 1];
    searchArgs.splice(freshnessIndex, 2);
  }
  const contentIndex = searchArgs.indexOf("--content");
  const fetchContent = contentIndex !== -1;
  if (fetchContent) searchArgs.splice(contentIndex, 1);
  const query = searchArgs.join(" ");
  if (!query) {
    console.error("No query provided.");
    process.exit(1);
  }
  const apiKey = process.env.BRAVE_API_KEY;
  if (!apiKey) {
    console.error("Error: BRAVE_API_KEY environment variable is required.");
    console.error("Get your API key at: https://api-dashboard.search.brave.com/app/keys");
    process.exit(1);
  }
  async function fetchBraveResults(query, numResults, country, freshness) {
    const params = new URLSearchParams({
      q: query,
      count: Math.min(numResults, 20).toString(),
      country: country,
    });
    if (freshness) {
      params.append("freshness", freshness);
    }
    const url = `https://api.search.brave.com/res/v1/web/search?${params.toString()}`;
    const response = await fetch(url, {
      headers: {
        "Accept": "application/json",
        "Accept-Encoding": "gzip",
        "X-Subscription-Token": apiKey,
      },
    });
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${response.statusText}\n${errorText}`);
    }
    const data = await response.json();
    const results = [];
    if (data.web && data.web.results) {
      for (const result of data.web.results) {
        if (results.length >= numResults) break;
        results.push({
          title: result.title || "",
          link: result.url || "",
          snippet: result.description || "",
          age: result.age || result.page_age || "",
        });
      }
    }
    return results;
  }
  function htmlToMarkdown(html) {
    const turndown = new TurndownService({ headingStyle: "atx", codeBlockStyle: "fenced" });
    turndown.use(gfm);
    turndown.addRule("removeEmptyLinks", {
      filter: (node) => node.nodeName === "A" && !node.textContent?.trim(),
      replacement: () => "",
    });
    return turndown
      .turndown(html)
      .replace(/\[\\?\[\s*\\?\]\]\([^)]*\)/g, "")
      .replace(/ +/g, " ")
      .replace(/\s+,/g, ",")
      .replace(/\s+\./g, ".")
      .replace(/\n{3,}/g, "\n\n")
      .trim();
  }
  async function fetchPageContent(url) {
    try {
      const response = await fetch(url, {
        headers: {
          "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        },
        signal: AbortSignal.timeout(10000),
      });
      if (!response.ok) {
        return `(HTTP ${response.status})`;
      }
      const html = await response.text();
      const dom = new JSDOM(html, { url });
      const reader = new Readability(dom.window.document);
      const article = reader.parse();
      if (article && article.content) {
        return htmlToMarkdown(article.content).substring(0, 5000);
      }
      // Fallback
      const fallbackDoc = new JSDOM(html, { url });
      const body = fallbackDoc.window.document;
      body.querySelectorAll("script, style, noscript, nav, header, footer, aside").forEach(el => el.remove());
      const main = body.querySelector("main, article, [role='main'], .content, #content") || body.body;
      const text = main?.textContent || "";
      if (text.trim().length > 100) {
        return text.trim().substring(0, 5000);
      }
      return "(Could not extract content)";
    } catch (e) {
      return `(Error: ${e.message})`;
    }
  }
  // Main
  try {
    const results = await fetchBraveResults(query, numResults, country, freshness);
    if (results.length === 0) {
      console.error("No results found.");
      process.exit(0);
    }
    if (fetchContent) {
      for (const result of results) {
        result.content = await fetchPageContent(result.link);
      }
    }
    for (let i = 0; i < results.length; i++) {
      const r = results[i];
      console.log(`--- Result ${i + 1} ---`);
      console.log(`Title: ${r.title}`);
      console.log(`Link: ${r.link}`);
      if (r.age) {
        console.log(`Age: ${r.age}`);
      }
      console.log(`Snippet: ${r.snippet}`);
      if (r.content) {
        console.log(`Content:\n${r.content}`);
      }
      console.log("");
    }
  } catch (e) {
    console.error(`Error: ${e.message}`);
    process.exit(1);
  }
}

async function main() {
  if (!subcommand || ["-h", "--help"].includes(subcommand)) {
    printMainHelp();
    process.exit(1);
  }
  if (subcommand === 'content') {
    await contentMain(args);
    return;
  }
  if (subcommand === 'search') {
    await searchMain(args);
    return;
  }
  console.error(`Unknown subcommand: ${subcommand}`);
  printMainHelp();
  process.exit(1);
}

main();
