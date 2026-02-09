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
    # themeFile = "Solarized_Light";
    # extraConfig = ''
    #   include ${./gv_light.conf}
    # '';
    settings = {

      shell = "nu --login --interactive";

      # bold_font = "Iosevka Term SS15 Medium";
      # italic_font = "Iosevka Term SS15 Light Italic";
      bold_font = "auto";
      italic_font = "auto";
      text_fg_override_threshold = "4.5 ratio";
      # cursor = "none";
      font_features = "Iosevka-Term-SS15-Medium +THND";
      # font_features = "Iosevka-Term-SS15-Light +THND";
      tab_separator = "│";
      enabled_layouts = "tall";
      enable_audio_bell = false;
      # cursor_trail = 3;
      # Have to force it because some symbols are loaded from djavu otherwise
      symbol_map = "U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b7,U+e700-U+e8ef,U+ed00-U+efc1,U+f000-U+f2ff,U+f000-U+f2e0,U+f300-U+f381,U+f400-U+f533,U+f0001-U+f1af0 Symbols Nerd Font Mono";
      scrollback_pager = "nvim --cmd 'set eventignore=FileType' +'nnoremap q ZQ' +'call nvim_open_term(0, {})' +'set nomodified nolist' +'$' -";
      editor = "nvim";

      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.3";
      cursor_trail_start_threshold = 1;

      foreground = "#35243c";
      background = "#fcfdf1";
      cursor = "#35243c";
      color0 = "#fcfdf1";
      color1 = "#ffe6e6";
      color2 = "#e3f4df";
      color3 = "#f7edd6";
      color4 = "#dff0ff";
      color5 = "#fbe7f9";
      color6 = "#d6f6f5";
      color7 = "#35243c";
      color8 = "#dabcb2";
      color9 = "#d5a9a7";
      color10 = "#c7b2a3";
      color11 = "#d5ac9e";
      color12 = "#b9b5b7";
      color13 = "#ceadb3";
      color14 = "#b8b8b1";
      color15 = "#09000f";
    };

    keybindings =
      let
        nvim_scrollback = "nvim --cmd 'set eventignore=FileType' +'nnoremap q ZQ' +'call nvim_open_term(0, {})' +'set nomodified nolist' +'$' - ";

      in
      {
        "ctrl+F1" = "launch --allow-remote-control kitty +kitten broadcast";
        "ctrl+shift+t" = "new_tab_with_cwd";
        "ctrl+shift+enter" = "new_os_window_with_cwd";

        # ''launch   --stdin-source=@screen_scrollback  nvim -c 'setlocal nonumber nolist showtabline=0 foldcolumn=0|Man!' -c "autocmd VimEnter * normal G" -'';

        # "kitty_mod+h" = ''launch --type=overlay  --stdin-source=@screen_scrollback ${nvim_scrollback}''; # --stdin-add-formatting
        #
        # "kitty_mod+g" = ''launch --type=overlay  --stdin-source=@last_cmd_output ${nvim_scrollback}'';

        # background = "#0e1415";
        # foreground = "#cecece";
        # cursor = "#cd974b";
        # selection_background = "#293334";
        # selection_foreground = "#cecece";
        # color0 = "#000000";
        # color1 = "#d2322d";
        # color2 = "#6abf40";
        # color3 = "#cd974b";
        # color4 = "#217EBC";
        # color5 = "#9B3596";
        # color6 = "#178F79";
        # color7 = "#cecece";
        # color8 = "#333333";
        # color9 = "#c33c33";
        # color10 = "#95cb82";
        # color11 = "#dfdf8e";
        # color12 = "#71aed7";
        # color13 = "#cc8bc9";
        # color14 = "#47BEA9";
        # color15 = "#ffffff";

      };
  };
}
