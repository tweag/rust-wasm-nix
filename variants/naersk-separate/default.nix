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
    src = ../cargo-separate/app;
    nativeBuildInputs = [ pkg-config ];
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
  };
  wasm = naerskWasm.buildPackage {
    name = "wasm";
    src = ../cargo-separate/wasm;
    copyLibs = true;
    CARGO_BUILD_TARGET = wasmTarget;
  };
}
