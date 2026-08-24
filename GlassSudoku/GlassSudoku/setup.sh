#!/bin/bash
# GlassSudoku – One-command Xcode project setup
# Run this ONCE from the GlassSudoku folder on your Mac.
# It installs XcodeGen (if needed) and generates a clean .xcodeproj

set -e
cd "$(dirname "$0")"

echo "🔧 GlassSudoku Project Setup"
echo "──────────────────────────────"

# 1. Install XcodeGen via Homebrew if not present
if ! command -v xcodegen &> /dev/null; then
  echo "📦 Installing XcodeGen..."
  if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Install it first: https://brew.sh"
    exit 1
  fi
  brew install xcodegen
fi

echo "✅ XcodeGen found: $(xcodegen --version)"

# 2. Remove any broken .xcodeproj
rm -rf GlassSudoku.xcodeproj
echo "🗑  Removed old .xcodeproj (if any)"

# 3. Generate fresh project
xcodegen generate
echo ""
echo "✅ GlassSudoku.xcodeproj generated successfully!"
echo ""
echo "👉 Open with:"
echo "   open GlassSudoku.xcodeproj"
