{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}: {
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     RADEON_DPM_PERF_LEVEL_ON_AC = "high";
  #     RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
  #
  #     RADEON_DPM_STATE_ON_AC = "performance";
  #     RADEON_DPM_STATE_ON_BAT = "battery";
  #
  #     RADEON_POWER_PROFILE_ON_AC = "high";
  #     RADEON_POWER_PROFILE_ON_BAT = "low";
  #
  #     PCIE_ASPM_ON_AC = "performance";
  #     PCIE_ASPM_ON_BAT = "powersupersave";
  #   };
  # };
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = {
  #     governor = "powersave";
  #     turbo = "never";
  #   };
  #   charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #   };
  # };
}
