@echo off
cd /d "%~dp0frontend"
echo === 1. Building Next.js (standalone) ===
call npm run build
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo === 2. Creating static export for Capacitor ===
node scripts/static-export.js
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo === 3. Syncing web assets to Android ===
call npx cap sync android
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo === 4. Building APK ===
cd android
call gradlew.bat assembleDebug
if %errorlevel% neq 0 exit /b %errorlevel%

cd ..
copy /Y android\app\build\outputs\apk\debug\app-debug.apk ..\Dentalist.apk >nul

echo.
echo === DONE ===
echo APK created: Dentalist.apk
