{ ... }:
{
  services = {
    gpg-agent.enable = true;

    mpris-proxy.enable = true;
    network-manager-applet.enable = true;
    tailscale-systray.enable = true;

    # These are disabled cause we are now using a noctalia plugin
    udiskie = {
      enable = false;
      automount = true;
    };
    blueman-applet.enable = false;
  };
}
