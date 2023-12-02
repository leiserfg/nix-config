{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: rec {
  # home.sessionVariables = {
  #   DSSI_PATH = "$HOME/.dssi:$HOME/.nix-profile/lib/dssi:/run/current-system/sw/lib/dssi:/etc/profiles/per-user/$USER/lib/dssi";
  #   LADSPA_PATH = "$HOME/.ladspa:$HOME/.nix-profile/lib/ladspa:/run/current-system/sw/lib/ladspa:/etc/profiles/per-user/$USER/lib/ladspa";
  #   LV2_PATH = "$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2:/etc/profiles/per-user/$USER/lib/lv2";
  #   LXVST_PATH = "$HOME/.lxvst:$HOME/.nix-profile/lib/lxvst:/run/current-system/sw/lib/lxvst:/etc/profiles/per-user/$USER/lib/lxvst";
  #   VST_PATH = "$HOME/.vst:$HOME/.nix-profile/lib/vst:/run/current-system/sw/lib/vst:/etc/profiles/per-user/$USER/lib/vst";
  # };

  home.packages = with pkgs; [
    # ardour
    # x42-avldrums
    (sunvox.overrideAttrs (finalAttrs: previousAttrs: rec {
      version = "2.1.1c";
      src = fetchurl {
        url = "https://www.warmplace.ru/soft/sunvox/sunvox-${version}.zip";
        sha256 = "sha256-LfBQ/f2X75bcqLp39c2tdaSlDm+E73GUvB68XFqiicw=";
      };
    }))
    orca-c
  ];
}
