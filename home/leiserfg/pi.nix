{
  config,
  pkgs,
  lib,
  ...
}:
let
  extensionsDir = ./pi-extensions;
  extensionFiles = builtins.readDir extensionsDir;

  # Create home.file entries for each extension
  extensionEntries = lib.mapAttrs' (
    name: type:
    lib.nameValuePair ".pi/agent/extensions/${name}" {
      source = extensionsDir + "/${name}";
    }
  ) (lib.filterAttrs (name: type: type == "regular") extensionFiles);

in
{
  home.file = extensionEntries;

  skills.entries = {
    brave-search = {
      resources.brave-search = lib.getExe (import ./skills/brave-search { inherit pkgs; });
      description = "Brave web search (with content extraction)";
      instructions = aliases: ''
        # Brave Search

        ## Search
        To search: `${aliases.brave-search} search \"your query\" [-n 5] [--content] [--country <code>] [--freshness <period>]`

        ## Extract Content
        To extract content: `${aliases.brave-search} content <url>`
      '';
    };
  };
}
