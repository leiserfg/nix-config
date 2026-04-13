{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };
    shellWrapperName = "y";
    initLua = ''
      require("gvfs"):setup()
    '';

    plugins = {
      inherit (pkgs.yaziPlugins) smart-filter gvfs;
    };

    settings = {
      plugin = {
        prepend_preloaders = [
          {
            url = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }
        ];
        prepend_previewers = [
          # Allow to preview folder.
          {
            url = "*/";
            run = "folder";
          }

          # Do not previewing files in mounted locations (uncomment this line to except text file):
          {
            mime = "{text/*,application/x-subrip}";
            run = "code";
          }

          # Using absolute path.
          {
            url = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }
        ];
      };
    };
    keymap = {
      input.prepend_keymap = [
        {
          run = "close";
          on = [ "<C-q>" ];
        }
        {
          run = "close --submit";
          on = [ "<Enter>" ];
        }
        {
          run = "escape";
          on = [ "<Esc>" ];
        }
        {
          run = "backspace";
          on = [ "<Backspace>" ];
        }
      ];

      mgr.prepend_keymap = [
        {
          on = [ "F" ];
          run = "plugin smart-filter";
          desc = "Smart filter";
        }
        {
          on = [ "<C-n>" ];
          run = ''shell 'dragon -x -i -T "$1"' --confirm'';
        }
        {
          on = "y";
          run = [
            ''shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list''
            "yank"
          ];
        }

        {
          on = [
            "g"
            "r"
          ];
          run = ''shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm'';
        }
        {
          run = "escape";
          on = [ "<Esc>" ];
        }
        {
          run = "quit";
          on = [ "q" ];
        }
        {
          run = "close";
          on = [ "<C-q>" ];
        }
        {
          on = [
            "M"
            "m"
          ];
          run = "plugin gvfs -- select-then-mount";
          desc = "Select device then mount";
        }
        {
          on = [
            "M"
            "u"
          ];
          run = "plugin gvfs -- select-then-unmount --eject";
          desc = "Select device then eject";
        }
        {
          on = [
            "M"
            "a"
          ];
          run = "plugin gvfs -- add-mount";
          desc = "Add a GVFS mount URI";
        }
        {
          on = [
            "g"
            "m"
          ];
          run = "plugin gvfs -- jump-to-device";
          desc = "Select device then jump to its mount point";
        }

        {
          on = [
            "M"
            "e"
          ];
          run = "plugin gvfs -- edit-mount";
          desc = "Edit a GVFS mount URI";
        }

        # Remove a Scheme/Mount URI
        {
          on = [
            "M"
            "r"
          ];
          run = "plugin gvfs -- remove-mount";
          desc = "Remove a GVFS mount URI";
        }
      ];
    };
  };
}
