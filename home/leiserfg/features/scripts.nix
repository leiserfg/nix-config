{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # --- Scripts & Custom Binaries ---
    (writeShellScriptBin "xdg-open" ''
      exec -a $0 ${handlr-regex}/bin/handlr open "$@"
    '')
    (writeShellScriptBin "vicinae-pp" ''
      printf " Performance\n Balanced\n Power Saver" \
      | vicinae dmenu \
      | tr -cd '[:print:]' \
      | xargs|tr " " "-" \
      | tr '[:upper:]' '[:lower:]' \
      | xargs powerprofilesctl set
    '')
    (writeShellScriptBin "pp-state" ''
      state=$(powerprofilesctl get | sed -e "s/.*string//" -e "s/.*save.*/ /"  -e "s/.*perf.*/ /"  -e "s/.*balanced.*/ /")
      echo $state
    '')
    (writeShellScriptBin "game-picker" ''
      exec  sh -c "ls ~/Games/*/*start*.sh  --quoting-style=escape \
      |xargs -n 1 -d '\n' dirname \
      |xargs -d '\n' -n 1 basename \
      |vicinae dmenu \
      |xargs  -d '\n'  -I__  bash -c 'cd $HOME/Games/__/  && source *start*.sh'"
    '')
    (writeShellScriptBin "rofi_power" ''
      enumerate () {
      # awk -F"|"  '{ for (i = 1; i <= NF; ++i) print "<big>"$i"</big><sub><small>"i"</small></sub>"; exit } '
       awk -F"|"  '{ for (i = 1; i <= NF; ++i) print i": "  $i; exit } '
      }
      question=$(printf "||||"| enumerate|vicinae dmenu)

      case $question in
          **)
              loginctl lock-session $XDG_SESSION_ID
              ;;
          **)
              systemctl suspend
              ;;
          **)
              # bspc quit || qtile cmd-obj -o cmd -f shutdown
              systemctl --user  stop graphical-session.target
              hyprctl dispatch exit || loginctl terminate-session $XDG_SESSION_ID
              ;;
          **)
              systemctl reboot
              ;;
          **)
              systemctl poweroff
              ;;
          *)
              exit 0  # do nothing on wrong response
              ;;
      esac
    '')
  ];
}
