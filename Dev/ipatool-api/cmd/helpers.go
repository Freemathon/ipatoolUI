package cmd

import (
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/majd/ipatool/v2/pkg/appstore"
)

func getAccountInfo(r *http.Request) (appstore.AccountInfoOutput, bool) {
	accountInfo, ok := r.Context().Value("accountInfo").(appstore.AccountInfoOutput)
	return accountInfo, ok
}

func generateRequestID() string {
	return fmt.Sprintf("%d-%d", time.Now().UnixNano(), rand.Int63())
}

func buildAppFromRequest(appID int64, bundleID string) appstore.App {
	if appID != 0 {
		return appstore.App{ID: appID}
	}
	return appstore.App{BundleID: bundleID}
}

func generateFilename(app appstore.App, versionID string) string {
	var filename string
	if app.BundleID != "" {
		// Security: Sanitize bundle ID to prevent path traversal
		safeBundleID := strings.ReplaceAll(app.BundleID, ".", "-")
		// Remove any remaining dangerous characters
		safeBundleID = sanitizeFilename(safeBundleID)
		// Remove .ipa extension if somehow present
		safeBundleID = strings.TrimSuffix(safeBundleID, ".ipa")
		filename = fmt.Sprintf("%s.ipa", safeBundleID)
	} else {
		filename = fmt.Sprintf("app-%d.ipa", app.ID)
	}

	if versionID != "" {
		// Security: Sanitize version ID
		safeVersionID := sanitizeFilename(versionID)
		if idx := strings.LastIndex(filename, ".ipa"); idx != -1 {
			filename = filename[:idx] + "-" + safeVersionID + ".ipa"
		}
	}

	// Final sanitization
	filename = sanitizeFilename(filename)
	if !strings.HasSuffix(filename, ".ipa") {
		filename += ".ipa"
	}

	return filename
}

func setDownloadHeaders(w http.ResponseWriter, filename string, fileSize int64) {
	// Security: Sanitize filename and escape for HTTP header
	safeFilename := sanitizeFilename(filename)
	// Remove quotes to prevent header injection
	safeFilename = strings.ReplaceAll(safeFilename, "\"", "")
	safeFilename = strings.ReplaceAll(safeFilename, "'", "")
	// RFC 5987 encoding for filename with special characters
	encodedFilename := fmt.Sprintf("attachment; filename=\"%s\"; filename*=UTF-8''%s", safeFilename, safeFilename)

	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Disposition", encodedFilename)
	w.Header().Set("Content-Length", fmt.Sprintf("%d", fileSize))
	w.Header().Set("Content-Encoding", "identity")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
	w.Header().Set("Pragma", "no-cache")
	w.Header().Set("Expires", "0")
}
