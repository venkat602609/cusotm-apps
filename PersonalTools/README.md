# OrbitKit

Native SwiftUI iPhone app scaffold for a personal toolkit.

## Included tools

- Compound interest calculator
- Mortgage calculator
- Fasting tracker with local history stored in `UserDefaults`
- Custom OrbitKit app icon and source logo in `PersonalTools/Assets`

## Device support

- Universal app for iPhone and iPad.
- Minimum supported OS: iOS/iPadOS 16.0.
- iOS 16.0 is the practical floor because the app uses Swift Charts and `NavigationStack`.

## Run on your Mac

1. Open `PersonalTools.xcodeproj` in Xcode.
2. Select an iPhone simulator from the run destination menu.
3. Press `Cmd+R`.

Command-line compile check after Xcode platform/runtime setup:

```sh
xcodebuild -project PersonalTools.xcodeproj -scheme PersonalTools -destination 'generic/platform=iOS' -derivedDataPath ./DerivedData CODE_SIGNING_ALLOWED=NO build
```

The command above verifies compilation without requiring signing. To run the app interactively, use Xcode with an iPhone simulator or a connected iPhone.

If the simulator list fails to load, update macOS/Xcode or reinstall the iOS platform and simulator runtime from `Xcode > Settings > Components`. This environment reported `CoreSimulator is out of date` and later `iOS 26.5 is not installed`, which prevents local asset-catalog compilation and simulator discovery.

## Branding

- Display name: `OrbitKit`
- Bundle identifier placeholder: `com.venkata.Orbit`
- Master logo source: `PersonalTools/Assets/orbit-logo-source.png`
- App icon asset catalog: `PersonalTools/Assets.xcassets/AppIcon.appiconset`

## App Store path

Before submission you will need:

- Apple Developer Program membership.
- A final app name and bundle identifier.
- A real app icon in `Assets.xcassets`.
- Signing team selected in Xcode.
- Privacy nutrition labels in App Store Connect. This first version stores fasting data locally and does not send data to a server.
- Archive from Xcode with `Product > Archive`, then upload through Organizer.
