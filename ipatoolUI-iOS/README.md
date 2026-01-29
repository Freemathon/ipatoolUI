# ipatoolUI-iOS

A native iOS application for downloading IPA files from the App Store using the `ipatool-server` API. Built with SwiftUI and following Apple's Human Interface Guidelines (HIG) with modern iOS 17+ design patterns.

## Features

### Core Functionality
- **Authentication**: Sign in with Apple ID, fetch account information, and manage authentication credentials
- **App Search**: Search the App Store for iOS applications by name, bundle ID, or app ID
- **License Purchase**: Purchase app licenses directly from the App Store
- **Version Management**: Browse and list all available versions of an app
- **Version Metadata**: Retrieve detailed metadata for specific app versions
- **IPA Download**: Download IPA files with real-time progress tracking and support for multi-GB files
- **File Management**: Share downloaded IPA files and delete them when no longer needed
- **Activity Logs**: View operation logs and track app activities

### User Experience
- **Multi-language Support**: Full localization in Japanese, English, and Simplified Chinese
- **Currency Display**: Automatic currency formatting based on locale with manual override option
- **Long-press Actions**: Copy bundle IDs and version strings with long-press gestures
- **Direct Download**: Download specific app versions directly from the version list
- **Optimized Downloads**: High-performance download engine optimized for large files and slow networks
- **Modern UI**: Native SwiftUI interface with tab-based navigation

## Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **ipatool-server**: Must be running and accessible (see Setup section)

## Setup

### 1. Start ipatool-server

First, you need to start the `ipatool-server` on your machine or server:

```bash
# Basic server (no API key)
ipatool server --port 8080

# Server with API key authentication
ipatool server --port 8080 --api-key "your-secret-key"
```

For production use, it's recommended to:
- Use HTTPS instead of HTTP
- Configure proper firewall rules
- Use API key authentication
- Run the server on a dedicated machine or cloud instance

### 2. Configure the iOS App

