{ ... }:
{
  services = {
    trayscale.enable = true;
    gpg-agent.enable = true;
    udiskie = {
      enable = true;
      automount = true;
    };

    mpris-proxy.enable = true;
    blueman-applet.enable = true;
    network-manager-applet.enable = true;
  };
}