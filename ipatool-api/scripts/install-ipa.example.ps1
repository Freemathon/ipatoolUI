# Sample wrapper for IPATOOL_INSTALL_CMD (Windows).
# ipatool-api calls this as:
#   install-ipa.example.ps1 install C:\path\to\app.ipa
#   install-ipa.example.ps1 -u <UDID> install C:\path\to\app.ipa
#
# Set in environment (PowerShell):
#   $env:IPATOOL_INSTALL_CMD = "powershell -ExecutionPolicy Bypass -File C:\path\to\install-ipa.example.ps1"
#
# Or point to your Windows ideviceinstaller (e.g. from libimobiledevice-win32):
#   $env:IPATOOL_INSTALL_CMD = "C:\path\to\ideviceinstaller.exe"

$installer = if ($env:IPATOOL_INSTALL_CMD_REAL) { $env:IPATOOL_INSTALL_CMD_REAL } else { "ideviceinstaller" }
& $installer $args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
