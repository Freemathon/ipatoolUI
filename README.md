# ipatoolUI

A native iOS application for downloading IPA files from the App Store, along with its dedicated HTTP API server.

> **Note**: This is a personal tool project. Use at your own discretion.

## Project Overview

This repository contains two main components:

1. **`ipatool-api/`** - HTTP API server for App Store interactions (Go)
2. **`ipatoolUI-iOS/`** - Native iOS client application (SwiftUI)

### Component Relationship

```
┌─────────────────┐         HTTP API          ┌──────────────┐
│ ipatoolUI-iOS   │ ──────────────────────────> │ ipatool-api  │
│  (iOS Client)   │ <────────────────────────── │  (Server)    │
└─────────────────┘                             └──────────────┘
                                                         │
                                                         │ App Store API
                                                         ▼
                                                 ┌──────────────┐
                                                 │  App Store   │
                                                 └──────────────┘
```

**Important**: `ipatool-api` and `ipatoolUI-iOS` are designed to work together. The iOS app requires a running `ipatool-api` server instance to function.

## Quick Start

### For iOS Users

1. **Start the API server**:
   ```bash
   cd ipatool-api
   go build -o ipaserver .
   ./ipaserver -port 8080
   ```
   Optionally use API key authentication: `./ipaserver -port 8080 -api-key "your-secret-key"`  
   On some systems you may need to set `IPATOOL_KEYCHAIN_PASSPHRASE` for non-interactive keychain access.

2. **Build and run the iOS app**:
   - Open `ipatoolUI-iOS/ipatoolUI-iOS.xcodeproj` in Xcode
   - Configure the API base URL in Settings (default: `http://localhost:8080`)
   - Build and run on iOS 17+ device or simulator

See [`ipatoolUI-iOS/README.md`](ipatoolUI-iOS/README.md) for detailed iOS setup instructions.

## Component Details

### ipatool-api

A server-only HTTP API for App Store interactions. Provides REST endpoints for authentication, search, purchase, version management, and IPA downloads.

- **Language**: Go
- **Requirements**: Go 1.19+ (1.23 recommended), Apple ID
- **Documentation**: [`ipatool-api/README.md`](ipatool-api/README.md)

**Key Features**:
- REST API for remote clients
- Streaming downloads for multi-GB files
- Optional API key authentication
- Structured JSON logging
- Automatic port selection

### ipatoolUI-iOS

Native iOS application built with SwiftUI. Connects to `ipatool-api` server to provide a full-featured App Store client.

- **Language**: Swift
- **Requirements**: iOS 17.0+, Xcode 15.0+
- **Documentation**: [`ipatoolUI-iOS/README.md`](ipatoolUI-iOS/README.md)

**Key Features**:
- Multi-language support (Japanese, English, Chinese)
- Currency formatting with locale selection
- Long-press actions for copying bundle IDs and versions
- Optimized downloads for large files
- Modern iOS 17+ UI design

## Architecture

### Server-Client Architecture

The iOS app (`ipatoolUI-iOS`) communicates with the API server (`ipatool-api`) via HTTP REST API:

- **Authentication**: `/api/v1/auth/*`
- **Search**: `/api/v1/search`
- **Purchase**: `/api/v1/purchase`
- **Versions**: `/api/v1/versions`
- **Version Metadata**: `/api/v1/metadata`
- **Download**: `/api/v1/download`

The server handles all App Store interactions and provides a clean API interface for clients.

### Network Configuration

For local development:
- **iOS Simulator**: Use `http://localhost:8080`
- **Physical Device**: Use `http://<server-ip>:8080` (e.g., `http://192.168.1.100:8080`)

The iOS app includes App Transport Security (ATS) configuration to allow local network connections.

## Development

### Building from Source

**API Server**:
```bash
cd ipatool-api
go build -o ipaserver .
```

**iOS App**:
```bash
cd ipatoolUI-iOS
open ipatoolUI-iOS.xcodeproj
# Build in Xcode
```

### Project Structure

```
ipatoolUI/
├── ipatool-api/          # Go HTTP API server
│   ├── main.go           # Entry point
│   ├── cmd/              # Server handlers & middleware
│   ├── pkg/              # Core packages
│   └── README.md         # Server documentation
├── ipatoolUI-iOS/        # iOS SwiftUI client
│   ├── ipatoolUI-iOS/    # Source code
│   └── README.md         # iOS documentation
└── README.md             # This file
```

## License

MIT License - See [`ipatool-api/LICENSE`](ipatool-api/LICENSE) for details.

## Disclaimer

This is a personal tool project. Use at your own risk. The tools interact with Apple's App Store and may be subject to Apple's Terms of Service.
