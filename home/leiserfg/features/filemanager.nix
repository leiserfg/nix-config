{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.pcmanfm-qt ];
  home.file.".local/share/file-manager/actions/send-to-telegram.desktop".text = ''
    [Desktop Entry]
    Type=Action
    Profiles=profile_id
    Name=Send to telegram
    Icon=telegram

    [X-Action-Profile profile_id]
    MimeTypes=all/all;
    Exec=Telegram -sendpath %F
  '';
}
