{
  description = "A flake for building a Rust workspace using buildRustPackage.";

  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.follows = "rust-overlay/flake-utils";
    nixpkgs.follows = "rust-overlay/nixpkgs";
    naersk.url = "github:nix-community/naersk";
    cargo2nix.url = "github:torhovland/cargo2nix/wasm";
    crane.url = "github:ipetkov/crane";
  };

  outputs = { self, rust-overlay, flake-utils, nixpkgs, naersk, cargo2nix, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = map (x: x.overlays.default or x.overlay) [
            rust-overlay naersk cargo2nix
            { # crane's overlay is weird
              overlay = (final: prev: {
                crane = crane.mkLib final;
              });
            }
          ];
        };
        inherit (builtins) filter pathExists readDir attrNames;
        inherit (pkgs.lib) genAttrs;
        toSymlinks = path: let
          code = pkgs.callPackage path { };
        in
          pkgs.symlinkJoin {
            name = "${baseNameOf path}-all";
            paths = with code; [ app wasm ];
            passthru = code;
          };
        
        variantNames = filter (name: pathExists (./variants + "/${name}/default.nix"))
          (attrNames (readDir ./variants));
        
      in {
        # usage: nix build .#buildRustPackage-workspace
        # or: nix build .#buildRustPackage-workspace.wasm
        packages = genAttrs variantNames (name: toSymlinks (./variants + ("/" + name)));
      }
    );
}
