{
  description = "Build a cargo project with a custom toolchain";

  inputs = {
    nixpkgs.url = "nixpkgs";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, crane, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        rustVersion = "1.62.0";

        wasmTarget = "wasm32-unknown-unknown";

        rustWithWasmTarget = pkgs.rust-bin.stable.${rustVersion}.default.override {
            targets = [ wasmTarget ];
        };

        # NB: we don't need to overlay our custom toolchain for the *entire*
        # pkgs (which would require rebuidling anything else which uses rust).
        # Instead, we just want to update the scope that crane will use by appending
        # our specific toolchain there.
        craneLib = (crane.mkLib pkgs).overrideToolchain rustWithWasmTarget;

        my-crate = craneLib.buildPackage {
          src = ./.;

          nativeBuildInputs = with pkgs; [
            openssl
            pkg-config
          ];

          cargoExtraArgs = "-p wasm";
          CARGO_BUILD_TARGET = wasmTarget;

          # Tests currently need to be run via `cargo wasi` which
          # isn't packaged in nixpkgs yet...
          doCheck = false;
        };
      in
      {
        checks = {
          inherit my-crate;
        };

        packages.default = my-crate;

        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "my-app" ''
            ${pkgs.wasmtime}/bin/wasmtime run ${my-crate}/bin/custom-toolchain.wasm
          '';
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.checks;

          # Extra inputs can be added here
          nativeBuildInputs = with pkgs; [
            rustWithWasmTarget
          ];
        };
      });
}
