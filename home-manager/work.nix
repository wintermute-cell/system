{ pkgs, config, lib, ... }:
let dotfilesDirectory = "/etc/nixos-config/dotfiles";
in
{
  home.file = {
    # git
    "${config.xdg.configHome}/git" = lib.mkForce {
      source = ../dotfiles/work/git;
      recursive = false;
    };

    # ssh
    "${config.home.homeDirectory}/.ssh/config" = lib.mkForce {
      source = ../dotfiles/work/ssh/config;
      recursive = false;
    };
  };

  home.packages = with pkgs; [ yarn dbeaver-bin ];
}
