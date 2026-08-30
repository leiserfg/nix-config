{ lib, ... }: {
  i18n = {
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings.LC_TIME = "en_DK.UTF-8";
  };
  time.timeZone = lib.mkDefault "Europe/Berlin";
}
