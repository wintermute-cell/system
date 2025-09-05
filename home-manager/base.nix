{ pkgs, config, ... }:
let
  # NOTE: this is used as a crutch since flake based home-manager cannot do
  # direct writable symlinks of config files when using mkOutOfStoreSymlink
  # with a relative path. Therefore we need to use the absolute path for the
  # link source. To stay consistent, this is centrally defined as `dotfilesDirectory`.
  # see: https://github.com/nix-community/home-manager/issues/3514
  dotfilesDirectory = "/etc/nixos-config/dotfiles";
in
{
  news.display = "silent";

  programs.home-manager.enable = true;

  # required to autoload fonts from packages installed via Home Manager
  fonts.fontconfig.enable = true;

  # gtk = {
  #   enable = true;
  #   cursorTheme = {
  #     name = "plan9";
  #     package = (pkgs.callPackage ../packages/xcursor-plan9/default.nix {});
  #   };
  # };

  home.pointerCursor = {
    gtk.enable =
      true; # this was supposed to fix wrong cursor in firefox but oh well...
    x11.enable = true;
    name = "plan9";
    package = (pkgs.callPackage ../packages/xcursor-plan9/default.nix { });
    # size = 28;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = "firefox.desktop";
        imageViewer = "nsxiv.desktop";
        videoPlayer = "mpv.desktop";
        audioPlayer = "vlc.desktop";
        # pdfViewer = "org.pwmt.zathura.desktop";
        pdfViewer = "sioyek.desktop";
      in
      {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/chrome" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;
        "application/json" = browser;
        "application/pdf" = pdfViewer;
        "application/epub+zip" = pdfViewer;
        "text/plain" = "nvim.desktop";
        "text/markdown" = "nvim.desktop";
        "text/x-markdown" = "nvim.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "image/bmp" = imageViewer;
        "image/gif" = imageViewer;
        "image/jpeg" = imageViewer;
        "image/jpg" = imageViewer;
        "image/png" = imageViewer;
        "image/svg+xml" = imageViewer;
        "image/tiff" = imageViewer;
        "image/vnd.microsoft.icon" = imageViewer;
        "image/webp" = imageViewer;
        "video/mp2t" = videoPlayer;
        "video/mp4" = videoPlayer;
        "video/mpeg" = videoPlayer;
        "video/ogg" = videoPlayer;
        "video/webm" = videoPlayer;
        "video/x-flv" = videoPlayer;
        "video/x-matroska" = videoPlayer;
        "video/x-msvideo" = videoPlayer;
        "audio/aac" = audioPlayer;
        "audio/mpeg" = audioPlayer;
        "audio/ogg" = audioPlayer;
        "audio/opus" = audioPlayer;
        "audio/wav" = audioPlayer;
        "audio/webm" = audioPlayer;
        "audio/x-matroska" = audioPlayer;
        "all/all" = "pcmanfm.desktop";
        "inode/directory" = "pcmanfm.desktop";
      };
  };

  home.packages = with pkgs; [
    # meta
    nix-search-cli
    comma

    # base system stuff
    zip
    unzip
    dtrx # extraction multitool (Do The Right Extraction)
    nvtopPackages.full
    trashy # safer alternative to rm, moves to xdg trash

    # backup
    borgbackup

    # base dev stuff, often a dependency for other progs
    gcc
    git
    file
    wget
    curl
    gnumake
    jq # json formatter
    perl
    cmake
    openssl
    killall
    pstree # process tree, useful for low level debugging
    cargo
    rustc
    libnotify
    tree
    sshfs # mounting remote filesystems
    mtpfs # mounting android phones (and kindle devices!)
    awscli2
    plan9port
    pkg-config
    btop
    glances
    fzf
    xterm
    edwood
    wio
    dash
    bc
    dbeaver-bin
    xorg.xkeyboardconfig # just to have the man pages
    fd

    # networking stuff
    nmap
    netcat
    tcpdump

    # python packages
    (python311.withPackages (ps:
      with ps; [
        # this is the python install. add all library packages here
        i3ipc
        packaging
        pandas
        networkx
        matplotlib
        scipy
        pywayland
        evdev
      ]))
    uv

    python312Packages.pip

    # runtimes, envs, etc.
    nodejs
    #python3
    go
    graphviz # required for viewing pprof files
    delve # go debugger
    docker
    sqlite
    elixir
    lua
    jdk # ltex-ls requires java

    # fonts
    fontpreview # pretty bad UX, only works from terminal; but works on NixOS, font-manager does not
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    sarasa-gothic
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    mononoki
    # terminus_font
    # creep
    # cozette
    # tamzen

    # neovim and its deps
    unstable.neovim
    stylua # external prog, used for formatting lua code
    ripgrep
    tree-sitter # the latex plugin needs this to be a PATH executable
    neovide
    neovim-remote
    markdownlint-cli

    # emacs lol
    emacs

    # vscode eww
    vscode

    # user progs
    gh
    thunderbird
    alacritty
    wezterm
    unstable.zellij
    lazygit
    bottom # system monitor like htop
    zathura
    sioyek
    nsxiv
    dust # du but better UX
    # ncdu # ncurses du
    dua # ncdu but better and faster
    mpv
    unstable.signal-desktop
    discord
    pcmanfm
    aseprite
    fastfetch
    teamspeak_client
    pavucontrol
    chafa # image/gif to textmode art cli tool
    # (callPackage ../packages/streamrip/streamrip.nix {})
    streamrip
    (gimp-with-plugins.override { plugins = with gimpPlugins; [ gmic ]; })
    libnotify
    tldr
    shotwell
    mpd
    # cantata # mpd client / music player # NOTE: compilation broken on latest unstable 18.10.24
    obsidian
    anki-bin
    bruno # API IDE like Postman
    wf-recorder # wayland screen recorder
    sway-contrib.grimshot # sway screenshot helper
    hyprpicker # color picker
    # mnemosyne # NOTE: compilation broken on latest unstable 18.10.24
    xournalpp
    adwaita-icon-theme # required by xournalpp
    wl-mirror
    # (callPackage ../packages/timetrace/default.nix {}) # replaced by watson
    figlet
    obs-studio
    (callPackage ../packages/pureref/default.nix { })
    ffmpeg
    pandoc
    (texliveFull.withPackages (ps: with ps; [ courier ]))
    liberation_ttf_v1 # some basic fonts
    unstable.prusa-slicer
    # jetbrains.goland
    # jetbrains.clion
    vlc
    avizo
    kitty
    unstable.ghostty
    playerctl
    j4-dmenu-desktop
    bemenu
    qimgv
    yt-dlp
    rx # vim like pixelart program
    lazydocker
    # libreoffice
    (callPackage ../packages/dam/default.nix { })
    go-task
    typora
    unstable.feishin # navidrome client
    (callPackage ../packages/markdown-flashcards/default.nix { })
    nyxt
    gnome-network-displays
    vial
    unstable.claude-code
  ];

  services.dunst = {
    enable = true;
    settings = {
      global = {
        browser = "firefox -new-tab";
        dmenu = "fuzzel";
        follow = "mouse";
        font = "Droid Sans 10";
        format = ''
          %a
          <b>%s</b>
          %b'';
        frame_color = "#555555";
        frame_width = 2;
        geometry = "500x5-5+30";
        horizontal_padding = 8;
        icon_position = "off";
        line_height = 0;
        markup = "full";
        padding = 8;
        separator_color = "frame";
        separator_height = 2;
        transparency = 10;
        word_wrap = true;
      };

      urgency_low = {
        background = "#1d1f21";
        foreground = "#4da1af";
        frame_color = "#4da1af";
        timeout = 10;
      };

      urgency_normal = {
        background = "#1d1f21";
        foreground = "#70a040";
        frame_color = "#70a040";
        timeout = 15;
      };

      urgency_critical = {
        background = "#1d1f21";
        foreground = "#dd5633";
        frame_color = "#dd5633";
        timeout = 0;
      };

      shortcuts = {
        context = "mod4+grave";
        close = "mod4+shift+space";
      };
    };
  };

  # udiskie
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  # firefox
  programs.firefox = {
    enable = true;
    profiles."winterveil" = {
      isDefault = true;
      settings = {
        "browser.compactmode.show" = true;
        "general.autoScroll" = true;
        "browser.toolbars.bookmarks.visibility" = "always";
      };
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        kagi-search
        tridactyl
        bitwarden
        sponsorblock
        clearurls
        consent-o-matic # auto cookie popup solver
        dearrow # youtube de-clickbaiting
        localcdn # intercepts CDN requests and tries to use local cache
        onetab
        privacy-badger # tracker blocker
        return-youtube-dislikes
        streetpass-for-mastodon
        ublock-origin
        youtube-nonstop
        translate-web-pages
        darkreader
      ];
    };
  };

  # nix-index
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    # enableFishIntegration = true; # doesnt work if fish is not managed by home-manager
  };

  programs.tmux = {
    enable = true;
    shortcut = "t";
    shell = "${pkgs.fish}/bin/fish";
    baseIndex = 1;
    keyMode = "vi";
    clock24 = true;
    escapeTime = 0;
    focusEvents = true;
    aggressiveResize = true;
    historyLimit = 64000;
    plugins = with pkgs; [ tmuxPlugins.mode-indicator ];
    extraConfig = ''
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      # Status bar colors for light terminal
      set -g status-style 'bg=default,fg=black'
      set -g status-left-style 'bg=black,fg=white'
      set -g status-right-style 'bg=default,fg=black'
      
      # Window status colors
      set -g window-status-style 'bg=default,fg=black'
      set -g window-status-current-style 'bg=black,fg=white,bold'
      set -g window-status-activity-style 'bg=default,fg=red'
      
      # Pane border colors
      set -g pane-border-style 'fg=brightblack'
      set -g pane-active-border-style 'fg=black'
      
      # Message colors
      set -g message-style 'bg=black,fg=white'
      set -g message-command-style 'bg=black,fg=white'

      # Status bar format
      set -g status-left "[#S] "
      set -g status-left-length 20

      # Vim-style pane navigation and controls
      bind-key v split-window -h
      bind-key s split-window -v
      
      # Vim-style pane navigation
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R
      
      # Modal resize mode with status bar indicator
      bind-key r switch-client -T resize \; set -g status-left "[#S] [RESIZE] "
      bind-key -T resize h resize-pane -L 5 \; switch-client -T resize
      bind-key -T resize j resize-pane -D 5 \; switch-client -T resize
      bind-key -T resize k resize-pane -U 5 \; switch-client -T resize
      bind-key -T resize l resize-pane -R 5 \; switch-client -T resize
      bind-key -T resize r switch-client -T root \; set -g status-left "[#S] "
      bind-key -T resize Escape switch-client -T root \; set -g status-left "[#S] "
      
      # Additional vim-like bindings
      bind-key x kill-pane
      bind-key X kill-window

      set -g status-right '%Y-%m-%d %H:%M #{tmux_mode_indicator}'

      # some plugins need to be loaded again after configuring
      run-shell ${pkgs.tmuxPlugins.mode-indicator}/share/tmux-plugins/mode-indicator/mode_indicator.tmux
    '';
  };

  home.file = {
    # zellij
    "${config.home.homeDirectory}/scripts" = {
      source = ../dotfiles/scripts;
      recursive = false;
    };

    # nvim
    "${config.xdg.configHome}/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/nvim";

    ## git
    #"${config.xdg.configHome}/git" = {
    #  source = ../dotfiles/git;
    #  recursive = false;
    #};

    # fish
    # "${config.xdg.configHome}/fish" = {
    #   source = ../dotfiles/fish;
    #   recursive = false;
    # };
    "${config.xdg.configHome}/fish".source = # fish requires .config/fish/fish_variables to be writable
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/fish";

    # sway
    # "${config.xdg.configHome}/sway" = {
    #   source = ../dotfiles/sway;
    #   recursive = false;
    # };

    # alacritty
    "${config.xdg.configHome}/alacritty" = {
      source = ../dotfiles/alacritty;
      recursive = false;
    };

    # foot
    "${config.xdg.configHome}/foot" = {
      source = ../dotfiles/foot;
      recursive = false;
    };

    # wezterm
    "${config.xdg.configHome}/wezterm" = {
      source = ../dotfiles/wezterm;
      recursive = false;
    };

    # tmux
    # "${config.xdg.configHome}/tmux" = {
    #   source = ../dotfiles/tmux;
    #   recursive = false;
    # };
    #
    # "${config.xdg.configHome}/nixos_generated/tmux_fish.conf" = {
    #   text = ''
    #     # integrate fish shell into tmux
    #     set-option -g default-shell "${pkgs.fish}/bin/fish"
    #   '';
    # };

    "${config.xdg.configHome}/nixos_generated/fish_nix_index.fish" =
      let
        wrapper = pkgs.writeScript "command-not-found" ''
          #!${pkgs.bash}/bin/bash
          source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
          command_not_found_handle "$@"
        '';
      in
      {
        text = ''
          # integrate nix-index's command-not-found into fish
          function fish_command_not_found
            ${wrapper} $argv
          end
        '';
      };

    # waybar
    "${config.xdg.configHome}/waybar" = {
      source = ../dotfiles/waybar;
      recursive = false;
    };

    # sioyek
    "${config.xdg.configHome}/sioyek" = {
      source = ../dotfiles/sioyek;
      recursive = false;
    };

    # zathura
    "${config.xdg.configHome}/zathura" = {
      source = ../dotfiles/zathura;
      recursive = false;
    };

    # fuzzel
    "${config.xdg.configHome}/fuzzel" = {
      source = ../dotfiles/fuzzel;
      recursive = false;
    };

    # mpd
    "${config.xdg.configHome}/mpd" = {
      source = ../dotfiles/mpd;
      recursive = false;
    };

    # streamrip
    "${config.xdg.configHome}/streamrip" = {
      source = ../dotfiles/streamrip;
      recursive = false;
    };

    # wob
    "${config.xdg.configHome}/wob" = {
      source = ../dotfiles/wob;
      recursive = false;
    };

    # ssh
    "${config.home.homeDirectory}/.ssh/config" = {
      source = ../dotfiles/ssh/config;
      recursive = false;
    };

    # ghostty
    "${config.xdg.configHome}/ghostty" = {
      source = ../dotfiles/ghostty;
      recursive = false;
    };

    # river
    "${config.xdg.configHome}/river" = {
      source = ../dotfiles/river;
      recursive = false;
    };

    # zellij
    "${config.xdg.configHome}/zellij" = {
      source = ../dotfiles/zellij;
      recursive = false;
    };

  };
}
