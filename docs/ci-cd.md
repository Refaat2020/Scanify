# CI/CD

This project uses GitHub Actions for CI/CD and fastlane for release automation.

## Why GitHub Actions

- The repository is already GitHub-compatible and does not need a separate CI vendor.
- Flutter Android builds can run on Linux runners.
- Flutter iOS build validation can run on macOS runners without checking signing credentials into the repository.
- fastlane gives us reusable local and CI release lanes for artifacts, Google Play, and TestFlight.

## Workflows

### CI

File: `.github/workflows/ci.yml`

Runs on pull requests, pushes to `main`, and manual dispatch.

Checks:

- Pinned Flutter SDK: `3.38.7`
- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze --fatal-infos`
- `flutter test --coverage`
- Android debug APK build
- Android release AAB build
- iOS release build without codesigning

Artifacts:

- Test coverage: `coverage/lcov.info`
- Android CI build artifacts

### Release Artifacts

File: `.github/workflows/release.yml`

Runs on tags matching `v*` and manual dispatch.

Builds:

- Android release app bundle
- Android release APKs split per ABI
- iOS release app bundle packaged as a no-codesign ZIP

The workflow publishes artifacts to a GitHub Release.

Release builds are driven by fastlane:

- Android artifacts: `bundle exec fastlane android build_release_artifacts`
- iOS unsigned artifact: `bundle exec fastlane ios build_unsigned`

Important: if Android signing secrets are not present, release artifact builds still fall back to debug signing for validation. Google Play upload requires production signing secrets.

## Production Store Deployment

fastlane lanes are already scaffolded:

- Google Play internal track: `bundle exec fastlane android upload_play_internal`
- TestFlight: `bundle exec fastlane ios upload_testflight`

Minimum secret set for Android production signing:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

Minimum secret set for iOS production deployment:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `APPLE_TEAM_ID`

## Dependency Updates

File: `.github/dependabot.yml`

Dependabot is configured for:

- GitHub Actions
- Dart and Flutter packages
- Android Gradle dependencies
