# OrbitKit

OrbitKit is a native SwiftUI iPhone and iPad app that bundles simple personal tools:

- Compound interest calculator with a visual growth breakdown
- Mortgage calculator with payment and amortization visuals
- Fasting tracker with elapsed-time tracking and milestones

## Project Layout

- `PersonalTools/` - Xcode project and SwiftUI app source
- `PersonalTools/Assets.xcassets/` - app icon and image assets
- `PersonalTools/AppStoreAssets/` - captured App Store screenshot assets
- `docs/` - GitHub Pages marketing, support, and privacy pages

## App Store Metadata

- App name: `OrbitKit`
- Bundle identifier: `com.venkata.Orbit`
- Supported devices: iPhone and iPad
- Minimum OS: iOS/iPadOS 16.0

## GitHub Pages

This repo is ready to serve the OrbitKit public pages from the root `docs/` folder.

Enable it in GitHub:

1. Open the repo settings.
2. Go to **Pages**.
3. Set source to **Deploy from a branch**.
4. Select branch `main`.
5. Select folder `/docs`.
6. Save.

Expected URLs:

- Marketing: `https://venkat602609.github.io/cusotm-apps/`
- Support: `https://venkat602609.github.io/cusotm-apps/support.html`
- Privacy Policy: `https://venkat602609.github.io/cusotm-apps/privacy.html`

## Build

Open the Xcode project:

```bash
open PersonalTools/PersonalTools.xcodeproj
```

For App Store submission, select an iOS device destination or `Any iOS Device`, archive from Xcode, then upload the archive to App Store Connect.
