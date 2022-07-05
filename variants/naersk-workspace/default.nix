{ pkgs, nixpkgs, system, naersk, rust-overlay }: 
let
    overlays = [
        (import rust-overlay)
    ];

    rust-pkgs = import nixpkgs {
        inherit system overlays;
    };

    rustVersion = "1.62.0";

    wasmTarget = "wasm32-unknown-unknown";

    wasm-rust = rust-pkgs.rust-bin.stable.${rustVersion}.default.override {
        targets = [ wasmTarget ];
    };

    naersk-lib = pkgs.callPackage naersk {};

    wasm-naersk-lib = pkgs.callPackage naersk {
        cargo = wasm-rust;
        rustc = wasm-rust;
    };
in {
    app = naersk-lib.buildPackage {
        name = "app";
        src = ./.;
        nativeBuildInputs = with pkgs; [ openssl pkg-config ];
        cargoBuildOptions = x: x ++ [ "-p" "app" ];
    };
    wasm = wasm-naersk-lib.buildPackage {
        name = "wasm";
        src = ./.;
        nativeBuildInputs = with pkgs; [ openssl pkg-config ];
        cargoBuildOptions = x: x ++ [ "-p" "wasm" ];
        copyLibs = true;
        CARGO_BUILD_TARGET = wasmTarget;
    };
}