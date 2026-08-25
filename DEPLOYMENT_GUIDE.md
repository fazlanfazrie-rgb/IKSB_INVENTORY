# STOREPH3 v1.0 - Deployment Guide

## 🎯 Overview
**STOREPH3** is a stable, offline-first inventory stabilization application built with Flutter. It supports both Android and Windows platforms with local SQLite database storage for daily use without internet connectivity.

**Build Status:** ✅ **SUCCESS**  
**Build Date:** August 25, 2026  
**Version:** v1.0.0

---

## 📦 Artifacts

### Available Downloads
1. **STOREPH3.apk** (51.84 MB)
   - Android release build
   - Target: Android 6.0+
   - Can be installed directly on Android devices

2. **STOREPH3-Windows-x64.zip** (12.36 MB)
   - Windows x64 executable + Flutter runtime
   - Target: Windows 10 x64 or later
   - Contains all required DLLs and resources

---

## 📱 Android Deployment

### Installation
1. **Transfer APK to Device**
   - Copy `STOREPH3.apk` to your Android device
   - Or use: `adb install STOREPH3.apk` (Android Debug Bridge)

2. **Grant Permissions**
   - When first launched, grant storage permissions
   - Required for: database access, offline storage

3. **Initial Setup**
   - App creates SQLite database on first run
   - Auto-loads 85 Item Master records
   - Loads 1,104 valid transaction rows from migration
   - No network required

### System Requirements
- Android 6.0 (API 23) or higher
- 100 MB free storage (for app + database)
- No internet required (fully offline-first)

### Features Enabled
✓ Item master inventory  
✓ Transaction ledger (opening, receive, issue)  
✓ Stock take & physical counts  
✓ Audit logging  
✓ Local SQLite database  
✓ Balance calculations (ledger-first)  

---

## 🖥️ Windows Deployment

### Installation
1. **Extract Package**
   - Unzip `STOREPH3-Windows-x64.zip`
   - Creates folder: `STOREPH3-Windows-x64/`

2. **Launch Application**
   - Double-click `storeph3.exe`
   - Or run from PowerShell: `.\storeph3.exe`

3. **Initial Setup**
   - App creates SQLite database on first run
   - Auto-loads 85 Item Master records
   - Loads 1,104 valid transaction rows from migration
   - No network required

### System Requirements
- Windows 10 x64 or Windows 11
- 200 MB free disk space
- No Visual C++ runtime needed (bundled)
- No internet required (fully offline-first)

### Included Files
- `storeph3.exe` - Main executable
- `flutter_windows.dll` - Flutter runtime
- `app.so` and other Flutter libraries
- `data/` - Flutter assets and resources

---

## 🗄️ Database Schema

### Tables
- **items** - Item master records (85 records)
- **transactions** - Movement ledger (1,104 rows)
- **stock_take** - Physical count records
- **audit_log** - Action audit trail
- **users** - User management (System user included)
- **app_settings** - Application configuration

### Key Constraints
- ✓ Stock levels cannot be negative
- ✓ Receive and issue are mutually exclusive per transaction
- ✓ Issue quantities cannot exceed current system balance
- ✓ All transactions audit-logged with timestamp & user

---

## 📊 Migration Data

### Source: STOREPH3 FINAL LOCKED
- **85 Item Master records** - Fully loaded
- **1,154 legacy rows processed**
  - 1,104 valid rows loaded
  - 50 blank rows skipped
  - Negative historical exceptions preserved as audit trail
- **New constraints enforced**
  - Issue transactions rejected if exceeding balance
  - Ledger-first calculation ensures accuracy

---

## 🚀 Usage Examples

### Android (via ADB)
```bash
# Install
adb install STOREPH3.apk

# Launch
adb shell am start -n com.example.storeph3/com.example.storeph3.MainActivity
```

### Windows
```powershell
# Extract
Expand-Archive STOREPH3-Windows-x64.zip -DestinationPath C:\Apps\

# Run
C:\Apps\STOREPH3-Windows-x64\storeph3.exe

# Optional: Create shortcut
New-Item -ItemType SymbolicLink -Path "C:\Users\$env:USERNAME\Desktop\STOREPH3.lnk" `
  -Target "C:\Apps\STOREPH3-Windows-x64\storeph3.exe"
```

---

## 🔒 Security & Offline-First

### Data Protection
- ✓ SQLite database local to device
- ✓ No cloud sync dependencies
- ✓ No authentication server required
- ✓ All data remains on-device

### Offline Capability
- ✓ Fully functional without internet
- ✓ All transaction processing local
- ✓ Audit logs stored locally
- ✓ System balance calculations real-time

---

## 📋 Build Information

### Build Pipeline
- **CI/CD:** GitHub Actions
- **Workflow:** STOREPH3 Release
- **Platforms:** Android (ubuntu-latest) + Windows (windows-latest)
- **Flutter Channel:** Stable (3.47.1)

### Workflow Steps
1. ✅ Checkout source code
2. ✅ Setup build tools (Java 17, Flutter)
3. ✅ Generate platform files
4. ✅ Fetch Pub dependencies
5. ✅ Build release APK (Android)
6. ✅ Build release EXE (Windows)
7. ✅ Verify packages
8. ✅ Upload artifacts

### Repository
```
Owner: fazlanfazrie-rgb
Repo: IKSB_INVENTORY
Branch: fazlanfazrie-rgb-storeph3-flutter-build
Tag: v1.0.0
```

---

## 📞 Support

### Common Issues

**Android: "Unknown sources" error**
- Enable "Install unknown apps" in Settings > Apps & notifications > Special app access

**Windows: Application won't start**
- Extract ZIP to a local folder (not USB)
- Right-click `storeph3.exe` > Properties > Compatibility > Run as Administrator (if needed)

**Database errors**
- Delete `storeph3.db` to reset database
- App will auto-recreate on next launch
- All historical data will be reloaded from migration

---

## ✨ Features Checklist

- [x] Offline-first architecture
- [x] SQLite local database
- [x] 85 Item Master records
- [x] 1,104 transaction records
- [x] Balance calculations
- [x] Stock take support
- [x] Audit logging
- [x] Android APK build
- [x] Windows x64 build
- [x] Production-ready stabilization
- [x] Daily use deployment
- [x] Zero-dependency runtime

---

**Version:** 1.0.0  
**Status:** ✅ Production Ready  
**Last Updated:** August 25, 2026
