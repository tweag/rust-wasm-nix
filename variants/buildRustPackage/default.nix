{ pkgs, nixpkgs, system, makeRustPlatform, rust-overlay }:
let
  overlays = [
    (import rust-overlay)
  ];

  rust-pkgs = import nixpkgs {
    inherit system overlays;
  };

  rustVersion = "1.62.0";

  wasmTarget = "wasm32-unknown-unknown";

  wasmPkgs = import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
  };

  rustWithWasmTarget = rust-pkgs.rust-bin.stable.${rustVersion}.default.override {
    targets = [ wasmTarget ];
  };

  rustPlatform = pkgs.rustPlatform;

  rustPlatformWasm = makeRustPlatform {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };
in {
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

  wasm = rustPlatformWasm.buildRustPackage rec {
    pname = "wasm";
    version = "0.0.1";
    src = ./.;
    cargoBuildFlags = "-p wasm";
   
    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    nativeBuildInputs = [ pkgs.pkg-config ];
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

    buildPhase = ''
      cargo build --release -p wasm --target=wasm32-unknown-unknown
    '';  
    installPhase = ''
      mkdir -p $out/lib
      cp target/wasm32-unknown-unknown/release/*.wasm $out/lib/
    '';  
  };  
}
