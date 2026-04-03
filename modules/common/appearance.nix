{ pkgs, ... }:
{
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          cursor-theme = "phinger-cursors-dark";
          cursor-size = pkgs.lib.gvariant.mkInt32 24;
        };
      }
    ];
  };
}
