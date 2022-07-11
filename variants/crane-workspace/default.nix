{ pkgs, nixpkgs, system, crane, rust-overlay }: 
let
  overlays = [
    (import rust-overlay)
  ];

  rustPkgs = import nixpkgs {
    inherit system overlays;
  };

  rustVersion = "1.62.0";

  wasmTarget = "wasm32-unknown-unknown";

  wasmPkgs = import nixpkgs {
    inherit system;
    crossSystem = {
      config = "wasm32-unknown-wasi-unknown";
      system = "wasm32-wasi";
      useLLVM = true;
    };
    overlays = [ (import rust-overlay) ];
  };

  rustWithWasmTarget = rustPkgs.rust-bin.stable.${rustVersion}.default.override {
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

    cargoCheckCommand = "cargo check --release";
    cargoBuildCommand = "cargo build --release";
    cargoExtraArgs = "-p wasm --target ${wasmTarget}";
    CARGO_BUILD_TARGET = wasmTarget;

    # Tests currently need to be run via `cargo wasi` which
    # isn't packaged in nixpkgs yet...
    doCheck = false;
  };
in
{
  app = pkgs.writeShellScriptBin "my-app" ''
    ${pkgs.wasmtime}/bin/wasmtime run ${my-crate}/bin/custom-toolchain.wasm
  '';
}
