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

## cargo2nix

Following the cargo2nix instructions, we generate a `Cargo.nix` file by running:

```
cd variants/cargo2nix-workspace
nix run github:cargo2nix/cargo2nix
git add Cargo.nix
```

Then we can simply build and run our native app like this:

```
nix run
```

However, the Wasm code does not get output by cargo2nix, and it is a known issue:

https://github.com/cargo2nix/cargo2nix/issues/203

After some debugging (with Alexei and Yorick) it turned out that the solution was simple, and fixed in https://github.com/cargo2nix/cargo2nix/pull/283. Until it gets merged, we run against `github:torhovland/cargo2nix/wasm`.

So, in the end, we build our Wasm code like this:

```
cd variants/cargo2nix-workspace
nix build
ls result/lib/wasm.wasm 
```

## crate2nix

## dream2nix

## naersk

### naersk and separate crates

Having a shared library next to our two apps, using a path dependency, just doesn't work in naersk. See https://github.com/nix-community/naersk/issues/133.

### naersk and a workspace

You can verify that the native Rust app works:

```
cd variants/naersk-workspace
nix build
./result/bin/app
```

And you can verify that the Wasm code also gets built:

```
cd variants/naersk-workspace
nix build .#packages.x86_64-linux.wasm
ls -l ./result/lib/wasm.wasm
```

Interestingly, trying to build both at the same time only leaves the default package (the native app) in the `result` directory:

```
nix build .#packages.x86_64-linux.app .#packages.x86_64-linux.wasm
```

## crane
