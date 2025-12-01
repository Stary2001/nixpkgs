{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchzip,
  pkg-config,
  platformio-core,
  writableTmpDirAsHomeHook,
  bluez,
  i2c-tools,
  libX11,
  libgpiod_1,
  libinput,
  libusb1,
  libuv,
  libxkbcommon,
  
  # ulfius deps
  curl,
  gnutls,
  jansson,
  libmicrohttpd,
  orcania,
  yder,
  zlib,

  ulfius,
  yaml-cpp,
  udevCheckHook,
}:
let
  version = "2.7.16.a597230";

  platformio-deps-native = fetchzip {
    url = "https://github.com/meshtastic/firmware/releases/download/v${version}/platformio-deps-native-tft-${version}.zip";
    hash = "sha256-Jo7e6zsCaiJs6NyIRmD6BWJFwbs0xVlUih206ePUpwk=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "meshtasticd";
  inherit version;

  src = fetchFromGitHub {
    owner = "meshtastic";
    repo = "firmware";
    hash = "sha256-oU3Z8qjBNeNGPGT74VStAPHgsGqsQJKngHJR6m2CBa0=";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    platformio-core
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    bluez
    i2c-tools
    libX11
    libgpiod_1
    libinput
    libusb1
    libuv
    libxkbcommon
    curl
    gnutls
    jansson
    libmicrohttpd
    orcania
    yder
    zlib
    ulfius
    yaml-cpp
  ];

  preConfigure = ''
    mkdir -p platformio-deps-native
    cp -ar ${platformio-deps-native}/. platformio-deps-native
    chmod +w -R platformio-deps-native

    export PLATFORMIO_CORE_DIR=platformio-deps-native/core
    export PLATFORMIO_LIBDEPS_DIR=platformio-deps-native/libdeps
    export PLATFORMIO_PACKAGES_DIR=platformio-deps-native/packages
  '';

  buildPhase = ''
    runHook preBuild

    platformio run --environment native-tft --verbose
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # TODO

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ udevCheckHook ];

  meta = {
    description = "Meshtastic daemon for communicating with Meshtastic devices";
    longDescription = ''
      This package has `udev` rules installed as part of the package.
      Add `services.udev.packages = [ pkgs.meshtasticd ]` into your NixOS
      configuration to enable them.
    '';
    homepage = "https://github.com/meshtastic/firmware";
    mainProgram = "meshtasticd";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
