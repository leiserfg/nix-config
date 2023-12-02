{
  pkgs,
  unstablePkgs,
  ...
}: {
  services.cbatticon = {
    enable = false;
    lowLevelPercent = 50;
    criticalLevelPercent = 30;
  };
}
