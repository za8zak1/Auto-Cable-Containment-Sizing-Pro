# Auto Cable Sizing Pro (Flutter)

A Malaysia IEC LV cable sizing assistant - automatic cable recommendation with
ampacity checking, voltage drop (R or R + X mode), protection device
suggestion, and Quick / Detailed design workflows. Built in Flutter for
Android (and portable to iOS/web with no extra work).

> ⚠️ **Engineering data disclaimer**: the bundled cable database
> (`assets/data/cable_database_sample.json`) is a clearly-labelled
> **placeholder dataset**, generated with simple illustrative formulas to
> demonstrate the app's architecture and UI. It is **not** verified against
> IEC 60364-5-52, TNB/Suruhanjaya Tenaga (ST) requirements, or any
> manufacturer's datasheet. Replace it with your own audited engineering
> database before using this app for real design work - see
> [Replacing the cable database](#replacing-the-cable-database) below.

## Features

- **Dashboard** - live database stats, an interactive multi-ring radial chart
  (family / material coverage, tap to inspect), cable-family breakdown,
  design-workflow guide, and engineering tips.
- **Quick Design** - fast load input (kW or known current) with instant
  cable + breaker recommendation.
- **Detailed Design** - full project/load workflow: demand factor, grouping
  and ambient derating, safety factor, R-only or R+X voltage-drop mode,
  material/family filters, and a tap-to-overwrite candidate comparison list.
- **Cable Lookup** - search and filter every record in the database, with
  CCC / R / X and source notes per cable.
- **Compliance Checklist, Database Version, Settings, About, FAQ** - reached
  from the navigation drawer.
- Light/dark theme, persisted with `shared_preferences`.

## Getting started

```bash
flutter pub get

# Regenerate/validate platform folders (android/ios/etc.) against the
# Flutter SDK version installed on your machine - safe to run any time,
# it will not touch lib/ or assets/.
flutter create .

flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

Before publishing, replace the debug signing config in
`android/app/build.gradle` with your own release keystore (see
`android/local.properties.example` and the standard
[Flutter Android signing guide](https://docs.flutter.dev/deployment/android)).


## GitHub-ready package

This source package includes `.github/workflows/flutter_android.yml`. After the
repository is uploaded, GitHub Actions will:

1. restore any standard Android Gradle-wrapper files omitted from the ZIP,
2. validate the bundled JSON database,
3. run `flutter analyze` and `flutter test`,
4. build `app-release.apk`, and
5. publish the APK as a downloadable workflow artifact.

Browser and command-line upload steps are included below. For a local Windows setup, run `tools\bootstrap_flutter.bat`; on macOS/Linux, run `./tools/bootstrap_flutter.sh`.

## Project structure

```
lib/
  models/         # CableRecord, SizingInput, CandidateResult
  data/           # CableDatabase - loads the bundled JSON asset
  services/       # CableSizingService - pure ampacity/VD/breaker logic
  providers/      # ThemeProvider, DatabaseProvider, DesignProvider (ChangeNotifier)
  screens/        # dashboard, quick_design, detailed_design, cable_lookup,
                  # compliance_checklist, database_version, settings, about, faq
  widgets/        # app_drawer, main_shell, circular_gauge, radial_family_chart,
                  # common_widgets, labeled_field
  theme/          # AppColors / AppTheme
assets/data/      # cable_database_sample.json (placeholder - see above)
android/          # standard Flutter Android embedding v2 project
test/             # calculation, database-asset, and widget navigation tests
```

The calculation engine (`lib/services/cable_sizing_service.dart`) has no
Flutter dependency, so it's straightforward to unit test in isolation.

## Replacing the cable database

Swap `assets/data/cable_database_sample.json` for your verified engineering
database, keeping the same shape:

```json
{
  "meta": { "version": "your-version", "disclaimer": "..." },
  "records": [
    {
      "id": "C00001",
      "construction": "1 x 4C",
      "family": "XLPE/PVC",
      "material": "Copper",
      "sizeSqmm": 4,
      "cccAmps": 32,
      "rOhmPerKm": 4.61,
      "xOhmPerKm": 0.086,
      "protectionClass": "MCB",
      "brandGroup": "Your Brand",
      "sourceNote": "Manufacturer datasheet rev X, page Y"
    }
  ]
}
```

See `lib/models/cable_record.dart` (`CableRecord.fromJson`) for the exact
field mapping. If you rename the file, update the `assets:` entry in
`pubspec.yaml` and the default `assetPath` in
`lib/data/cable_database.dart`.

## Publishing to GitHub

### Browser method

1. Create an empty GitHub repository. Do not add a README, license, or `.gitignore` because they already exist in this package.
2. Extract the ZIP on your computer.
3. In the repository, choose **Add file → Upload files**.
4. Upload the **contents inside** `auto_cable_sizing_pro/`, not the outer folder. The repository root must show `pubspec.yaml`, `lib/`, `android/`, `assets/`, and `.github/`.
5. Commit to `main`, then open **Actions → Flutter Android CI**.
6. After the workflow passes, download `auto-cable-sizing-pro-apk` from the run's **Artifacts** section.

Confirm that `.github/workflows/flutter_android.yml` is present. GitHub Actions will not appear without that hidden folder.

### Command-line method

```bash
git init
git add .
git commit -m "Initial commit - Auto Cable Sizing Pro (Flutter)"
git branch -M main
git remote add origin https://github.com/<your-username>/auto-cable-sizing-pro.git
git push -u origin main
```

### Local validation

Windows:

```bat
tools\bootstrap_flutter.bat
```

macOS/Linux:

```bash
./tools/bootstrap_flutter.sh
```

## Design-assist notice

This app is a design-assist tool. It does not replace the judgement of a
competent engineer, TNB/ST submission requirements, or a manufacturer's
current datasheet. Always verify the final cable and protection device
selection before construction issue.

## License

MIT - see `LICENSE`.
