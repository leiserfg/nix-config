{
  pkgs,
  config,
  lib,
  outputs,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = true; # Allow changing the password via `passwd`
  users.users.leiserfg = {
    isNormalUser = true;
    initialPassword = "password";
    shell = pkgs.bash;
    extraGroups =
      [
        "wheel"
        "video"
        "audio"
        "netorkmanager"
        "adbusers"
      ]
      ++ ifTheyExist [
        "network"
        "wireshark"
        "i2c"
        "mysql"
        "docker"
        "podman"
        "git"
        "libvirtd"
        "deluge"
        "scanner"
        "lp"
      ];
  };
}
