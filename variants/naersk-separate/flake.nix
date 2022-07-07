{
  description = "A flake for building a Rust workspace using naersk.";

  inputs = {
    nixpkgs.url = "nixpkgs";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      code = pkgs.callPackage ./. { inherit naersk; };
    in {
      defaultPackage.x86_64-linux = code.app;

      packages.x86_64-linux = {
        app = code.app;
        wasm = code.wasm;
      };
    };
}
