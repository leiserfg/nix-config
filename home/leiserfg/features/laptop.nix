{
  pkgs,
  unstablePkgs,
  ...
}: {
  services.cbatticon = {
    enable = true;
    lowLevelPercent = 50;
    criticalLevelPercent = 30;
  };
}
