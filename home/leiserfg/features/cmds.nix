{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellScriptBin "adb_purge" ''
      adb shell "pm list packages" | sed 's/.*://g'|fzf |xargs adb shell pm uninstall -k --user 0
    '')
    (writeShellScriptBin "mpvyt" ''
        mpv --no-video --ytdl-format=bestaudio ytdl://ytsearch10:"$@";
    '')
  ];
}
