{
  description = "Anikki - Anime streaming and tracking application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        anikki = pkgs.flutter.buildFlutterApplication rec {
          pname = "anikki";
          version = "0.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "Hion-V";
            repo = "Anikki_";
            rev = "dev";
            hash = "sha256-n0IIn/99eKmzYXeGQgg2lKdu9j9QhrhNeopOCyGusEA=";
          };

          # Read the pubspec.lock.json file for deterministic dependency resolution
          pubspecLock = builtins.fromJSON (builtins.readFile ./pubspec.lock.json);

          # Don't use the default CMake configure step - we'll handle build ourselves
          dontUseCmakeConfigure = true;

          nativeBuildInputs = with pkgs; [
            pkg-config
            cmake
            ninja
            clang
            makeWrapper
          ];

          buildInputs = with pkgs; [
            gtk3
            glib
            pcre
            pcre2
            util-linux
            libselinux
            libsepol
            libthai
            libdatrie
            libepoxy
            xorg.libXdmcp
            xorg.libXtst
            xorg.libX11
            libxkbcommon
            dbus
            at-spi2-core
            libsecret
            jsoncpp
            mpv
            libass
          ];

          preConfigure = ''
            export HOME=$TMPDIR
            
            # Copy .env
            if [ -f .env.example ]; then
              cp .env.example .env
            else
              touch .env
            fi
            
            # Disable analytics
            flutter config --no-analytics 2>/dev/null || true
          '';

          buildPhase = ''
            runHook preBuild
            flutter build linux --release
            
            # Fix RPATHs immediately after build, before Nix's automatic fixup
            echo "Cleaning RPATHs in plugin libraries..."
            for lib in build/linux/x64/release/bundle/lib/*.so; do
              if [ -f "$lib" ]; then
                echo "Fixing: $lib"
                ${pkgs.patchelf}/bin/patchelf --remove-rpath "$lib" 2>/dev/null || true
                ${pkgs.patchelf}/bin/patchelf --set-rpath "${pkgs.lib.makeLibraryPath buildInputs}" "$lib" 2>/dev/null || true
              fi
            done
            
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            
            mkdir -p $out/bin
            mkdir -p $out/share/anikki
            
            # Copy the entire Flutter bundle
            cp -r build/linux/x64/release/bundle/* $out/share/anikki/
            
            # Ensure the executable has executable permissions
            chmod +x $out/share/anikki/anikki
            
            # Create debug output directory (required by buildFlutterApplication)
            mkdir -p $debug
            
            runHook postInstall
          '';

          postInstall = ''
            # Create wrapper with proper library paths including mpv
            # Wrap the actual executable in the share directory
            wrapProgram $out/share/anikki/anikki \
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
            
            # Create a symlink in bin that points to the wrapped executable
            ln -s $out/share/anikki/anikki $out/bin/anikki
            
            # Install desktop entry
            mkdir -p $out/share/applications
            cat > $out/share/applications/anikki.desktop <<EOF
[Desktop Entry]
Name=Anikki
Comment=Anime streaming and tracking application
Exec=$out/bin/anikki
Terminal=false
Type=Application
Categories=AudioVideo;Video;Player;
EOF
          '';

          meta = with pkgs.lib; {
            description = "Anime streaming and tracking application with AniList/MAL support";
            homepage = "https://github.com/Kylart/Anikki";
            license = licenses.mit;
            platforms = platforms.linux;
            mainProgram = "anikki";
          };
        };

      in {
        packages = {
          default = anikki;
          anikki = anikki;
        };

        apps = {
          default = {
            type = "app";
            program = "${anikki}/bin/anikki";
          };
        };        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            nodejs
            git
            pkg-config
            cmake
            ninja
            clang
            gtk3
            glib
            pcre
            pcre2
            util-linux
            libselinux
            libsepol
            libthai
            libdatrie
            libepoxy
            xorg.libXdmcp
            xorg.libXtst
            xorg.libX11
            libxkbcommon
            dbus
            at-spi2-core
            libsecret
            jsoncpp
            mpv
          ];

          shellHook = ''
            echo "🚀 Anikki development environment loaded!"
            echo ""
            echo "Flutter version:"
            flutter --version | head -n 1
            echo ""
            
            # Add build directory to library path for anitomy
            export LD_LIBRARY_PATH="$PWD/build/linux/x64/debug/bundle/lib:$LD_LIBRARY_PATH"
            
            echo "📝 Quick commands:"
            echo "  flutter pub get         - Install dependencies"
            echo "  flutter run             - Run in debug mode"
            echo "  flutter build linux     - Build release binary"
            echo ""
            echo "💡 After building, the binary is at:"
            echo "  ./build/linux/x64/release/bundle/anikki"
          '';
        };
      }
    );
}
