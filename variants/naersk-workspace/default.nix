{ pkgs, nixpkgs, system, naersk, rust-overlay }: 
let
  rustPkgs = import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
  };

  rustVersion = "1.62.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rustPkgs.rust-bin.stable.${rustVersion}.default.override {
    targets = [ wasmTarget ];
  };

  naerskLib = pkgs.callPackage naersk {};

  naerskLibWasm = pkgs.callPackage naersk {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };
in {
  app = naerskLib.buildPackage {
    name = "app";
    src = ./.;
    nativeBuildInputs = with pkgs; [ openssl pkg-config ];
    cargoBuildOptions = x: x ++ [ "-p" "app" ];
  };
  wasm = naerskLibWasm.buildPackage {
    name = "wasm";
    src = ./.;
    nativeBuildInputs = with pkgs; [ openssl pkg-config ];
    cargoBuildOptions = x: x ++ [ "-p" "wasm" ];
    copyLibs = true;
    CARGO_BUILD_TARGET = wasmTarget;
  };
}