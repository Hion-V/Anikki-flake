{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Flutter SDK
    flutter
    
    # Build tools
    dart
    
    # Node.js for Anilist schema generation
    nodejs
    
    # Git for version control
    git
    
    # Additional dependencies for Linux builds
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
    
    # Media playback (required by media_kit_video plugin)
    mpv
    libass
  ];

  shellHook = ''
    echo "🚀 Anikki development environment loaded!"
    echo ""
    echo "Flutter version:"
    flutter --version | head -n 1
    echo ""
    
    # Point to the submodule source
    if [ -d "$PWD/anikki-src" ]; then
      export ANIKKI_SRC="$PWD/anikki-src"
      echo "📁 Anikki source: $ANIKKI_SRC"
    fi
    
    # Add build directory to library path for anitomy
    export LD_LIBRARY_PATH="$PWD/anikki-src/build/linux/x64/debug/bundle/lib:$LD_LIBRARY_PATH"
    
    echo ""
    echo "📝 Quick commands:"
    echo "  cd anikki-src           - Enter the Anikki source directory"
    echo "  flutter pub get         - Install dependencies"
    echo "  flutter run             - Run in debug mode"
    echo "  flutter build linux     - Build release binary"
    echo ""
    echo "💡 After building, the binary is at:"
    echo "  ./anikki-src/build/linux/x64/release/bundle/anikki"
  '';
}