1. Open the app on your iOS device
2. Navigate to the **Settings** tab
3. Enter the server URL in **API Base URL**:
   - Local network: `http://192.168.x.x:8080` (replace with your server's IP)
   - Localhost (simulator only): `http://localhost:8080` or `http://127.0.0.1:8080`
   - Remote server: `https://your-server.com:8080`
4. If your server uses API key authentication, enter it in the **API Key** field

### 3. Network Configuration

For local network access, ensure:
- Your iOS device and server are on the same network
- The server's firewall allows connections on the specified port
- The app has been granted local network permissions (prompted on first launch)

## Usage Guide

### Authentication

1. Open the **Authentication** tab
2. Enter your Apple ID email address and password
3. If two-factor authentication is enabled, enter the verification code when prompted
4. Tap **Sign In** to authenticate
5. Use **Account Info** to view your current authentication status
6. Use **Delete Auth** to revoke stored credentials

### Searching for Apps

1. Navigate to the **Search** tab
2. Enter a search term (app name, bundle ID, or app ID)
3. Optionally select a country code for localized search results
4. Tap the search button or press return
5. Browse results with app icons, names, prices, and bundle IDs
6. Long-press on a bundle ID to copy it to the clipboard

### Purchasing Licenses

1. Go to the **Purchase** tab
2. Enter the app ID or bundle ID of the app you want to purchase
3. Optionally specify an external version ID
4. Tap **Purchase** to buy the license
5. The app must be available for purchase in your region

### Viewing App Versions

1. Open the **Versions** tab
2. Enter an app ID or bundle ID
3. Tap **List Versions** to retrieve all available versions
4. Long-press on any version string to:
   - Copy the version to clipboard
   - Download that specific version directly

### Downloading IPA Files

1. Navigate to the **Download** tab
2. Enter the app ID or bundle ID
3. Optionally specify an external version ID
4. Enable **Auto Purchase** if you want to automatically purchase the license if needed
5. Tap **Download** to start the download
6. Monitor progress with the real-time progress indicator
7. Once complete, use **Share File** to share the IPA or **Delete File** to remove it

### Viewing Version Metadata

1. Open the **Version Metadata** tab
2. Enter the app ID or bundle ID
3. Enter the external version ID
4. Tap **Fetch Metadata** to retrieve detailed version information

### Settings

The **Settings** tab allows you to:
- Configure server URL and API key
- Select app language (Japanese, English, Chinese, or Auto)
- Choose currency display locale (for price formatting)
- View app information

## Project Structure

```
ipatoolUI-iOS/
├── Services/
│   ├── APIService.swift              # REST API client for ipatool-server
│   ├── AppLookupService.swift        # iTunes API lookup service
│   └── FileManagerService.swift      # File system operations
├── Models/
│   ├── AppState.swift                # Application state management
│   ├── APIResponseModels.swift       # API response data models
│   ├── Localization.swift            # Multi-language support
│   ├── CountryCode.swift             # Country code and currency mapping
│   └── CurrencyFormatter.swift       # Currency formatting utilities
├── ViewModels/
│   ├── BaseViewModel.swift           # Base class for all ViewModels
│   ├── AuthViewModel.swift           # Authentication logic
│   ├── SearchViewModel.swift         # App search functionality
│   ├── PurchaseViewModel.swift       # License purchase logic
│   ├── DownloadViewModel.swift       # Download management
│   ├── ListVersionsViewModel.swift   # Version listing
│   └── VersionMetadataViewModel.swift # Metadata retrieval
├── Views/
│   ├── MainView.swift                # Main tab view
│   ├── AuthView.swift                # Authentication screen
│   ├── SearchView.swift              # Search interface
│   ├── PurchaseView.swift            # Purchase screen
│   ├── DownloadView.swift           # Download interface
│   ├── ListVersionsView.swift       # Version list
│   ├── VersionMetadataView.swift    # Metadata display
│   ├── SettingsView.swift           # Settings screen
│   ├── LogsView.swift               # Activity logs
│   └── AboutView.swift              # About screen
├── Utilities/
│   ├── ValidationHelpers.swift      # Input validation utilities
│   ├── FilenameHelper.swift         # Filename generation and sanitization
│   ├── DateFormatterHelper.swift    # Date formatting utilities
│   └── AsyncSemaphore.swift         # Async concurrency control
└── ipatoolUI_iOSApp.swift           # App entry point
```

## Technical Details

### Architecture
- **MVVM Pattern**: Clear separation between Views, ViewModels, and Models
- **Combine Framework**: Reactive programming for state management
- **Async/Await**: Modern Swift concurrency for network operations
- **MainActor**: Thread-safe UI updates

### Download Optimization
The app is optimized for downloading large files (multi-GB):
- **Streaming Downloads**: Files are streamed directly to disk, not loaded into memory
- **Large Buffers**: 4MB buffers for efficient network utilization
- **Extended Timeouts**: 2-hour timeout for resource requests
- **Progress Tracking**: Real-time byte-level progress updates
- **Connection Reuse**: HTTP keep-alive for stable connections

### Localization
- **Supported Languages**: Japanese, English, Simplified Chinese
- **Dynamic Switching**: Change language without app restart
- **Auto-detection**: Automatically uses system language if available
- **Currency Formatting**: Locale-aware price display with manual override

### Network Configuration
- **Local Network Access**: Configured for local server connections
- **HTTP Support**: Allows insecure HTTP for local development
- **HTTPS Support**: Full support for secure connections
- **Bonjour Services**: Local network discovery support

## Troubleshooting

### Connection Issues
- **"Connection refused"**: Ensure `ipatool-server` is running and accessible
- **"Local network prohibited"**: Grant local network permissions when prompted
- **Timeout errors**: Check network connectivity and server status
- **403 errors**: Verify API key if authentication is enabled

### Download Problems
- **Slow downloads**: Normal for large files; progress indicator shows status
- **Download fails**: Check server logs for errors, verify app is available for download
- **Memory issues**: The app streams to disk, so memory usage should be minimal

### Authentication Errors
- **Invalid credentials**: Verify Apple ID and password
- **2FA required**: Enter verification code when prompted
- **Purchase failures**: Ensure the app is available in your region and account has sufficient funds

### Localization Issues
- **Language not changing**: Restart the app after changing language in settings
- **Currency not updating**: Change the currency locale in settings

## Development

### Building the Project
1. Open `ipatoolUI-iOS.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘R)

### Dependencies
- No external dependencies (uses only Apple frameworks)
- Requires `ipatool-server` to be running separately

### Code Organization
- **Services**: Business logic and API interactions
- **ViewModels**: Presentation logic and state management
- **Views**: SwiftUI user interface components
- **Models**: Data structures and business models
- **Utilities**: Reusable helper functions and extensions

## Security Considerations

- **API Keys**: Store securely in app preferences (not in code)
- **Credentials**: Apple ID credentials are sent to `ipatool-server`, not stored locally
- **Network**: Use HTTPS in production environments
- **Local Network**: Only connect to trusted servers on local networks

## License

This project follows the same license as the Mac version of ipatoolUI.

## Contributing

Contributions are welcome! Please ensure:
- Code follows Swift style guidelines
- UI adheres to Apple's Human Interface Guidelines
- All new features include appropriate error handling
- Localization strings are added for all supported languages

## Support

For issues related to:
- **ipatool-server**: See the `ipatool-server` documentation
- **iOS App**: Open an issue in this repository
- **API Compatibility**: Ensure server and client versions are compatible

---

**Note**: This app requires `ipatool-server` to be running and accessible. It does not function as a standalone application.
