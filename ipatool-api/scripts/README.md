# Install script samples for IPATOOL_INSTALL_CMD

ipatool-api runs an external command to install the IPA on a USB-connected device. The default is `ideviceinstaller` (macOS/Linux). You can override it with the **IPATOOL_INSTALL_CMD** environment variable.

## Invocation

The server calls your command with one of:

- `install <path>` — install the IPA at `<path>` (first connected device)
- `-u <UDID> install <path>` — install on the device with the given UDID

Your command must accept these arguments and install the IPA (exit 0 on success, non-zero on failure).

## Samples

| File | Platform | Description |
|------|----------|-------------|
| `install-ipa.example.sh` | macOS / Linux | Wraps `ideviceinstaller` (or set `IPATOOL_INSTALL_CMD_REAL` to your binary). |
| `install-ipa.example.ps1` | Windows | Wraps `ideviceinstaller` or your Windows build; use with `powershell -File ...`. |

### macOS / Linux

Use `ideviceinstaller` as-is (default), or a wrapper:

```bash
# Default: no env needed; server uses "ideviceinstaller"

# Or use the sample wrapper (e.g. to pick a custom path):
chmod +x scripts/install-ipa.example.sh
export IPATOOL_INSTALL_CMD=/path/to/ipatool-api/scripts/install-ipa.example.sh
# Optional: use a different backend binary
export IPATOOL_INSTALL_CMD_REAL=/opt/local/bin/ideviceinstaller
./ipaserver -port 8080
```

### Windows

Point **IPATOOL_INSTALL_CMD** to your Windows installer that accepts `install <path>` (and optionally `-u <UDID> install <path>`).

**Option A — Windows build of ideviceinstaller (e.g. libimobiledevice-win32):**

```powershell
$env:IPATOOL_INSTALL_CMD = "C:\path\to\ideviceinstaller.exe"
.\ipaserver.exe -port 8080
```

**Option B — Use the PowerShell sample wrapper:**

1. Edit `install-ipa.example.ps1` and set the path to your Windows `ideviceinstaller` (or set `IPATOOL_INSTALL_CMD_REAL`).
2. Run the server:

```powershell
$env:IPATOOL_INSTALL_CMD = "powershell -ExecutionPolicy Bypass -File C:\path\to\ipatool-api\scripts\install-ipa.example.ps1"
.\ipaserver.exe -port 8080
```

Replace `C:\path\to\...` with your actual paths.
