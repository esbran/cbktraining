# cbktraining

Native iOS (SwiftUI) port of the volleyball training plan app. Targets iOS 17+,
written in Swift 5, no third-party dependencies.

## Project layout

```
cbktraining/
├── cbktraining.xcodeproj/        # Xcode project
├── cbktraining/
│   ├── cbktrainingApp.swift      # App entry point
│   ├── ContentView.swift         # Root view + header, day picker, bottom nav
│   ├── DayDetailView.swift       # Day body: tags, week toggle, sections, tip
│   ├── ExerciseRowView.swift     # Expandable exercise card
│   ├── TrainingData.swift        # Data model + static training plan
│   ├── Theme.swift               # Color palette, fonts, hex Color extension
│   ├── Assets.xcassets/
│   └── Preview Content/
└── README.md
```

## Build from the command line

The project ships with a shared scheme called `cbktraining`, so `xcodebuild`
works without opening Xcode first.

Quick syntax check (compiles every Swift file, no signing):

```bash
xcodebuild \
  -project cbktraining.xcodeproj \
  -scheme cbktraining \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Build and run in the iPhone simulator (replace the destination with whatever
shows up under `xcrun simctl list devices`):

```bash
xcodebuild \
  -project cbktraining.xcodeproj \
  -scheme cbktraining \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

To install and run after building:

```bash
xcrun simctl boot "iPhone 15" || true
open -a Simulator
xcrun simctl install booted \
  "$(xcodebuild -project cbktraining.xcodeproj -scheme cbktraining -configuration Debug -sdk iphonesimulator -showBuildSettings | awk -F' = ' '/^ *BUILT_PRODUCTS_DIR/{print $2; exit}')/cbktraining.app"
xcrun simctl launch booted com.esbran.cbktraining
```

## Open in Xcode

```bash
open cbktraining.xcodeproj
```

Hit ⌘R to build and run.

## TestFlight deployment

The repository includes a GitHub Actions workflow at
`.github/workflows/testflight.yml`. It runs whenever a commit is pushed to
`main`, archives the iOS app, and uploads it to App Store Connect/TestFlight.

Add these repository secrets in GitHub under
`Settings > Secrets and variables > Actions`:

```text
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_API_ISSUER_ID
APP_STORE_CONNECT_API_KEY
```

`APP_STORE_CONNECT_API_KEY` should contain the full contents of the downloaded
`AuthKey_XXXXXXXXXX.p8` file from App Store Connect. The workflow uses the
GitHub Actions run number as the app build number, so each push to `main`
produces a unique TestFlight build.

## Pushing to GitHub

After copying these files into your clone of `esbran/cbktraining`:

```bash
git add .
git commit -m "Initial SwiftUI port of training plan"
git push
```

## Notes on the port

* All `useState` hooks become `@State` properties on `ContentView`.
* The horizontal day-pill scroller uses `ScrollViewReader` to mirror the
  React `scrollIntoView({ inline: "center" })` behavior on selection change.
* Tag wrapping is handled by a small custom `FlowLayout` so tags wrap to
  the next line cleanly on narrow screens.
* Periodization state (strength vs. hypertrophy week) is shared between
  Tuesday and Friday, matching the React behavior.
* Colors are defined as `Color(hex:)` constants in `Theme.swift` so the
  palette matches the source one-to-one. The system accent color in
  `Assets.xcassets` also defaults to the green used in the React design.
