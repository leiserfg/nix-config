{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellScriptBin "adb_purge" ''
      adb shell "pm list packages" | sed 's/.*://g'|fzf -m |xargs -n 1 adb shell pm uninstall -k --user 0
    '')
    (writeShellScriptBin "mpvyt" ''
      mpv --no-video --ytdl-format=bestaudio ytdl://ytsearch10:"$@";
    '')

    (writeShellScriptBin "glslViewer_monitor" ''
      glslViewer -audio $(pactl --format=json list sources | jq 'to_entries|.[]|select(.value.monitor_source == "'$(pactl get-default-sink)'")|.key' ) "$@"
    '')

    (writeShellScriptBin "wf_rec_monitor" ''
        wf-recorder --audio=$(pactl --format=json list sources | jq 'to_entries|.[]|select(.value.monitor_source == "'$(pactl get-default-sink)'")|.value.name' -r)  "$@"
    '')
  ];
}
