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
    target = "wasm32-unknown-unknown";

    # cargo2nix thinks we're building for wasm32-unknown-wasi now.
    # We need to guide it to wasm32-unknown-unknown instead.
    packageFun = attrs: import ./Cargo.nix (attrs // {
      hostPlatform = attrs.hostPlatform // {
        parsed = attrs.hostPlatform.parsed // {
          kernel.name = "unknown";
        };
      };
    });
  };
in {
  app = (rustPkgs.workspace.app {}).bin;
  wasm = (rustPkgsWasm.workspace.wasm {}).out;
}