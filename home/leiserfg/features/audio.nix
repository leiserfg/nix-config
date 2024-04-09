{
  pkgs,
  config,
  ...
}: {
  services.easyeffects = {
    enable = true;
    preset = "music";
  };
}
