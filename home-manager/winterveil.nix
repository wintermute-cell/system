{ pkgs, config, lib, ... }:
let dotfilesDirectory = "/etc/nixos-config/dotfiles";
in
{
  home.file = { };

  home.packages = with pkgs; [ libation reaper steam-run milkytracker bat ];
}
