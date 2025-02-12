# Rust Flake Template
Simple Nix Flake template for Rust using [Crate2Nix](https://github.com/nix-community/crate2nix).

### Features
- Builds crate dependanices individualy with [Crate2Nix](https://github.com/nix-community/crate2nix) so they can be reused between builds.
- Uploads built crates to a binary cache server during CI/CD if provided.
- Local builds will pull crates from the cache server meaning the same crate doesn't need to built more than once.
- Dev shell with everything needed to build using Cargo.
- Wraps program with any desired system dependencies so its avaialable at runtime.

### Usage

Running without cloning.
```bash
nix run github:justryanw/rust-flake-template
```

Build with Nix.
```bash
# Clone and cd into repo
nix develop -c nom build # Nice build output ( can be skipped )
nix run
```

or enter dev environment and build using Cargo.
```bash
nix develop -c $SHELL # Use direnv to do this automatically
cargo run
```

### Issues / Limitations

- Not tested on MacOS.
