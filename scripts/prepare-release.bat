@echo off
REM BINA-BOT Release Preparation Script for Windows
REM This script prepares everything needed for a release

echo 🚀 BINA-BOT Release Preparation
echo =================================

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ❌ Error: pubspec.yaml not found. Please run this script from the project root.
    exit /b 1
)

REM Get current version
for /f "tokens=2" %%a in ('findstr "version:" pubspec.yaml') do set CURRENT_VERSION=%%a
echo 📋 Current version: %CURRENT_VERSION%

REM Ask for new version
set /p NEW_VERSION="🔢 Enter new version (e.g., 1.0.1+2): "

if "%NEW_VERSION%"=="" (
    echo ❌ Error: Version cannot be empty
    exit /b 1
)

echo 📝 Updating version to %NEW_VERSION%...

REM Update pubspec.yaml
powershell -Command "(Get-Content pubspec.yaml) -replace 'version: %CURRENT_VERSION%', 'version: %NEW_VERSION%' | Set-Content pubspec.yaml"

REM Clean and get dependencies
echo 🧹 Cleaning project...
flutter clean

echo 📦 Getting dependencies...
flutter pub get

REM Run tests
echo 🧪 Running tests...
flutter test

REM Analyze code
echo 🔍 Analyzing code...
flutter analyze

echo ✅ Pre-release checks completed!
echo.
echo 📋 Next steps:
echo 1. Review and commit your changes
echo 2. Create and push a git tag: git tag v%NEW_VERSION% ^&^& git push origin v%NEW_VERSION%
echo 3. GitHub Actions will automatically build and create a release
echo.
echo Git commands:
echo git add .
echo git commit -m "chore: bump version to %NEW_VERSION%"
echo git tag v%NEW_VERSION%
echo git push origin main
echo git push origin v%NEW_VERSION%

pause
