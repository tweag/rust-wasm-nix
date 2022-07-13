{ pkgs, rustBuilder }: 
let
  pkgsWasm = import pkgs.path {
    inherit (pkgs) system overlays;
    crossSystem = {
      system = "wasm32-wasi";
      useLLVM = true;
    };
  };

  rustVersion = "1.61.0";

  rustPkgs = rustBuilder.makePackageSet {
    inherit rustVersion;
    packageFun = import ./app/Cargo.nix;
    workspaceSrc = ../cargo-separate/app;
  };

  rustPkgsWasm = pkgsWasm.rustBuilder.makePackageSet {
    inherit rustVersion;
    packageFun = import ./wasm/Cargo.nix;
    workspaceSrc = ../cargo-separate/wasm;
  };
in {
  app = (rustPkgs.workspace.app {}).bin;
  wasm = (rustPkgsWasm.workspace.wasm {}).out;
}
