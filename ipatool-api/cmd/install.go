package cmd

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/majd/ipatool/v2/pkg/appstore"
)

// InstallRequest is the request body for POST /api/v1/install.
// Same as download; device_udid is optional (first connected device if empty).
type InstallRequest struct {
	AppID             int64  `json:"app_id,omitempty"`
	BundleID          string `json:"bundle_id,omitempty"`
	ExternalVersionID string `json:"external_version_id,omitempty"`
	AutoPurchase      bool   `json:"auto_purchase,omitempty"`
	DeviceUDID        string `json:"device_udid,omitempty"`
}

// InstallResponse is the response for the install endpoint.
type InstallResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
}

// getInstallCommand returns the install command (default: ideviceinstaller).
// Override with IPATOOL_INSTALL_CMD environment variable.
func getInstallCommand() string {
	if cmd := os.Getenv("IPATOOL_INSTALL_CMD"); cmd != "" {
		return cmd
	}
	return "ideviceinstaller"
}

func handleInstall(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 15*time.Minute)
	defer cancel()
	r = r.WithContext(ctx)

	var req InstallRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if err := validateAppIDOrBundleID(fmt.Sprintf("%d", req.AppID), req.BundleID); err != nil {
		respondError(w, http.StatusBadRequest, err.Error())
		return
	}

	if err := validateExternalVersionID(req.ExternalVersionID); err != nil {
		respondError(w, http.StatusBadRequest, err.Error())
		return
	}

	accountInfo, ok := getAccountInfo(r)
	if !ok {
		respondError(w, http.StatusUnauthorized, "Authentication required")
		return
	}

	app := buildAppFromRequest(req.AppID, req.BundleID)

	if req.BundleID != "" && app.ID == 0 {
		lookupResult, err := dependencies.AppStore.Lookup(appstore.LookupInput{
			Account:  accountInfo.Account,
			BundleID: req.BundleID,
		})
		if err != nil {
			dependencies.Logger.Error().Err(err).Str("bundleID", req.BundleID).Msg("Lookup failed")
			statusCode, message := mapAppStoreErrorToHTTPStatus(err)
			respondError(w, statusCode, message)
			return
		}
		app = lookupResult.App
	}

	if req.AutoPurchase {
		err := dependencies.AppStore.Purchase(appstore.PurchaseInput{
			Account: accountInfo.Account,
			App:     app,
		})
		if err != nil {
			if !errors.Is(err, appstore.ErrLicenseRequired) {
				dependencies.Logger.Error().Err(err).Msg("AutoPurchase failed")
				statusCode, message := mapAppStoreErrorToHTTPStatus(err)
				respondError(w, statusCode, message)
				return
			}
			dependencies.Logger.Log().Msg("AutoPurchase: License may already be purchased, continuing")
		} else {
			dependencies.Logger.Log().Msg("AutoPurchase: License purchased successfully")
		}
	}

	tmpFile, err := os.CreateTemp("", "ipatool-install-*.ipa")
	if err != nil {
		dependencies.Logger.Error().Err(err).Msg("Failed to create temporary file for install")
		respondError(w, http.StatusInternalServerError, "Failed to create temporary file")
		return
	}
	tmpPath := tmpFile.Name()
	tmpFile.Close()

	defer func() {
		if err := os.Remove(tmpPath); err != nil {
			dependencies.Logger.Error().Err(err).Str("path", tmpPath).Msg("Failed to remove temporary IPA")
		}
	}()

	result, err := dependencies.AppStore.Download(appstore.DownloadInput{
		Account:           accountInfo.Account,
		App:               app,
		ExternalVersionID: req.ExternalVersionID,
		OutputPath:        tmpPath,
	})
	if err != nil {
		dependencies.Logger.Error().Err(err).Msg("Install: download failed")
		statusCode, message := mapAppStoreErrorToHTTPStatus(err)
		respondError(w, statusCode, message)
		return
	}

	ipaPath, err := filepath.Abs(result.DestinationPath)
	if err != nil {
		ipaPath = result.DestinationPath
	}

	if err := runInstallCommand(ipaPath, strings.TrimSpace(req.DeviceUDID)); err != nil {
		dependencies.Logger.Error().Err(err).Str("path", ipaPath).Msg("Install: device install failed")
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Install to device failed: %v", err))
		return
	}

	dependencies.Logger.Log().Str("bundleID", app.BundleID).Str("path", ipaPath).Msg("Install to device succeeded")
	respondSuccess(w, InstallResponse{
		Success: true,
		Message: "Installed successfully",
	})
}

func runInstallCommand(ipaPath string, deviceUDID string) error {
	cmdName := getInstallCommand()
	args := []string{"install", ipaPath}
	if deviceUDID != "" {
		args = append([]string{"-u", deviceUDID}, args...)
	}

	cmd := exec.Command(cmdName, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("%s: %w", cmdName, err)
	}
	return nil
}
