{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [./common.nix ./features/mesa.nix ./features/wayland.nix];
  targets.genericLinux.enable = true;

  # services.xcape = {
  #   enable = true;
  #   mapExpression = {Control_L = "Escape";};
  # };

  # home.keyboard.options = ["ctrl:nocaps"];
  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
    terraform
    terraform-ls
    insomnia
    awscli2
    csvkit
    libreoffice
    pandoc

  ];
  # xresources.extraConfig = ''
  #   Xft.dpi:       128
  #   *dpi:          128
  # '';
}
