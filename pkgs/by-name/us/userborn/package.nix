{
  lib,
  rustPlatform,
  fetchFromGitHub,
  libxcrypt,
  nixosTests,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "userborn";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "nikstur";
    repo = "userborn";
    rev = version;
    hash = "sha256-ABePye1zuGDH74BL6AP05rR9eBOYu1SoVpd2TcZQMW8=";
  };

  sourceRoot = "${src.name}/rust/userborn";

  useFetchCargoVendor = true;
  cargoPatches = [ ./use-patched-libxcrypt.patch ];

  cargoHash = "sha256-d/k3J6vTOjK5fA8fPJpS1JS5584twp9lBVA0qjhyX/0=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  buildInputs = [ libxcrypt ];

  stripAllList = [ "bin" ];

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      inherit (nixosTests)
        userborn
        userborn-mutable-users
        userborn-mutable-etc
        userborn-immutable-users
        userborn-immutable-etc
        ;
    };
  };

  meta = with lib; {
    homepage = "https://github.com/nikstur/userborn";
    description = "Declaratively bear (manage) Linux users and groups";
    changelog = "https://github.com/nikstur/userborn/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with lib.maintainers; [ nikstur ];
    mainProgram = "userborn";
  };
}
