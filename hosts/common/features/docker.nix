{pkgs, ...}: {
  virtualisation.docker.rootless = {
    enable = false;
    setSocketVariable = true;
  };
}
