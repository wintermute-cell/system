{
  description = "NixOS system configuration with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , nur
    }:
    let
      system = "x86_64-linux";

      # Define overlays (from your dotfiles flake)
      overlays = [
        # nur overlay
        nur.overlays.default

        # unstable packages overlay, allows one to selectively use unstable.package_name
        (final: _prev: {
          unstable = import nixpkgs-unstable { inherit (final) system config; };
        })
      ];

      # Configure nixpkgs settings (let NixOS modules handle pkgs creation)
      nixpkgsConfig = { allowUnfree = true; };

    in
    {
      nixosConfigurations.rakka = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        inherit system;
        modules = [
          # Hardware and system configuration
          nixos-hardware.nixosModules.lenovo-thinkpad-t480
          ./nixos/configuration.nix

          # Configure nixpkgs with overlays system-wide
          {
            nixpkgs = {
              inherit system overlays;
              config = nixpkgsConfig;
            };
          }

          # Home-manager integration
          home-manager.nixosModules.home-manager
          {
            # avoids double nixpkgs instance and lets us use the configured nixpkgs from nixos in home-manager
            home-manager.useGlobalPkgs = true;

            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.winterveil = { ... }: {
              imports =
                [ ./home-manager/base.nix ./home-manager/winterveil.nix ];
              home = {
                username = "winterveil";
                homeDirectory = "/home/winterveil";
                stateVersion = "23.11";
              };
            };
            home-manager.users.work = { ... }: {
              imports = [ ./home-manager/base.nix ./home-manager/work.nix ];
              home = {
                username = "work";
                homeDirectory = "/home/work";
                stateVersion = "23.11";
              };
            };
          }
        ];
      };
    };
}

