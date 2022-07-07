{
  description = "A flake for building a Rust workspace using naersk.";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, naersk, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        code = pkgs.callPackage ./. { inherit nixpkgs system naersk rust-overlay; };
      in rec {
        packages = {
          app = code.app;
          wasm = code.wasm;
          default = code.app;
          everything = pkgs.symlinkJoin {
            name = "everything";
            paths = with code; [ app wasm ];
          };
        };

      });
}
