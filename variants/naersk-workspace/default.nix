{ pkg-config, openssl, rust-bin, naersk }: 
let
  rustVersion = "1.61.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rust-bin.stable.${rustVersion}.default.override {
    targets = [ wasmTarget ];
  };

  naerskWasm = naersk.override {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };
in {
  app = naersk.buildPackage {
    name = "app";
    src = ../cargo-workspace;
    cargoBuildOptions = x: x ++ [ "-p" "app" ];
    nativeBuildInputs = [ pkg-config ];
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
  };
  wasm = naerskWasm.buildPackage {
    name = "wasm";
    src = ../cargo-workspace;
    cargoBuildOptions = x: x ++ [ "-p" "wasm" ];
    copyLibs = true;
    CARGO_BUILD_TARGET = wasmTarget;
  };
}
