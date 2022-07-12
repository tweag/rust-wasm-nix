{
  description = "A flake for building a Rust workspace using cargo2nix.";

  inputs = {
    cargo2nix.url = "github:torhovland/cargo2nix/wasm";
    flake-utils.follows = "cargo2nix/flake-utils";
    nixpkgs.follows = "cargo2nix/nixpkgs";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        code = pkgs.callPackage ./. { inherit nixpkgs system cargo2nix; };
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
      }
    );
}

