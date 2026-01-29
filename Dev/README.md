# Dev – Install feature

This folder holds copies of the main project with the **IPA install** feature implemented (server installs IPA to a USB-connected device).

## Contents

| Folder | Purpose |
|--------|---------|
| **ipatool-api/** | API server with `POST /api/v1/install`. Downloads IPA and runs `ideviceinstaller -i <path>` (or `IPATOOL_INSTALL_CMD`) on the server machine. |
| **ipatoolUI-iOS/** | iOS app with an **Install** tab: App ID/Bundle ID, optional version, optional device UDID, Auto Purchase; calls install API. |

## Implemented

### ipatool-api
- **cmd/install.go**: `InstallRequest` (same as download + optional `device_udid`), `handleInstall`, `runInstallCommand(ipaPath, deviceUDID)`. Uses `ideviceinstaller -i <path>` (override with `IPATOOL_INSTALL_CMD`).
- **cmd/server.go**: Registered `POST /api/v1/install`, added to root endpoint list.

### ipatoolUI-iOS
- **APIService**: `install(bundleID:appID:externalVersionID:autoPurchase:deviceUDID:)` → `InstallResponse`.
- **InstallViewModel**: Inputs + `install()` calling API.
- **InstallView**: Form with note, App ID/Bundle ID/Version/UDID, Auto Purchase, “Install to Device” button.
- **AppState**: `Feature.install`, `installViewModel`; **MainView**: Install tab.
- **Localization**: `installToDevice`, `installDeviceNote`, `installedSuccessfully`, `note`.

## How to test

1. On a **Mac** (or machine with libimobiledevice): install `ideviceinstaller` (e.g. `brew install ideviceinstaller`).
2. Connect **iPhone via USB** to that Mac.
3. **Rebuild and start** the server (404 on `/api/v1/install` means the running binary is old):
   ```bash
   cd Dev/ipatool-api
   go build -o ipaserver .
   ./ipaserver -port 8080
   ```
   If you use an API key: `./ipaserver -port 8080 -api-key "your-key"`.
4. In the iOS app (Dev/ipatoolUI-iOS), set API Base URL to that machine (e.g. `http://192.168.x.x:8080`), sign in, then use the **Install** tab: enter Bundle ID (or App ID), tap **Install to Device**. The server will download the IPA and install it on the connected device.

## Constraint

The device must be **connected via USB** to the machine running ipatool-api. The server needs `ideviceinstaller` (or the binary set in `IPATOOL_INSTALL_CMD`) on that machine.
