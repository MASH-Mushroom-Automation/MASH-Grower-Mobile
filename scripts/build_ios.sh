#!/bin/bash

# MASH Grow Mobile - iOS Build Script
# This script builds the iOS app for distribution

set -e

echo "🍄 Building MASH Grow Mobile for iOS..."

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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "iOS builds can only be performed on macOS"
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

# Check iOS deployment target
print_status "Checking iOS deployment target..."
grep -r "IPHONEOS_DEPLOYMENT_TARGET" ios/ || print_warning "iOS deployment target not explicitly set"

# Build for iOS Simulator
print_status "Building for iOS Simulator..."
flutter build ios --simulator

# Build for iOS Device (requires code signing)
print_status "Building for iOS Device..."
flutter build ios --release

# Build IPA for distribution
print_status "Building IPA for distribution..."
flutter build ipa --release

print_success "Build completed successfully!"
print_status "Output files:"
print_status "  - iOS App: build/ios/iphoneos/Runner.app"
print_status "  - IPA: build/ios/ipa/Runner.ipa"

# Optional: Install on connected iOS device
if command -v ios-deploy &> /dev/null; then
    if ios-deploy --detect | grep -q "Found"; then
        print_status "Installing on connected iOS device..."
        ios-deploy --bundle build/ios/iphoneos/Runner.app
        print_success "iOS app installed successfully!"
    else
        print_warning "No iOS device connected. Skipping installation."
    fi
fi

print_success "🍄 MASH Grow Mobile iOS build completed!"
