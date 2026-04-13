{
  config,
  pkgs,
  lib,
  inputs,
  myPkgs,
  ...
}:
let
  extensionsDir = ./pi-extensions;
  extensionFiles = builtins.readDir extensionsDir;

  # Reference to the pi package
  piPackage = myPkgs.pi;

  # Directory containing builtin extensions
  builtinExtensionsDir = "${piPackage}/lib/node_modules/@mariozechner/pi-coding-agent/examples/extensions";

  # List of builtin extension names to include (empty by default, add as needed)
  builtinExtensionNames = [
    "custom-provider-qwen-cli"
    "interactive-shell.ts"
    "qna.ts"
    "subagent"
    "ssh.ts"
  ];

  # Create home.file entries for each local extension
  extensionEntries = lib.mapAttrs' (
    name: type:
    lib.nameValuePair ".pi/agent/extensions/${name}" {
      source = extensionsDir + "/${name}";
    }
  ) (lib.filterAttrs (name: type: type == "regular") extensionFiles);

  # Create home.file entries for builtin extensions
  builtinExtensionEntries = lib.listToAttrs (
    map (extName: {
      name = ".pi/agent/extensions/${extName}";
      value = {
        source = "${builtinExtensionsDir}/${extName}";
        recursive = true;
      };
    }) builtinExtensionNames
  );

  # Get all md files from agents directory of subagent extension
  subagentAgentsDir = "${builtinExtensionsDir}/subagent/agents";
  subagentAgentsFiles = lib.pipe subagentAgentsDir [
    builtins.readDir
    (dir: lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) dir)
    lib.attrNames
  ];

  # Create home.file entries for agents (symlinks)
  agentEntries = lib.listToAttrs (
    map (file: {
      name = ".pi/agent/agents/${file}";
      value = {
        source = "${subagentAgentsDir}/${file}";
      };
    }) subagentAgentsFiles
  );

  # Get all md files from prompts directory of subagent extension
  subagentPromptsDir = "${builtinExtensionsDir}/subagent/prompts";
  subagentPromptsFiles = lib.pipe subagentPromptsDir [
    builtins.readDir
    (dir: lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) dir)
    lib.attrNames
  ];

  # Create home.file entries for prompts (symlinks)
  promptEntries = lib.listToAttrs (
    map (file: {
      name = ".pi/agent/prompts/${file}";
      value = {
        source = "${subagentPromptsDir}/${file}";
      };
    }) subagentPromptsFiles
  );

  # Combine all extension entries
  allExtensionEntries = lib.mkMerge [
    extensionEntries
    builtinExtensionEntries
    agentEntries
    promptEntries
  ];

in
{
  home.packages = [ piPackage ];

  home.file = allExtensionEntries;

  skills.raw_paths = [
    ./raw_skills
  ];
  skills.entries = {
    brave-search = {
      resources.brave-search = lib.getExe (import ./skills/brave-search { inherit pkgs; });
      description = "Brave web search (with content extraction)";
      instructions = aliases: ''
        # Brave Search

        ## Search
        To search: `${aliases.brave-search} search "your query" [-n 5] [--content] [--country <code>] [--freshness <period>]`

        ## Extract Content
        To extract content: `${aliases.brave-search} content <url>`
      '';
    };

    playwright-skill = {
      resources.playwright-node = lib.getExe (
        pkgs.writeShellScriptBin "playwright-node" ''
          export NODE_PATH="${pkgs.playwright-test}/lib/node_modules"
          export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
          exec ${pkgs.nodejs}/bin/node "$@"
        ''
      );
      description = "Complete browser automation with Playwright. Test pages, fill forms, take screenshots, check responsive design, validate UX, test login flows, check links, automate any browser task. Use when user wants to test websites, automate browser interactions, validate web functionality, or perform any browser-based testing.";
      instructions = aliases: ''
        # Playwright Skill
        This skill makes sure you get access to a nodejs with playwright working (included browsers pre-installed) to use it you run node scripts that require playwright as:

        To use it just call `${aliases.playwright-node}` the same way you'll call node, it's just a wrapper with playwright and browsers pre-installed

        Do not call `playwright` from your system or any global node_modules: this skill provides a fully Nix-managed, agent-compatible environment.

        ## Notes
        - Scripts should be written to /tmp, not the skill directory.
        - Use `headless: false` unless headless mode explicitly requested.
      '';
    };
  };
}
