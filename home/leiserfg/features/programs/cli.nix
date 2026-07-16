{
  pkgs,
  ...
}:
{
  programs = {
    aria2 = {
      enable = true;
      settings = { };
    };

    fzf = {
      enable = true;
      defaultOptions = [ "--color=light" ];
      defaultCommand = "rg --files --hidden --follow --glob '!.git/*'";
    };
    # skim = {
    #   enable = true;
    # };

    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };

    bat = {
      enable = true;
      # config.theme = "base16";
    };

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    yt-dlp = {
      enable = true;
      settings = {
        cookies-from-browser = "firefox";
        # downloader = "aria2c";
        # downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
      };
    };

    rbw = {
      enable = true;
      settings = {
        # A bit of obfuscation doesn't hurt
        base_url = "https:" + "//bw.nul.mywire.org/";
        email = "leiserfg@gmail.com";
        lock_timeout = 60 * 60 * 8;
        pinentry = pkgs.pinentry-qt;
      };
    };

    bash = {
      enable = true;
      initExtra = ''
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"
      '';
    };

    nushell = {
      enable = true;
      extraConfig = ''$env.SSH_AUTH_SOCK = $env.XDG_RUNTIME_DIR + "/rbw/ssh-agent-socket"'';
    };
  };

}
