{unstablePkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = unstablePkgs.kitty;
    theme = "Liquid Carbon Transparent";
    font = {
      name = "Iosevka Term SS07";
      size = 14.0;
    };
    settings = {
      cursor = "none";
      font_features = "Iosevka-Term-SS07 +THND";
      tab_separator = "│";
      enabled_layouts = "tall";
      enable_audio_bell = false;

      editor = "nvim";
      scrollback_pager = ''nvim -c 'setlocal nonumber nolist showtabline=0 foldcolumn=0|Man!' -c "autocmd VimEnter * normal G" -'';
    };
    keybindings = {
      "ctrl+F1" = "launch --allow-remote-control kitty +kitten broadcast";
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
    };
  };
}
