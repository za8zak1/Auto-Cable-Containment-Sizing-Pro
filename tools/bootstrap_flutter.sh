#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f android/gradlew || ! -f android/gradle/wrapper/gradle-wrapper.jar ]]; then
  flutter create --platforms=android --project-name auto_cable_sizing_pro --org com.aizahid .
fi

python3 tools/validate_database.py
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test

echo "Flutter project bootstrap and validation completed."
