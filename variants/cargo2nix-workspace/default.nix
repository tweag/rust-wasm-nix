{ pkgs, nixpkgs, system, cargo2nix }: 
let
  wasmTarget = "wasm32-unknown-unknown";

  pkgs = import nixpkgs {
    inherit system;
    overlays = [cargo2nix.overlays.default];
  };

  wasmPkgs = import nixpkgs {
    inherit system;
    crossSystem = {
      config = "wasm32-unknown-wasi-unknown";
      system = "wasm32-wasi";
      useLLVM = true;
    };
    overlays = [cargo2nix.overlays.default];
  };

  rustPkgs = pkgs.rustBuilder.makePackageSet {
    rustVersion = "1.61.0";
    packageFun = import ./Cargo.nix;
  };

  rustPkgsWasm = wasmPkgs.rustBuilder.makePackageSet {
    rustVersion = "1.61.0";
    packageFun = import ./Cargo.nix;
    target = "wasm32-unknown-unknown";
  };
in {
  app = (rustPkgs.workspace.app {}).bin;
  wasm = (rustPkgsWasm.workspace.wasm {}).out;
}