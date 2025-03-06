{...}: {
  systemd.oomd.enable = false;
  services.earlyoom.enable = true;
}
