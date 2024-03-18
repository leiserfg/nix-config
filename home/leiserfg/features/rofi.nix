{config, ...}: {
  programs.rofi = {
    enable = true;
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg0 = mkLiteral "#242424";
        bg1 = mkLiteral "#7E7E7E";
        bg2 = mkLiteral "#afcfee";

        fg0 = mkLiteral "@bg2";
        fg1 = mkLiteral "@bg0";
        fg2 = mkLiteral "#e2e2e2";

        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg0";

        margin = 0;
        padding = 0;
        spacing = 0;
      };

      window = {
        background-color = mkLiteral "@bg0";

        location = "center";
        width = 640;
        border-radius = 8;
      };

      inputbar = {
        padding = mkLiteral "12px";
        spacing = mkLiteral "12px";
        children = [(mkLiteral "icon-search") (mkLiteral "entry")];
      };

      icon-search = {
        expand = false;
        filename = "search";
        size = mkLiteral "1.5em";
      };

      "icon-search, entry, element-icon, element-text" = {
        vertical-align = mkLiteral "0.5";
      };

      entry = {
        font = mkLiteral "inherit";

        # placeholder         = "";
        placeholder-color = mkLiteral "@fg2";
      };

      message = {
        border = mkLiteral "2px 0 0";
        border-color = mkLiteral "@bg1";
        background-color = mkLiteral "@bg1";
      };

      textbox = {
        padding = mkLiteral "8px 24px";
      };

      listview = {
        lines = 10;
        columns = 1;

        fixed-height = false;
        border = mkLiteral "1px 0 0";
        border-color = mkLiteral "@bg1";
      };

      element = {
        padding = mkLiteral "8px 16px";
        spacing = mkLiteral "16px";
        background-color = mkLiteral "transparent";
      };

      "element normal active" = {
        text-color = mkLiteral "@bg2";
      };

      "element selected normal, element selected active" = {
        background-color = mkLiteral "@bg2";
        text-color = mkLiteral "@fg1";
      };

      element-icon = {
        size = mkLiteral "1em";
      };

      element-text = {
        text-color = mkLiteral "inherit";
      };
    };
  };
}
