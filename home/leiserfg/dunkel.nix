{pkgs, ...}: {
  imports = [./common.nix ./features/intel_gl.nix];
  targets.genericLinux.enable = true;
  services.xcape = {
    enable = true;
    mapExpression = {Control_L = "Escape";};
  };
  home.keyboard.options = ["ctrl:nocaps"];
  home.packages = with pkgs; [slack pgcli pre-commit poetry terraform iredis bluetuith terraform-ls insomnia];
  xresources.extraConfig = ''
    Xft.dpi:       128
    *dpi:          128
  '';
}
