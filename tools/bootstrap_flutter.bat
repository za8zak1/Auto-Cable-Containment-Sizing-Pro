@echo off
setlocal
cd /d "%~dp0\.."

if not exist android\gradlew.bat (
  flutter create --platforms=android --project-name auto_cable_sizing_pro --org com.aizahid .
)

python tools\validate_database.py || exit /b 1
flutter pub get || exit /b 1
flutter analyze --no-fatal-infos --no-fatal-warnings || exit /b 1
flutter test || exit /b 1

echo Flutter project bootstrap and validation completed.
endlocal
