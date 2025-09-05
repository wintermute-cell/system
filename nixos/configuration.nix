# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, inputs, ... }: {
  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # actually mount /tmp as a tmpfs/ramdisk
  boot.tmp.useTmpfs = true;

  # enable aarch64-linux cross-compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # firmware updater
  services.fwupd.enable = true;

  # this is required for udiskie automount in home-manager
  services.udisks2.enable = true;

  services.seatd.enable = true;

  # allow mounting android devices in pcmanfm
  services.gvfs.enable = true;

  networking.hostName = "rakka"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.extraHosts = ''
    127.0.0.1 dieter-server
    127.0.0.1 postgres
  '';

  fonts.fontconfig = { enable = true; };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # enable qmk keyboard support
  hardware.keyboard.qmk.enable = true;

  hardware.uinput.enable = true;
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        config = ''
          (defsrc
            h j
          )

          (defchords chords 10
            (h j) esc
            (h) h
            (j) j
          )

          (deflayer base
            (chord chords h) (chord chords j)
          )
        '';
      };
    };
  };

  services.udev.extraRules = ''
    # Atmel DFU
    SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2fef", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2ff*", MODE="0666"
  '';

  # Enable Avahi daemon for network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable mDNS resolution
    openFirewall = true; # Open required ports
  };

  # zsh system wide
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # fish for interactive shell
  programs.fish.enable = true;
  # Configure keymap in X11, for wayland, this is done in the river init.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "compose:rctrl, caps:escape";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Battery / power management
  powerManagement.enable = true;
  services.tlp.enable = true;
  services.upower.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # users.mutableUsers = true; # allow users to change their own passwords
  users.groups.homeowner = { }; # allows access to /etc/dotfiles
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.winterveil = {
    isNormalUser = true;
    description = "winterveil";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "docker"
      "wireshark"
      "homeowner"
      "uinput"
      "dialout"
    ];
    packages = [ ];
  };
  users.users.work = {
    isNormalUser = true;
    description = "work";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "docker"
      "wireshark"
      "homeowner"
      "uinput"
      "dialout"
    ];
    packages = [ ];
  };

  # Fix dynamically linked binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # default list from https://github.com/NixOS/nixpkgs/blob/2a58fe7ed15fb345fc6ada7e929c0796321c8593/nixos/modules/programs/nix-ld.nix#L44
    zlib
    zstd
    curl
    openssl
    attr
    libssh
    bzip2
    libxml2
    acl
    libsodium
    util-linux
    xz
    systemd
    stdenv.cc.cc
    stdenv.cc.cc.lib
    fontconfig

    # vst3s
    libpulseaudio
    cairo
    xorg.libxcb
    freetype
    glib

    # electron
    glib
    glibc
    nss
    nspr
    cups # for libcups.so.2
    libdrm # for libdrm.so.2
    gtk3 # for libgtk-3.so.0
    pango # for libpango-1.0.so.0
    cairo # for libcairo.so.2
    xorg.libX11 # for libX11.so.6
    xorg.libXcomposite # for libXcomposite.so.1
    xorg.libXdamage # for libXdamage.so.1
    xorg.libXext # for libXext.so.6
    xorg.libXfixes # for libXfixes.so.3
    expat # for libexpat.so.1
    xorg.libxcb # for libxcb.so.1
    alsa-lib # for libasound.so.2
    at-spi2-atk # for libatspi.so.0
    mesa # for libgbm.so.1

    # random wayland stuff, good for running wayland bars etc..
    wayland
    wayland-protocols
    wayland-scanner

    fcft
    libpulseaudio
    pixman
    systemdLibs

    # for raylib-go
    libGL
    xorg.libXi
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    wayland
    libxkbcommon
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    dash
    cpio
    fuzzel # app launcher for my sway config
    i3ipc-glib # requirement for swaymonad
    networkmanagerapplet
    pulseaudio # in addition to the option, to have pactl available
    udiskie
    waybar
    wob
    vim
    git
    grim
    slurp
    wl-clipboard
    mako
    qt5.qtwayland
    jmtpfs
    niri
    wlr-randr
    dbus
    dnsmasq
    distrobox
    foot

    # some system man pages
    # linux-manual
    man-pages
    man-pages-posix
  ];

  documentation = {
    enable = true;
    man.enable = true;
    man.generateCaches =
      false; # takes ages, fish auto-enables this so we set it off again
    nixos.enable = true;
    dev.enable = true;
    info.enable = true;
    doc.enable = true;
  };

  # Encourage the use of wayland
  environment.sessionVariables = rec {
    # Set XDG directories
    # XDG_CONFIG_HOME = "$HOME/.config";
    # XDG_CACHE_HOME = "$HOME/.cache";
    # XDG_DATA_HOME = "$HOME/.local/share";
    # XDG_DATA_DIRS = "$HOME/.local/share/:$HOME/.nix-profile/share/:$XDG_DATA_DIRS";
    # XDG_STATE_HOME = "$HOME/.local/state";

    # Login
    LIBSEAT_BACKEND = "logind";

    # Wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # XDG_CURRENT_DESKTOP = "river";
    # XDG_SESSION_DESKTOP = "river";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  services.gnome.gnome-keyring.enable = true;
  hardware.graphics.enable = true; # for some reason opengl is default off??
  programs.xwayland.enable = true;
  # programs.river = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     # default
  #     swaylock
  #     foot
  #     dmenu
  #     # custom
  #     river-luatile
  #     wideriver
  #   ];
  # };
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [ swayidle swaylock swaysome ];
  };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # wireshark can't be installed using home-manager
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  # Bluetooth (hardware settings in hardware file)
  services.blueman.enable = true;

  # Backlight
  programs.light.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd "sway --unsupported-gpu"'';
        # command = ''${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd "dbus-run-session river"'';
        user = "greeter";
      };
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;

  # this is a life saver.
  # literally no documentation about this anywhere.
  # might be good to write about this...
  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # disable docker auto start
  systemd.services.docker.wantedBy = lib.mkForce [ ];

  virtualisation = {
    containers.enable = true;
    docker.enable = true;
    # podman = {
    #   enable = true;
    #   defaultNetwork.settings.dns_enabled = true;
    # };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
