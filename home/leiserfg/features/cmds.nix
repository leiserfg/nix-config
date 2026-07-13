{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "adb_purge" ''
      adb shell "pm list packages" | sed 's/.*://g'|fzf -m |xargs -n 1 adb shell pm uninstall -k --user 0
    '')
    (writeShellScriptBin "mpvyt" ''
      mpv --no-video --ytdl-format=bestaudio ytdl://ytsearch10:"$@";
    '')

    (writeShellScriptBin "glslViewer_monitor" ''
      glslViewer -audio $(pw-dump | jq '.[] | select(.type == "Port" and .info.direction == "in") | select(.info.name | contains("monitor")) | .id' | head -1) "$@"
    '')

    (writeShellScriptBin "wf_rec_monitor" ''
      wf-recorder --audio=$(pw-dump | jq -r '.[] | select(.type == "Port" and .info.direction == "in") | select(.info.name | contains("monitor")) | .info.name' | head -1)  "$@"
    '')
  ];
}
