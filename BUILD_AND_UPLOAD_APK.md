# Build APK and Upload to Google Drive - Quick Guide

This guide will help you build your Flutter app APK and upload it to Google Drive for sharing.

## Step 1: Build the APK

### Option A: Using Flutter Command (Recommended)

Open PowerShell or Command Prompt in the project directory and run:

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Option B: Using the Build Script (Linux/Mac/Git Bash)

If you have Git Bash or WSL on Windows:

```bash
chmod +x scripts/build_android.sh
./scripts/build_android.sh
```

## Step 2: Locate Your APK

After building, your APK file will be at:
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`

## Step 3: Upload to Google Drive

### Method 1: Manual Upload (Easiest)

1. **Open Google Drive** in your web browser: https://drive.google.com
2. **Sign in** to your Google account
3. **Click "New"** button (top left)
4. **Select "File upload"**
5. **Navigate to** your project folder:
   ```
   C:\Users\admin\Downloads\MASH-Grower-Mobile-1\build\app\outputs\flutter-apk\
   ```
6. **Select** `app-release.apk`
7. **Wait** for upload to complete
8. **Right-click** on the uploaded file → **Get link** or **Share**
9. **Set sharing permissions**:
   - Click "Change" next to sharing settings
   - Choose "Anyone with the link" if you want to share publicly
   - Or "Specific people" to share with specific email addresses
10. **Copy the link** and share it!

### Method 2: Using Google Drive Desktop App

1. **Install Google Drive for Desktop** (if not already installed)
   - Download from: https://www.google.com/drive/download/
2. **Copy the APK** to your Google Drive folder on your computer
3. The file will **automatically sync** to Google Drive
4. **Right-click** the file in Google Drive → **Get link** to share

### Method 3: Drag and Drop

1. **Open Google Drive** in your browser
2. **Open File Explorer** and navigate to:
   ```
   C:\Users\admin\Downloads\MASH-Grower-Mobile-1\build\app\outputs\flutter-apk\
   ```
3. **Drag** `app-release.apk` into the Google Drive browser window
4. **Wait** for upload
5. **Share** the file as needed

## Step 4: Share the APK

### Sharing Options:

1. **Get Shareable Link**:
   - Right-click the APK in Google Drive
   - Click "Get link"
   - Copy the link
   - Send the link to others

2. **Share with Specific People**:
   - Right-click the APK
   - Click "Share"
   - Enter email addresses
   - Set permissions (Viewer/Editor)
   - Click "Send"

3. **Download Instructions for Recipients**:
   - Recipients click the shared link
   - They'll see a preview page
   - Click the **download icon** (⬇️) or **"Download"** button
   - The APK will download to their device
   - They can install it on Android devices

## Important Notes

### For Recipients Installing the APK:

1. **Enable Unknown Sources**:
   - Go to Settings → Security
   - Enable "Install from Unknown Sources" or "Allow from this source"

2. **Install the APK**:
   - Open the downloaded APK file
   - Tap "Install"
   - Follow the prompts

### APK File Size:

- The APK might be large (50-100MB+)
- Make sure you have enough Google Drive storage
- Recipients need good internet connection to download

### Security:

- Only share APKs with trusted people
- Consider using Google Drive's "Anyone with the link" option for easy sharing
- You can set expiration dates for shared links in Google Drive

## Quick Command Reference

```bash
# Build APK
flutter build apk --release

# Build APK for specific architecture (smaller file)
flutter build apk --release --target-platform android-arm64

# Build split APKs (one per architecture)
flutter build apk --release --split-per-abi

# Check APK location
dir build\app\outputs\flutter-apk\app-release.apk
```

## Troubleshooting

### Build Fails:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### Can't Find APK:
- Check: `build/app/outputs/flutter-apk/`
- The file should be named `app-release.apk`

### Upload Too Slow:
- Compress the APK first (zip it)
- Or use Google Drive Desktop app for better sync

### Recipients Can't Install:
- Make sure they enabled "Unknown Sources"
- Check if their Android version is compatible (minSdkVersion in build.gradle)

---

**Need Help?** Check the main [DEPLOYMENT.md](DEPLOYMENT.md) file for more detailed deployment information.



