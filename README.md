# OrbitKit

OrbitKit is a native SwiftUI iPhone and iPad app that bundles simple personal tools:

- Compound interest calculator with a visual growth breakdown
- Mortgage calculator with payment and amortization visuals
- Fasting tracker with elapsed-time tracking and milestones

## Project Layout

- `PersonalTools/` - Xcode project and SwiftUI app source
- `PersonalTools/Assets.xcassets/` - app icon and image assets
- `PersonalTools/AppStoreAssets/` - captured App Store screenshot assets
- `PersonalTools/AppStoreAssets/Screenshots/AppStore/` - generated App Store-ready iPhone and iPad screenshot images
- `docs/` - GitHub Pages marketing, support, and privacy pages
- `fastlane/` - App Store Connect metadata automation

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

## App Store Screenshot Images

Generated App Store screenshots are available at:

- iPhone 6.9-inch: `PersonalTools/AppStoreAssets/Screenshots/AppStore/iPhone-6.9/`
- iPad 13-inch: `PersonalTools/AppStoreAssets/Screenshots/AppStore/iPad-13/`

## App Store Connect Metadata Automation

The repo includes a Fastlane lane that uploads App Store listing metadata and screenshots through the App Store Connect API.

Create an App Store Connect API key:

1. Open App Store Connect.
2. Go to **Users and Access**.
3. Open the **Integrations** tab.
4. Create an API key with access to manage apps.
5. Download the `.p8` key file.

Create a local `.env.appstore` file from the example:

```bash
cp .env.appstore.example .env.appstore
```

Fill in:

```text
APP_STORE_CONNECT_KEY_ID=...
APP_STORE_CONNECT_ISSUER_ID=...
APP_STORE_CONNECT_KEY_PATH=/absolute/path/to/AuthKey_....p8
```

Install Fastlane and upload metadata:

```bash
bundle install
set -a
source .env.appstore
set +a
bundle exec fastlane ios upload_appstore_metadata
```

This uploads metadata and screenshots only. It does not submit the app for review.

## Build

Open the Xcode project:

```bash
open PersonalTools/PersonalTools.xcodeproj
```

For App Store submission, select an iOS device destination or `Any iOS Device`, archive from Xcode, then upload the archive to App Store Connect.
