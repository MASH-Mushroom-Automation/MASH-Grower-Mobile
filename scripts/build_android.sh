#!/bin/bash

# M.A.S.H. Grower Mobile - Android Build Script
# This script builds the Android APK and AAB for distribution

set -e

echo "🍄 Building M.A.S.H. Grower Mobile for Android..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Using $FLUTTER_VERSION"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Run tests
print_status "Running tests..."
flutter test

# Analyze code
print_status "Analyzing code..."
flutter analyze

# Build debug APK
print_status "Building debug APK..."
flutter build apk --debug --target-platform android-arm64

# Build release APK
print_status "Building release APK..."
flutter build apk --release --target-platform android-arm64

# Build App Bundle (AAB) for Play Store
print_status "Building App Bundle (AAB)..."
flutter build appbundle --release

# Build for multiple architectures
print_status "Building universal APK..."
flutter build apk --release --split-per-abi

print_success "Build completed successfully!"
print_status "Output files:"
print_status "  - Debug APK: build/app/outputs/flutter-apk/app-debug.apk"
print_status "  - Release APK: build/app/outputs/flutter-apk/app-release.apk"
print_status "  - App Bundle: build/app/outputs/bundle/release/app-release.aab"
print_status "  - Split APKs: build/app/outputs/flutter-apk/app-*-release.apk"

# Optional: Install debug APK on connected device
if command -v adb &> /dev/null; then
    if adb devices | grep -q "device$"; then
        print_status "Installing debug APK on connected device..."
        adb install build/app/outputs/flutter-apk/app-debug.apk
        print_success "Debug APK installed successfully!"
    else
        print_warning "No Android device connected. Skipping installation."
    fi
fi

print_success "🍄 M.A.S.H. Grower Mobile Android build completed!"
