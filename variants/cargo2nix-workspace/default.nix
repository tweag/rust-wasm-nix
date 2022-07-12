{ pkgs, nixpkgs, system, cargo2nix }: 
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [cargo2nix.overlays.default];
  };

  pkgsWasm = import nixpkgs {
    inherit system;
    crossSystem = {
      system = "wasm32-wasi";
      useLLVM = true;
    };
    overlays = [cargo2nix.overlays.default];
  };

  rustVersion = "1.61.0";

  rustPkgs = pkgs.rustBuilder.makePackageSet {
    inherit rustVersion;
    packageFun = import ./Cargo.nix;
  };

  rustPkgsWasm = pkgsWasm.rustBuilder.makePackageSet {
    inherit rustVersion;
    packageFun = import ./Cargo.nix;
  };
in {
  app = (rustPkgs.workspace.app {}).bin;
  wasm = (rustPkgsWasm.workspace.wasm {}).out;
}