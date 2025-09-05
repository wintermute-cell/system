with import <nixpkgs> {};
(callPackage ./default.nix {}).overrideAttrs (old: {
  nativeBuildInputs = old.nativeBuildInputs ++ [ ];
})
