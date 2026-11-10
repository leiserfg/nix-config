{
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    # ./features/mesa.nix
    ./features/hyprland.nix
    # ./features/daw.nix
  ];
  home.packages = with pkgs; [
    bruno
    libreoffice-qt6
    terraform
    # traceroute
    # chromium
    # slack
  ];

}
