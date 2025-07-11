#!/bin/bash

# BINA-BOT Release Preparation Script
# This script prepares everything needed for a release

set -e

echo "🚀 BINA-BOT Release Preparation"
echo "================================="

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | cut -d ' ' -f2)
echo "📋 Current version: $CURRENT_VERSION"

# Ask for new version
read -p "🔢 Enter new version (e.g., 1.0.1+2): " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo "❌ Error: Version cannot be empty"
    exit 1
fi

echo "📝 Updating version to $NEW_VERSION..."

# Update pubspec.yaml
sed -i.bak "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml

# Clean and get dependencies
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

echo "✅ Pre-release checks completed!"
echo ""
echo "📋 Next steps:"
echo "1. Review and commit your changes"
echo "2. Create and push a git tag: git tag v$NEW_VERSION && git push origin v$NEW_VERSION"
echo "3. GitHub Actions will automatically build and create a release"
echo ""
echo "Git commands:"
echo "git add ."
echo "git commit -m 'chore: bump version to $NEW_VERSION'"
echo "git tag v$NEW_VERSION"
echo "git push origin main"
echo "git push origin v$NEW_VERSION"
