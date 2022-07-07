{ lib, pkgs, rustPlatform }:
{
  app = rustPlatform.buildRustPackage rec {
    pname = "app";
    version = "0.0.1";
    src = ./.;
    cargoBuildFlags = "-p app";
   
    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    nativeBuildInputs = with pkgs; [ pkg-config ];
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
