#!/usr/bin/env python3
"""
Generate pubspec.lock.json from pubspec.lock for Nix Flutter builds.

This script converts Flutter's pubspec.lock YAML file to JSON format,
ensuring the 'sdks' section is included for buildFlutterApplication.
"""

import yaml
import json
import sys
from pathlib import Path


def generate_pubspec_lock_json(input_file="pubspec.lock", output_file="pubspec.lock.json"):
    """Convert pubspec.lock YAML to JSON with sdks section."""
    
    input_path = Path(input_file)
    output_path = Path(output_file)
    
    if not input_path.exists():
        print(f"Error: {input_file} not found", file=sys.stderr)
        sys.exit(1)
    
    print(f"Reading {input_file}...")
    with open(input_path, 'r') as f:
        lock_data = yaml.safe_load(f)
    
    # Ensure sdks section exists
    if 'sdks' not in lock_data:
        print("Warning: 'sdks' section not found in pubspec.lock", file=sys.stderr)
        print("You may need to run 'flutter pub get' first", file=sys.stderr)
        sys.exit(1)
    
    print(f"Converting to JSON format...")
    print(f"Found {len(lock_data.get('packages', {}))} packages")
    print(f"SDK constraints: {lock_data.get('sdks', {})}")
    
    print(f"Writing to {output_file}...")
    with open(output_path, 'w') as f:
        json.dump(lock_data, f, indent=2)
    
    print(f"✓ Successfully generated {output_file}")


if __name__ == "__main__":
    if len(sys.argv) > 2:
        generate_pubspec_lock_json(sys.argv[1], sys.argv[2])
    elif len(sys.argv) > 1:
        generate_pubspec_lock_json(sys.argv[1])
    else:
        generate_pubspec_lock_json()
