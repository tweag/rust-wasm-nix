{ pkgs, nixpkgs, system, makeRustPlatform, rust-overlay }:
let
  rust-pkgs = import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
  };

  rustVersion = "1.62.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rust-pkgs.rust-bin.stable.${rustVersion}.default.override {
    targets = [ wasmTarget ];
  };

  rustPlatformWasm = makeRustPlatform {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };

  common = {
    version = "0.0.1";
    src = ./.;

    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    nativeBuildInputs = [ pkgs.pkg-config ];
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
in {
  app = pkgs.rustPlatform.buildRustPackage (common // {
    pname = "app";
    cargoBuildFlags = "-p app";
  });

  wasm = rustPlatformWasm.buildRustPackage (common // {
    pname = "wasm";

    buildPhase = ''
      cargo build --release -p wasm --target=wasm32-unknown-unknown
    '';  
    installPhase = ''
      mkdir -p $out/lib
      cp target/wasm32-unknown-unknown/release/*.wasm $out/lib/
    '';  
  });
}
