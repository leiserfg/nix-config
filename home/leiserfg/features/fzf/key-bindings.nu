#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.nu
#
# - $FZF_TMUX_OPTS --
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS ---
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Dependencies: `find`, `bat`.

# Code provided by @igor-ramazanov
# Source: https://github.com/junegunn/fzf/issues/4122#issuecomment-2607368316


export-env {
  $env.FZF_TMUX_OPTS       = $env.FZF_TMUX_OPTS?       | default "--height 40%"
  $env.FZF_CTRL_T_COMMAND  = $env.FZF_CTRL_T_COMMAND?  | default "^find . -type f"
  $env.FZF_CTRL_T_OPTS     = $env.FZF_CTRL_T_OPTS?     | default "--preview 'bat --color=always --style=full --line-range=:500 {}' "
  $env.FZF_CTRL_R_OPTS     = $env.FZF_CTRL_R_OPTS?     | default ""
  $env.FZF_ALT_C_COMMAND   = $env.FZF_ALT_C_COMMAND?   | default "^find . -type d"
  $env.FZF_ALT_C_OPTS      = $env.FZF_ALT_C_OPTS?      | default "--preview 'ls --color=always {}'"
  $env.FZF_DEFAULT_COMMAND = $env.FZF_DEFAULT_COMMAND? | default "^find . -type f"
}

# Directories
const alt_c = {
    name: fzf_dirs
    modifier: alt
    keycode: char_c
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let fzf_command = \$\"($env.FZF_ALT_C_COMMAND) | fzf ($env.FZF_ALT_C_OPTS)\";
          let result = nu -c $fzf_command;
          cd $result;
        "
      }
    ]
}

# History
const ctrl_r = {
  name: history_menu
  modifier: control
  keycode: char_r
  mode: [emacs, vi_insert, vi_normal]
  event: [
    {
      send: executehostcommand
      cmd: "commandline edit --insert (
      history | select command | reverse | uniq | get command | str join (char -i 0)|fzf --scheme history --read0 --query "(commandline)" |decode utf-8|str trim
      )"
    }
  ]
}

# Files
const ctrl_t =  {
    name: fzf_files
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let fzf_command = \$\"($env.FZF_CTRL_T_COMMAND) | fzf ($env.FZF_CTRL_T_OPTS)\";
          let result = nu -l -i -c $fzf_command;
          commandline edit --append $result;
          commandline set-cursor --end
        "
      }
    ]
}

$env.config.keybindings = $env.config.keybindings | append [
    $alt_c
    $ctrl_r
    $ctrl_t
]


