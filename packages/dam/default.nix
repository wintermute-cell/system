{ lib
, stdenv
, pkg-config
, wayland-scanner
, wayland-protocols
, wayland
, fcft
, pixman
}:

stdenv.mkDerivation {
  pname = "dam";
  version = "0";

  src = ./.;

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    fcft
    pixman
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Itsy-bitsy dwm-esque bar for river.";
    homepage = "https://codeberg.org/sewn/dam";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ "sewn" "winterveil" ];
  };
}

