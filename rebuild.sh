#!/usr/bin/env bash

# NixOS + Home Manager unified rebuild script
# This script rebuilds both system and user configurations atomically

set -euo pipefail

FLAKE_DIR="/etc/nixos-config"
UPDATE_FLAKE=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-update)
            UPDATE_FLAKE=false
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--no-update]"
            echo "  --no-update    Skip updating flake inputs"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🔨 Rebuilding NixOS system and home-manager configurations..."
echo "Using flake: $FLAKE_DIR"

# Check if flake directory exists
if [[ ! -d "$FLAKE_DIR" ]]; then
    echo "❌ Error: Flake directory $FLAKE_DIR not found"
    exit 1
fi

# Check if we're in the right directory or change to it
if [[ "$(pwd)" != "$FLAKE_DIR" ]]; then
    echo "📁 Changing to flake directory..."
    cd "$FLAKE_DIR"
fi

# Update flake lock file if requested
if [[ "$UPDATE_FLAKE" == true ]]; then
    echo "🔄 Updating flake inputs..."
    nix flake update
else
    echo "⏭️ Skipping flake update (--no-update flag provided)"
fi

# Perform the rebuild
echo "🚀 Running nixos-rebuild switch..."
sudo nixos-rebuild switch --flake "$FLAKE_DIR"

if [[ $? -eq 0 ]]; then
    echo "✅ Rebuild completed successfully!"
    echo "🏠 Both system and home-manager configurations are now active."
else
    echo "❌ Rebuild failed!"
    exit 1
fi