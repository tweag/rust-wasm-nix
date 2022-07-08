{
  description = "A flake for building a Rust workspace using crane.";

  inputs = {
    crane.url = "github:ipetkov/crane";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.follows = "rust-overlay/flake-utils";
    nixpkgs.follows = "rust-overlay/nixpkgs";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        code = pkgs.callPackage ./. { inherit nixpkgs system crane rust-overlay; };
      in rec {
        packages = {
          app = code.app;
          # wasm = code.wasm;
          # all = pkgs.symlinkJoin {
          #   name = "all";
          #   paths = with code; [ app wasm ];
          # };
          # default = packages.all;
          default = code.app;
        };
      });
}
