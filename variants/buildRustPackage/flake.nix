{
  description = "A flake for building a Rust workspace using buildRustPackage.";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rustPlatform = pkgs.rustPlatform;
        code = pkgs.callPackage ./. { inherit rustPlatform; };
      in rec {
        packages = {          
          app = code.app;
          wasm = code.wasm;
          all = pkgs.symlinkJoin {
            name = "all";
            paths = with code; [ app wasm ];
          };
          default = packages.all;
        };
      });
}
