{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles = {
      yolo = {
        userContent = "";
        userChrome = ''
          #TabsToolbar {
            visibility: collapse;
          }
          #sidebar-box #sidebar-header {
              display: none !important;
          }
        '';

        settings = {
          # Enable user chrome
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "sidebar.position_start" = false; # Sideberry in the right side
          "widget.wayland.fractional-scale.enabled" = true;
          "browser.compactmode.show" = true;
          "dom.webgpu.enabled" = true;
          "browser.uidensity" = 1;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.ffvpx.enabled" = true;
        };
        search.force = true;
        search.engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }

                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS Wiki" = {
            urls = [ { template = "https://wiki.nixos.org/index.php?search={searchTerms}"; } ];
            icon = "https://wiki.nixos.org/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };

          "bing".metaData.hidden = true;
          "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
        };
      };
    };
  };
}