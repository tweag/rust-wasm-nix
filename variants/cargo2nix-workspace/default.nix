{ pkgs, nixpkgs, system, cargo2nix }: 
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [cargo2nix.overlays.default];
  };

  wasmPkgs = import nixpkgs {
    inherit system;
    crossSystem = {
      system = "wasm32-wasi";
      useLLVM = true;
    };
    overlays = [cargo2nix.overlays.default];
  };

  rustVersion = "1.61.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustPkgs = pkgs.rustBuilder.makePackageSet {
    inherit rustVersion;
    packageFun = import ./Cargo.nix;
  };

  rustPkgsWasm = wasmPkgs.rustBuilder.makePackageSet {
    inherit rustVersion;
    packageFun = import ./Cargo.nix;
    target = wasmTarget;
  };
in {
  app = (rustPkgs.workspace.app {}).bin;
  wasm = (rustPkgsWasm.workspace.wasm {}).out;
}