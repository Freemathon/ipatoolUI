# ipatool-server

A dedicated HTTP API server for downloading IPA files from the App Store. This is a server-only version of ipatool, providing REST API endpoints for remote clients (iOS apps, web UIs, etc.) to interact with the App Store.

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/majd/ipatool/blob/main/LICENSE)

## Features

- **REST API**: Full REST API for App Store interactions
- **Authentication**: Apple ID login, account info, and credential management
- **App Search**: Search the App Store for iOS applications
- **License Purchase**: Purchase app licenses via API
- **Version Management**: List and retrieve metadata for app versions
- **IPA Download**: Download IPA files with streaming support for multi-GB files
- **API Key Authentication**: Optional API key protection for endpoints
- **Structured Logging**: JSON-formatted logs for production environments

## Requirements

- Supported operating system (Windows, Linux, or macOS)
- Go 1.19+ (for building from source)
- Apple ID set up to use the App Store

## Security Features

This server includes comprehensive security measures:

- **CORS Protection**: Configurable allowed origins via `CORS_ALLOWED_ORIGINS` environment variable
- **Rate Limiting**: IP-based rate limiting per endpoint (login: 5/15min, purchase: 20/hour, download: 10/hour)
- **Request Size Limits**: Body size limits per endpoint to prevent memory exhaustion attacks
- **Input Validation**: Strict validation for email, bundle IDs, version IDs with regex patterns
- **Path Traversal Protection**: Filename sanitization to prevent directory traversal attacks
- **Session Timeout**: Automatic session expiration after 24 hours of inactivity
- **API Key Security**: API keys only accepted via headers (not URL parameters)
- **Error Message Sanitization**: Generic error messages in production mode (set `DEBUG=true` for detailed errors)
- **Security Headers**: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection
- **Sensitive Data Masking**: Passwords and API keys are masked in logs

## Installation

### Building from Source

```bash
# Clone the repository
git clone <repository-url>
cd ipatool-server

# Build the server
go build -o ipaserver .

# The binary will be created as `ipaserver`
```

## Usage

### Starting the Server

```bash
# Start server on default port (8080)
./ipaserver

# Start server on custom port
./ipaserver -port 9090

# Start server with API key authentication
./ipaserver -port 8080 -api-key "your-secret-key"
```

### Command Line Options

- `-port`: HTTP server port (default: 8080)
- `-api-key`: API key for authentication (optional, but recommended for production)

### Environment Variables

- `IPATOOL_KEYCHAIN_PASSPHRASE`: Keychain passphrase for non-interactive keychain access (required if keychain is locked)
- `CORS_ALLOWED_ORIGINS`: Comma-separated list of allowed CORS origins (default: all origins allowed for development)
  - Example: `CORS_ALLOWED_ORIGINS=http://localhost:3000,https://example.com`
  - If not set, all origins are allowed (development mode)
- `DEBUG`: Set to `true` to enable detailed error messages (default: `false`)
  - In production, keep this `false` to prevent information leakage
- `IPATOOL_PORT_FILE`: Optional file path to write the actual port number when using random port

### Environment Variables

- `IPATOOL_KEYCHAIN_PASSPHRASE`: Keychain passphrase for non-interactive keychain access (required if keychain is locked)

## API Endpoints

### Authentication

#### `POST /api/v1/auth/login`
Authenticate with Apple ID.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "auth_code": "123456"  // Optional, for 2FA
}
```

**Response:**
```json
{
  "success": true,
  "email": "user@example.com",
  "name": "User Name",
  "country_code": "US"
}
```

#### `GET /api/v1/auth/info`
Get current account information.

**Response:**
```json
{
  "email": "user@example.com",
  "name": "User Name",
  "country_code": "US"
}
```

#### `POST /api/v1/auth/revoke`
Revoke stored authentication credentials.

**Response:**
```json
{
  "success": true
}
```

### App Search

#### `GET /api/v1/search`
Search for apps on the App Store.

**Query Parameters:**
- `term` (required): Search term
- `limit` (optional): Maximum number of results (default: 25)
- `country` (optional): Country code for localized search

**Example:**
```bash
curl "http://localhost:8080/api/v1/search?term=twitter&limit=10&country=US"
```

**Response:**
```json
{
  "count": 10,
  "apps": [
    {
      "track_id": 123456789,
      "bundle_id": "com.example.app",
      "name": "Example App",
      "version": "1.0.0",
      "price": 0.99,
      "artwork_url": "https://..."
    }
  ]
}
```

### License Purchase

#### `POST /api/v1/purchase`
Purchase a license for an app.

**Request Body:**
```json
{
  "bundle_id": "com.example.app"
}
```

**Response:**
```json
{
  "success": true,
  "message": "License purchased successfully"
}
```

### Version Management

#### `GET /api/v1/versions`
List available versions for an app.

**Query Parameters:**
- `app_id` (optional): App ID
- `bundle_id` (optional): Bundle ID (takes precedence over app_id)

**Example:**
```bash
curl "http://localhost:8080/api/v1/versions?bundle_id=com.example.app"
```

**Response:**
```json
{
  "bundle_id": "com.example.app",
  "external_version_identifiers": ["1.0.0", "1.1.0", "2.0.0"],
  "success": true
}
```

#### `GET /api/v1/metadata`
Get metadata for a specific app version.

**Query Parameters:**
- `version_id` (required): External version identifier
- `bundle_id` (optional): Bundle ID
- `app_id` (optional): App ID

**Example:**
```bash
curl "http://localhost:8080/api/v1/metadata?version_id=1.0.0&bundle_id=com.example.app"
```

**Response:**
```json
{
  "success": true,
  "external_version_id": "1.0.0",
  "display_version": "1.0.0",
  "release_date": "2024-01-01T00:00:00Z"
}
```

### IPA Download

#### `POST /api/v1/download`
Download an IPA file. Supports streaming for large files (multi-GB).

**Request Body:**
```json
{
  "app_id": 123456789,              // Optional
  "bundle_id": "com.example.app",  // Optional (takes precedence)
  "external_version_id": "1.0.0",  // Optional (defaults to latest)
  "auto_purchase": true            // Optional (auto-purchase license if needed)
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/download \
  -H "Content-Type: application/json" \
  -d '{
    "bundle_id": "com.example.app",
    "auto_purchase": true
  }' \
  --output app.ipa
