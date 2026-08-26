{ lib, ... }: {
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings.LC_TIME = "en_GB.UTF-8"; # European datetime
  };
  time.timeZone = lib.mkDefault "Europe/Berlin";

}
