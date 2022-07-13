{ pkg-config, openssl, crane, rust-bin }: 
let
  rustVersion = "1.61.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rust-bin.stable.${rustVersion}.default.override {
    targets = [ wasmTarget ];
  };

  # NB: we don't need to overlay our custom toolchain for the *entire*
  # pkgs (which would require rebuidling anything else which uses rust).
  # Instead, we just want to update the scope that crane will use by appending
  # our specific toolchain there.
  craneWasm = crane.overrideToolchain rustWithWasmTarget;
in
{
  app = crane.buildPackage {
    src = ./.;
    cargoExtraArgs = "-p app";
    nativeBuildInputs = [ pkg-config ];
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
  };
  wasm = craneWasm.buildPackage {
    src = ./.;
    cargoExtraArgs = "-p wasm --target ${wasmTarget}";
    
    # Override crane's use of --workspace, which tries to build everything.
    cargoCheckCommand = "cargo check --release";
    cargoBuildCommand = "cargo build --release";

    # Tests currently need to be run via `cargo wasi` which
    # isn't packaged in nixpkgs yet...
    doCheck = false;
  };
}
