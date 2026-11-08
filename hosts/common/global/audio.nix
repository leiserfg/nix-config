{ ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Use pw-jack if needed
    # jack.enable = true;
  };
  security.rtkit.enable = true;
}
