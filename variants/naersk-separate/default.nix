{ pkgs, nixpkgs, system, naersk, rust-overlay }: 
let
  rustPkgs = import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
  };

  rustVersion = "1.61.0";

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
    src = ./app;
    nativeBuildInputs = [ pkgs.pkg-config ];
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
  wasm = naerskLibWasm.buildPackage {
    name = "wasm";
    src = ./wasm;
    copyLibs = true;
    CARGO_BUILD_TARGET = wasmTarget;
  };
}