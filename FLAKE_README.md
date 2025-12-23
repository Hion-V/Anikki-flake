# Anikki Nix Flake

This repository contains a Nix flake for building [Anikki](https://github.com/Kylart/Anikki_) - an anime streaming and tracking application built with Flutter.

## Building

```bash
nix build
```

The built application will be available in `./result/bin/anikki`.

## Running

```bash
./result/bin/anikki
```

Or install to your profile:

```bash
nix profile install .
```

## What's Included

- **flake.nix**: Main flake definition that fetches source from GitHub
- **pubspec.lock.json**: Converted Flutter dependency lock file for deterministic builds
- **flake.lock**: Nix flake lock file for reproducible builds

## Source

This flake fetches the Anikki source from:
- Repository: https://github.com/Kylart/Anikki_
- Branch: dev

## Technical Details

The flake uses `buildFlutterApplication` from nixpkgs and includes:
- Custom RPATH fixes for plugin libraries
- Linux desktop build configuration
- All required dependencies (GTK3, GLib, MPV, etc.)
