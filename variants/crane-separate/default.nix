{ pkgs, nixpkgs, system, crane, rust-overlay }: 
let
  rustPkgs = import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
  };

  rustVersion = "1.61.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rustPkgs.rust-bin.stable.${rustVersion}.default.override {
      targets = [ wasmTarget ];
  };

  craneLib = crane.mkLib pkgs;

  # NB: we don't need to overlay our custom toolchain for the *entire*
  # pkgs (which would require rebuidling anything else which uses rust).
  # Instead, we just want to update the scope that crane will use by appending
  # our specific toolchain there.
  craneLibWasm = craneLib.overrideToolchain rustWithWasmTarget;
in
{
  app = craneLib.buildPackage {
    src = ./app;
    nativeBuildInputs = [ pkgs.pkg-config ];
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
  wasm = craneLibWasm.buildPackage {
    src = ./wasm;
    cargoExtraArgs = "--target ${wasmTarget}";
    
    # Override crane's use of --workspace, which tries to build everything.
    cargoCheckCommand = "cargo check --release";
    cargoBuildCommand = "cargo build --release";

    # Tests currently need to be run via `cargo wasi` which
    # isn't packaged in nixpkgs yet...
    doCheck = false;
  };
}
