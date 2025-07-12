@echo off
setlocal enabledelayedexpansion

echo.
echo ======================================
echo  INVICTUS TRADER PRO - BUILD SCRIPT
echo ======================================
echo.

:: Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

:: Check if Git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH
    pause
    exit /b 1
)

echo [1/6] Cleaning previous builds...
flutter clean

echo.
echo [2/6] Getting dependencies...
flutter pub get

echo.
echo [3/6] Running analyzer...
flutter analyze
if %errorlevel% neq 0 (
    echo ERROR: Flutter analyzer found issues. Please fix them first.
    pause
    exit /b 1
)

echo.
echo [4/6] Building Android APK...
flutter build apk --release --target-platform android-arm64

echo.
echo [5/6] Building Windows EXE...
flutter config --enable-windows-desktop
flutter build windows --release

echo.
echo [6/6] Creating release package...
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
set TIMESTAMP=%TIMESTAMP: =0%

:: Create release directory
if not exist "releases" mkdir releases
if not exist "releases\%TIMESTAMP%" mkdir "releases\%TIMESTAMP%"

:: Copy APK
copy "build\app\outputs\flutter-apk\app-release.apk" "releases\%TIMESTAMP%\InvictusTraderPro-Android-v%TIMESTAMP%.apk"

:: Copy Windows EXE (zipped)
powershell -Command "Compress-Archive -Path 'build\windows\x64\runner\Release\*' -DestinationPath 'releases\%TIMESTAMP%\InvictusTraderPro-Windows-v%TIMESTAMP%.zip'"

echo.
echo ==========================================
echo  BUILD COMPLETED SUCCESSFULLY!
echo ==========================================
echo.
echo Files created:
echo - releases\%TIMESTAMP%\InvictusTraderPro-Android-v%TIMESTAMP%.apk
echo - releases\%TIMESTAMP%\InvictusTraderPro-Windows-v%TIMESTAMP%.zip
echo.
echo Android APK is ready for:
echo - Android 8.0+ (API 26+)
echo - Optimized for Android 14
echo - ARM64 architecture
echo.
echo Windows EXE is ready for:
echo - Windows 10/11 (64-bit)
echo - Desktop application
echo.

:: Ask if user wants to commit and push
set /p COMMIT="Do you want to commit and push to GitHub? (y/N): "
if /i "%COMMIT%"=="y" (
    echo.
    echo Checking git status...
    git status
    
    set /p MESSAGE="Enter commit message (or press Enter for default): "
    if "!MESSAGE!"=="" set MESSAGE="Build release v%TIMESTAMP%"
    
    git add .
    git commit -m "!MESSAGE!"
    git push origin main
    
    echo.
    echo Changes pushed to GitHub!
    echo GitHub Actions will automatically build and create release.
    echo Check: https://github.com/Rk13termux/BINA-BOT/actions
)

echo.
echo Press any key to exit...
pause >nul
