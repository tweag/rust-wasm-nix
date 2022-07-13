{ pkg-config, openssl, rustPlatform, makeRustPlatform, rust-bin }:
let
  rustVersion = "1.61.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rust-bin.stable.${rustVersion}.default.override {
    targets = [ wasmTarget ];
  };

  rustPlatformWasm = makeRustPlatform {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };

  common = {
    version = "0.0.1";

    nativeBuildInputs = [ pkg-config ];
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
  };
in {
  app = rustPlatform.buildRustPackage (common // {
    pname = "app";
    src = ./app;
    
    cargoLock = {
      lockFile = ./app/Cargo.lock;
    };
  });

  wasm = rustPlatformWasm.buildRustPackage (common // {
    pname = "wasm";
    src = ./wasm;
    
    cargoLock = {
      lockFile = ./wasm/Cargo.lock;
    };

    buildPhase = ''
      cargo build --release --target=wasm32-unknown-unknown
    '';  
    installPhase = ''
      mkdir -p $out/lib
      cp target/wasm32-unknown-unknown/release/*.wasm $out/lib/
    '';  
  });
}
