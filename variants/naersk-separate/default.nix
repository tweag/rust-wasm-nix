{ pkgs, naersk }: 
let
    naersk-lib = pkgs.callPackage naersk {};
in {
    app = naersk-lib.buildPackage {
        src = ./app;
        copySources = ["../cats"];
        nativeBuildInputs = with pkgs; [ openssl pkg-config ];
    };
    wasm = naersk-lib.buildPackage {
        src = ./wasm;
        nativeBuildInputs = with pkgs; [ openssl pkg-config ];
    };
}