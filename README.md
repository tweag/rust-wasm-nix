# Options for building Rust with Nix

While supporting a common workspace where a native Rust app and a Wasm app both
work even when they need slightly different dependencies.

## Cargo and separate crates (no Nix and no workspace)

You can verify that the native Rust app works:

```
cd variants/cargo-separate/app
cargo run
```

And you can verify that the Wasm app also works:

```
cd variants/cargo-separate/wasm
wasm-pack test --firefox --headless
```

Replace `--firefox` with `--chrome` or `--safari` if necessary.

## Cargo and a common workspace (no Nix)

Interestingly, both apps still work:

```
cd variants/cargo-workspace/app
cargo run
```

```
cd variants/cargo-workspace/wasm
wasm-pack test --firefox --headless
```