```

**Response:** Binary IPA file streamed directly.

### Health Check

#### `GET /health`
Check server status.

**Response:**
```json
{
  "status": "ok",
  "service": "ipatool-api"
}
```

#### `GET /`
Get API information and available endpoints.

**Response:**
```json
{
  "service": "ipatool-api",
  "version": "dev",
  "endpoints": {
    "health": "GET /health",
    "auth_login": "POST /api/v1/auth/login",
    "auth_info": "GET /api/v1/auth/info",
    "auth_revoke": "POST /api/v1/auth/revoke",
    "search": "GET /api/v1/search",
    "purchase": "POST /api/v1/purchase",
    "list_versions": "GET /api/v1/versions",
    "version_metadata": "GET /api/v1/metadata",
    "download": "POST /api/v1/download"
  }
}
```

## API Key Authentication

When API key authentication is enabled, all requests to `/api/v1/*` endpoints must include the API key in the `X-API-Key` header:

```bash
curl -H "X-API-Key: your-secret-key" \
  http://localhost:8080/api/v1/search?term=twitter
```

## CORS Support

The server includes CORS middleware to allow cross-origin requests from web applications.

## Logging

The server uses structured JSON logging, which is ideal for production environments and log aggregation systems. Logs include:

- Request ID for tracing
- HTTP method and path
- Status codes
- Request duration
- Error details

Only critical errors and important operations are logged by default to reduce noise.

## Server Configuration

The server is optimized for large file downloads:

- **Read Timeout**: 30 seconds
- **Write Timeout**: 2 hours (for multi-GB downloads)
- **Idle Timeout**: 300 seconds
- **Max Header Size**: 1MB

## Production Deployment

### Security Recommendations

1. **Use HTTPS**: Always use HTTPS in production. Consider using a reverse proxy (nginx, Caddy, etc.) with SSL/TLS termination.

2. **API Key Authentication**: Always enable API key authentication in production:
   ```bash
   ./ipaserver -port 8080 -api-key "strong-random-secret-key"
   ```

3. **Keychain Passphrase**: Set the keychain passphrase via environment variable:
   ```bash
   export IPATOOL_KEYCHAIN_PASSPHRASE="your-passphrase"
   ./ipaserver -port 8080 -api-key "your-api-key"
   ```

4. **Firewall**: Configure firewall rules to restrict access to the server port.

5. **Process Management**: Use a process manager like systemd, supervisor, or PM2 to manage the server process.

### Example systemd Service

Create `/etc/systemd/system/ipatool-server.service`:

```ini
[Unit]
Description=ipatool HTTP API Server
After=network.target

[Service]
Type=simple
User=ipatool
WorkingDirectory=/opt/ipatool-server
Environment="IPATOOL_KEYCHAIN_PASSPHRASE=your-passphrase"
ExecStart=/opt/ipatool-server/ipaserver -port 8080 -api-key "your-api-key"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Then enable and start the service:

```bash
sudo systemctl enable ipatool-server
sudo systemctl start ipatool-server
```

## Compiling

Build the server using the Go toolchain:

```bash
go build -o ipaserver .
```

Run unit tests:

```bash
go test -v ./...
```

## License

This project is released under the [MIT license](https://github.com/majd/ipatool/blob/main/LICENSE).

## Differences from Original ipatool

This server-only version:

- **Removed CLI functionality**: All command-line commands have been removed
- **Server-only mode**: Runs exclusively as an HTTP API server
- **Simplified initialization**: No interactive prompts, uses environment variables for configuration
- **JSON logging**: Always uses structured JSON logging format
- **Optimized for production**: Designed for deployment in server environments

For CLI functionality, please use the original [ipatool](https://github.com/majd/ipatool) project.
