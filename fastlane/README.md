fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Build IPA and upload to App Store Connect

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots to App Store Connect

Upload screenshots and metadata to App Store Connect

----


## Android

### android upload_screenshots

```sh
[bundle exec] fastlane android upload_screenshots
```

Upload screenshots to Google Play Store

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Upload AAB to Google Play Production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
