{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [./common.nix ./features/wayland.nix];

  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
  ];
}
