{ lib, ... }:
let
  extensionsDir = ./pi-extensions;
  extensionFiles = builtins.readDir extensionsDir;
  
  # Create home.file entries for each extension
  extensionEntries = lib.mapAttrs' (name: type:
    lib.nameValuePair ".pi/agent/extensions/${name}" {
      source = extensionsDir + "/${name}";
    }
  ) (lib.filterAttrs (name: type: type == "regular") extensionFiles);
in
{
  home.file = extensionEntries;
}
