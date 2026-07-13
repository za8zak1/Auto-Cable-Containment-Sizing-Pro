# Upload this Flutter project to GitHub

## Browser method

1. Create an empty GitHub repository. Do not add a README, license, or `.gitignore` because they already exist here.
2. Open the new repository and choose **Add file → Upload files**.
3. Extract the supplied ZIP on your computer.
4. Upload the **contents inside** `auto_cable_sizing_pro/`, not the outer folder itself. The repository root must show `pubspec.yaml`, `lib/`, `android/`, `assets/`, and `.github/`.
5. Commit the files to the `main` branch.
6. Open **Actions → Flutter Android CI**. The workflow validates the database, analyzes the source, runs tests, and builds the release APK.
7. Open the completed workflow run and download the `auto-cable-sizing-pro-apk` artifact.

GitHub's web uploader might not show hidden folders clearly on some devices. Confirm that `.github/workflows/flutter_android.yml` was uploaded; without it, the **Actions** build will not appear.

## Command-line method

```bash
git init
git add .
git commit -m "Initial Flutter source"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
git push -u origin main
```

## Local validation

Windows:

```bat
tools\bootstrap_flutter.bat
```

macOS/Linux:

```bash
./tools/bootstrap_flutter.sh
```

The bootstrap regenerates omitted standard Android wrapper files, validates the JSON database, installs packages, runs analysis, and runs tests.
