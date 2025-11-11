# MASH Grow Mobile - Android APK Build Script for Windows
# This script builds the Android APK for distribution

Write-Host "Building MASH Grow Mobile for Android..." -ForegroundColor Cyan

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "[INFO] Using $flutterVersion" -ForegroundColor Blue
} catch {
    Write-Host "[ERROR] Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Clean previous builds
Write-Host "[INFO] Cleaning previous builds..." -ForegroundColor Blue
flutter clean

# Get dependencies
Write-Host "[INFO] Getting dependencies..." -ForegroundColor Blue
flutter pub get

# Build release APK
Write-Host "[INFO] Building release APK..." -ForegroundColor Blue
flutter build apk --release

# Check if build was successful
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $fileSize = (Get-Item $apkPath).Length / 1MB
    Write-Host "[SUCCESS] Build completed successfully!" -ForegroundColor Green
    Write-Host "[INFO] APK Location: $apkPath" -ForegroundColor Blue
    Write-Host "[INFO] APK Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Open Google Drive: https://drive.google.com" -ForegroundColor White
    Write-Host "2. Upload the APK from: $((Get-Location).Path)\$apkPath" -ForegroundColor White
    Write-Host "3. Right-click the file → Get link → Share" -ForegroundColor White
    Write-Host ""
    Write-Host " MASH Grow Mobile Android build completed!" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Build failed. APK not found at expected location." -ForegroundColor Red
    exit 1
}



