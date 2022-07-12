# Options for building Rust with Nix

While supporting a common workspace where a native Rust app and a Wasm app both
work even when they need slightly different dependencies.

## Just Cargo (no Nix)

### Cargo and separate crates (no workspace)

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

### Cargo and a common workspace

Interestingly, both apps still work:

```
cd variants/cargo-workspace/app
cargo run
```

```
cd variants/cargo-workspace/wasm
wasm-pack test --firefox --headless
```

## buildRustPackage

### Separate crates

```
cd variants/buildRustPackage-separate
nix build
```

This fails because it expects to find `/build/cats/Cargo.toml`.

### Workspace

```
cd variants/buildRustPackage-workspace
nix build
ls -R result*
```

## naersk

### Separate crates

```
cd variants/naersk-separate
nix build
```

This fails because it expects to find `/build/cats/Cargo.toml`.

### Workspace

```
cd variants/naersk-workspace
nix build
ls -R result*
```

## crane

### Separate crates

```
cd variants/crane-separate
nix build
```

This fails because it expects to find `/build/cats/Cargo.toml`.

### Workspace

```
cd variants/crane-workspace
nix build
ls -R result*
```

## cargo2nix

### Separate crates

```
cd variants/cargo2nix-separate
nix build
ls -R result*
```

### Workspace

```
cd variants/cargo2nix-workspace
nix build
ls -R result*
```
