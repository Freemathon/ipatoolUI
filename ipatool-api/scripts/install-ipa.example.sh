#!/usr/bin/env bash
# Sample wrapper for IPATOOL_INSTALL_CMD (macOS/Linux).
# Usage: ipatool-api calls this as:
#   install-ipa.example.sh install /path/to/app.ipa
#   install-ipa.example.sh -u <UDID> install /path/to/app.ipa
#
# Set in environment:
#   export IPATOOL_INSTALL_CMD=/path/to/install-ipa.example.sh
# Or use ideviceinstaller directly:
#   export IPATOOL_INSTALL_CMD=ideviceinstaller

set -e
INSTALLER="${IPATOOL_INSTALL_CMD_REAL:-ideviceinstaller}"
exec "$INSTALLER" "$@"
