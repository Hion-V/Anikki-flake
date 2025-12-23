# Anikki Nix Flake

This repository contains a Nix flake for building [Anikki](https://github.com/Kylart/Anikki_) - an anime streaming and tracking application built with Flutter.

## Quick Start

### Building

```bash
nix build
```

The built application will be available in `./result/bin/anikki`.

### Running

```bash
./result/bin/anikki
```

Or install to your profile:

```bash
nix profile install .
```

Or run directly without installing:

```bash
nix run
```

## Updating to a Newer Version

When you want to update the flake to build a newer version of Anikki, follow these steps:

### 1. Update the revision in flake.nix

Edit `flake.nix` and change the `rev` field to the desired branch, tag, or commit SHA:

```nix
src = pkgs.fetchFromGitHub {
  owner = "Kylart";
  repo = "Anikki_";
  rev = "dev";  # Change this to a specific commit SHA or tag
  hash = "";    # Clear the hash
};
```

### 2. Get the new hash

Build the flake to get the correct hash:

```bash
nix build 2>&1 | grep "got:"
```

This will fail but output something like:
```
got:    sha256-abc123...
```

### 3. Update the hash in flake.nix

Copy the hash from the error message and update `flake.nix`:

```nix
src = pkgs.fetchFromGitHub {
  owner = "Kylart";
  repo = "Anikki_";
  rev = "your-commit-sha";
  hash = "sha256-abc123...";  # Use the hash from step 2
};
```

### 4. Update pubspec.lock.json

If the Anikki source has updated dependencies, you need to regenerate `pubspec.lock.json`:

```bash
# First, clone the Anikki repository at the new revision
git clone https://github.com/Kylart/Anikki_.git /tmp/anikki-update
cd /tmp/anikki-update
git checkout your-commit-sha

# Get dependencies (this updates pubspec.lock)
nix develop -c flutter pub get

# Generate the JSON file
python3 /path/to/this/repo/generate_pubspec_lock_json.py

# Copy the generated file back to this repository
cp pubspec.lock.json /path/to/this/repo/

# Clean up
cd -
rm -rf /tmp/anikki-update
```

Or if you have the Anikki source checked out elsewhere:

```bash
cd /path/to/anikki/source
git pull
flutter pub get
/path/to/this/repo/generate_pubspec_lock_json.py
cp pubspec.lock.json /path/to/this/repo/
```

### 5. Commit the changes

```bash
git add flake.nix pubspec.lock.json
git commit -m "Update to Anikki version X.Y.Z"
```

### 6. Build and test

```bash
nix build
./result/bin/anikki
```

## Files in This Repository

- **flake.nix**: Main flake definition that fetches source from GitHub and builds the application
- **pubspec.lock.json**: Converted Flutter dependency lock file for deterministic builds
- **generate_pubspec_lock_json.py**: Script to convert `pubspec.lock` (YAML) to `pubspec.lock.json` (JSON)
- **flake.lock**: Nix flake lock file for reproducible builds
- **.gitignore**: Configured to only track flake-related files

## Technical Details

The flake uses `buildFlutterApplication` from nixpkgs and includes:
- Custom RPATH fixes for plugin libraries to avoid forbidden `/build/` references
- Linux desktop build configuration
- All required dependencies (GTK3, GLib, MPV, libass, etc.)
- Desktop entry for application launchers

## Source

This flake fetches the Anikki source from:
- Repository: https://github.com/Kylart/Anikki_
- Default branch: dev

## Development Shell

Enter a development environment with Flutter and all dependencies:

```bash
nix develop
```

This provides:
- Flutter SDK
- All build dependencies
- Development tools (cmake, ninja, clang, etc.)

Then you can work with the Anikki source directly:
```bash
flutter pub get
flutter run
flutter build linux
```
