{pkgs, ...}: let
  shaders_dir = "${pkgs.mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders";
in {
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      uosc
      thumbfast
      mpris
      sponsorblock
    ];
    config = {
      volume-max = 150;
      ontop = "yes";
      sub-auto = "fuzzy";
      slang = "esp,es,eng,en";
      alang = "eng,en,esp,es";

      glsl-shaders-clr = true;

      scale = "ewa_lanczos";
      dscale = "spline36";
      linear-downscaling = "yes";
      cscale = "mitchell";
      sigmoid-upscaling = "yes";

      hwdec = "auto-safe";
      gpu-api = "vulkan";
      hdr-compute-peak = "no";
      vo = "gpu-next";
    };
    profiles = {
      audio-only = {
        profile-cond = "audio_codec and (container_fps == nil or container_fps == 1)";
        lavfi-complex = "'[aid1]asplit[ao][a1];[a1]avectorscope=draw=line:s=1920x1080,format=yuv420p[vo]'";
      };
      # hdr-p10 = {
      #   profile-cond = "p['video-params/pixelformat']:match'p10$'";
      #   vo = "gpu-next";
      # };
      # no-hdr-p10 = {
      #   profile-cond = "video_codec and (not p['video-params/pixelformat']:match'p10$')";
      #   vo = "dmabuf-wayland";
      # };
      # from-720-to-1080 = {
      #   profile-cond = "p['video-params/h'] >= 720 and p['video-params/h'] < 1080";
      #   glsl-shader = "${shaders_dir}/FSR.glsl";
      #   profile-restore = "copy";
      # };
    };
    scriptOpts = {
      uosc = {
        top_bar = "always"; # This makes uosc work fine in wayland
      };
    };

    bindings = {
      "MOUSE_BTN3" = "add volume +2";
      "MOUSE_BTN4" = "add volume -2";

      "MOUSE_BTN5" = "seek -10 ";
      "MOUSE_BTN6" = "seek 10 ";

      "Shift+RIGHT" = "seek 20";
      "Shift+LEFT" = "seek -20";
      "CTRL+1" = "show-text 'Shaders: \${glsl-shaders}'";
      "UP" = "add volume +5";
      "DOWN" = "add volume -5";

      "ENTER" = "cycle fullscreen";

      "M" = "script-binding uosc/menu";
      "mbtn_mid" = "script-binding uosc/menu";

      "f" = "cycle fullscreen                       #! Toggle Fullscreen";
      "alt+s" = "script-binding uosc/load-subtitles     #! Load subtitles";
      "alt+2" = "script-binding uosc/subtitles-2        #! Select secondary subs";
      "S" = "script-binding uosc/subtitles          #! Select subtitles";
      "ctrl+p" = "script-binding find_and_add_entries    #! Load Files into PL";
      "a" = "script-binding appendURL               #! Append url to PL";
      "A" = "script-binding uosc/audio              #! Select audio";

      "ctrl+s" = "async screenshot                       #! Utils > Screenshot";
      "p" = "script-binding uosc/playlist           #! Utils > Playlist";
      "C" = "script-binding uosc/chapters           #! Utils > Chapters";

      "c" = "script-binding auto_crop               #! Utils > Smart Crop";
      "n" = "script-binding denoise                 #! Utils > Cycle Denoise";

      "o" = "script-binding uosc/open-file          #! Open file";
      "O" = "script-binding uosc/show-in-directory  #! Show in directory";

      "esc" = "quit_watch_later #! Quit";
      "q" = "quit_watch_later #!";
    };
  };
}
