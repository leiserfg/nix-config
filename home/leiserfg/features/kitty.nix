{ unstablePkgs, ... }:
{

  programs.kitty = {
    enable = true;
    package = unstablePkgs.kitty;
    environment = {
      FZF_DEFAULT_OPTS = "--color=light";
    };
    font = {
      name = "Iosevka Term SS15 Medium";
      # name = "Iosevka Term SS15 Light";
      size = 14.0;
    };
    themeFile = "Solarized_Light";
    # extraConfig = ''
    #   include ${./gv_light.conf}
    # '';
    settings = {
      # bold_font = "Iosevka Term SS15 Medium";
      # italic_font = "Iosevka Term SS15 Light Italic";
      bold_font = "auto";
      italic_font = "auto";
      text_fg_override_threshold = "4.5 ratio";
      cursor = "none";
      font_features = "Iosevka-Term-SS15-Medium +THND";
      # font_features = "Iosevka-Term-SS15-Light +THND";
      tab_separator = "│";
      enabled_layouts = "tall";
      enable_audio_bell = false;
      # cursor_trail = 3;
      # Have to force it because some symbols are loaded from djavu otherwise
      symbol_map = "U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b7,U+e700-U+e8ef,U+ed00-U+efc1,U+f000-U+f2ff,U+f000-U+f2e0,U+f300-U+f381,U+f400-U+f533,U+f0001-U+f1af0 Symbols Nerd Font Mono";

      editor = "nvim";

      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.3";
      cursor_trail_start_threshold = 2;
    };
    keybindings = {
      "ctrl+F1" = "launch --allow-remote-control kitty +kitten broadcast";
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_os_window_with_cwd";

      # ''launch   --stdin-source=@screen_scrollback  nvim -c 'setlocal nonumber nolist showtabline=0 foldcolumn=0|Man!' -c "autocmd VimEnter * normal G" -'';

      "kitty_mod+h" =
        # ''launch --type=overlay --stdin-source=@screen_scrollback nvim -c 'setlocal nonumber nolist showtabline=0 foldcolumn=0|Man!' -c 'autocmd VimEnter * normal let kitty_data = $KITTY_PIPE_DATA | let parts = split(kitty_data, ":") | let scrolled_by = parts[0] | call cursor(line("$") - scrolled_by + 1, 0) | call feedkeys("zb", "n")' - '';

        ''launch --type=overlay --stdin-source=@screen_scrollback nvim -c 'setlocal nonumber nolist showtabline=0 foldcolumn=0|Man!' +@input-line-number  - '';
      "kitty_mod+g" =
        ''launch --type=overlay --stdin-source=@last_cmd_output nvim -c 'setlocal nonumber nolist showtabline=0 foldcolumn=0|Man!' -c 'autocmd VimEnter * normal let kitty_data = $KITTY_PIPE_DATA | let parts = split(kitty_data, ":") | let scrolled_by = parts[0] | call cursor(line("$") - scrolled_by, 0) | call feedkeys("zb", "n")' -'';
    };
  };
}
