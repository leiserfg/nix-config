let carapace_completer = {|spans: list<string>|

   let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

$env.config = {
 show_banner: false,
 buffer_editor : $env.EDITOR
 completions: {
   case_sensitive: false # case-sensitive completions
   quick: true    # set to false to prevent auto-selecting completions
   partial: true    # set to false to prevent partial filling of the prompt
   algorithm: "fuzzy"
   external: {
   # set to false to prevent nushell looking into $env.PATH to find more suggestions
   enable: true
   # set to lower can improve completion performance at the cost of omitting some options
    max_results: 100
    completer: $carapace_completer # check 'carapace_completer'
  }
 }
}

def to_print0 [] {
    $in | str join (char -i 0)
}

def from_print0 [] {
     $in | bytes split (char -i 0) | each { decode }
}

def __parse_cmd [] {
  let text = $in
}

$env.config.keybindings ++=  [
# History
{
  name: history_menu
  modifier: control
  keycode: char_r
  mode: [emacs, vi_insert, vi_normal]
  event: [
    {
      send: executehostcommand
      cmd: "
commandline edit --replace (
        history
          | where exit_status == 0
          | get command
          | reverse
          | uniq
          | str join (char -i 0)
          | fzf --scheme=history --read0 --tiebreak=chunk --layout=reverse --height=70% -q (commandline)'
          | decode utf-8
          | str trim
      )
      "
    }
  ]
}
    # maybe this one is not needed because of <tab> completion
{
    name: fzf_files
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "

          let token_end = commandline get-cursor;
          let text = commandline;
          let ending = $text | str substring ($token_end + 1 )..-1;
          let text = $text | str substring 0..$token_end;

          let res = $text | parse --regex '(?s)\\A(?P<prefix>.*[\\s=])(?P<needle>\\S+)$';

          let parts = if ($res | is-empty) {
           [
            ['prefix' 'needle'];
            [$text    '']
           ];
          } else { $res } | first

          let result = fzf --reverse --walker=file,dir,follow,hidden --scheme=path --walker-root=($parts.needle | path expand);
          commandline edit --replace ([$parts.prefix $result]|str join '')
          commandline set-cursor --end
          commandline edit --append $ending
        "
      }
    ]
}

]


