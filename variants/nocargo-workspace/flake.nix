# See more usages of nocargo at https://github.com/oxalica/nocargo#readme
{
  description = "My Rust packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nocargo = {
      url = "github:oxalica/nocargo";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.registry-crates-io.follows = "registry-crates-io";
    };
    # Optionally, you can override crates.io index to get cutting-edge packages.
    # registry-crates-io = { url = "github:rust-lang/crates.io-index"; flake = false; };
  };

  outputs = { nixpkgs, flake-utils, nocargo, ... }@inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        ws = nocargo.lib.${system}.mkRustPackageOrWorkspace {
          src = ./.;
        };
      in rec {
        packages = ws.release
          // nixpkgs.lib.mapAttrs' (name: value: { name = "${name}-dev"; inherit value; }) ws.dev;
      });
}
