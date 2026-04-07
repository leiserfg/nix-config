{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.vicinae = {
    enable = true;
    systemd.enable = true;
    # package = myPkgs.vicinae;
    extensions =
      let
        vicExts =
          pkgs.fetchFromGitHub {
            owner = "vicinaehq";
            repo = "extensions";
            rev = "4d8b08d90fda9bd2693e6682730f31b273cec70c";
            hash = "sha256-CDf+7qwkX9f9d448CxBhKvuyEvObZcHnPbSiSnZvwLs=";
          }
          + "/extensions";

      in
      [
        # (config.lib.vicinae.mkRayCastExtension {
        #   name = "gif-search";
        #   sha256 = "sha256-G7il8T1L+P/2mXWJsb68n4BCbVKcrrtK8GnBNxzt73Q=";
        #   rev = "4d417c2dfd86a5b2bea202d4a7b48d8eb3dbaeb1";
        # })
        # (config.lib.vicinae.mkExtension {
        #   name = "test-extension";
        #   src =
        #     pkgs.fetchFromGitHub {
        #       owner = "schromp";
        #       repo = "vicinae-extensions";
        #       rev = "f8be5c89393a336f773d679d22faf82d59631991";
        #       sha256 = "sha256-zk7WIJ19ITzRFnqGSMtX35SgPGq0Z+M+f7hJRbyQugw=";
        #     }
        #     + "/test-extension";
        # })

        # (config.lib.vicinae.mkExtension {
        #   name = "firefox";
        #   src = vicExts + "/firefox";
        # })
      ];
  };
}
