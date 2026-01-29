package cmd

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"

	"github.com/majd/ipatool/v2/pkg/appstore"
)

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message,omitempty"`
	Code    int    `json:"code,omitempty"`
}

func respondJSON(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		dependencies.Logger.Error().Err(err).Msg("Error encoding JSON response")
	}
}

func respondError(w http.ResponseWriter, statusCode int, message string) {
	respondJSON(w, statusCode, ErrorResponse{
		Error:   http.StatusText(statusCode),
		Message: message,
		Code:    statusCode,
	})
}

func respondSuccess(w http.ResponseWriter, data interface{}) {
	respondJSON(w, http.StatusOK, data)
}

// handleAppStoreError handles AppStore errors and responds with appropriate HTTP status
func handleAppStoreError(w http.ResponseWriter, err error) bool {
	if err == nil {
		return false
	}
	statusCode, message := mapAppStoreErrorToHTTPStatus(err)
	respondError(w, statusCode, message)
	return true
}

// mapAppStoreErrorToHTTPStatus maps AppStore errors to HTTP status codes and messages
func mapAppStoreErrorToHTTPStatus(err error) (int, string) {
	errMsg := err.Error()

	var appstoreErr *appstore.Error
	if errors.As(err, &appstoreErr) && appstoreErr.Metadata != nil {
		dependencies.Logger.Error().
			Err(err).
			Interface("metadata", appstoreErr.Metadata).
			Msg("Purchase error with metadata")
	}
	if errors.Is(err, appstore.ErrPasswordTokenExpired) {
		return http.StatusUnauthorized, "Authentication expired. Please login again."
	}
	if errors.Is(err, appstore.ErrLicenseRequired) {
		return http.StatusForbidden, "License is required for this app."
	}
	if errors.Is(err, appstore.ErrSubscriptionRequired) {
		return http.StatusForbidden, "Subscription is required for this app."
	}
	if errors.Is(err, appstore.ErrTemporarilyUnavailable) {
		return http.StatusServiceUnavailable, "Service temporarily unavailable. Please try again later."
	}

	if strings.Contains(errMsg, "password token is expired") || strings.Contains(errMsg, "authentication") {
		return http.StatusUnauthorized, "Authentication required. Please login first."
	}
	if strings.Contains(errMsg, "license is required") || strings.Contains(errMsg, "License is required") {
		return http.StatusForbidden, "License is required for this app."
	}
	if strings.Contains(errMsg, "subscription required") || strings.Contains(errMsg, "Subscription") {
		return http.StatusForbidden, "Subscription is required for this app."
	}
	if strings.Contains(errMsg, "temporarily unavailable") {
		return http.StatusServiceUnavailable, "Service temporarily unavailable."
	}
	if strings.Contains(errMsg, "not found") {
		return http.StatusNotFound, "Resource not found."
	}
	if strings.Contains(errMsg, "license already exists") {
		return http.StatusOK, "License already exists. You can proceed with download."
	}
	if strings.Contains(errMsg, "unknown error") || strings.Contains(errMsg, "something went wrong") {
		dependencies.Logger.Error().Err(err).Msg("Purchase failed with unknown error")
		// Security: Don't expose internal error details in production
		if isDebugMode() {
			return http.StatusInternalServerError, fmt.Sprintf("Purchase failed: %s. Please check the server logs for details.", errMsg)
		}
		return http.StatusInternalServerError, "Purchase failed. Please check the server logs for details."
	}

	// Security: In production mode, use generic error messages
	if !isDebugMode() {
		userFriendly := makeUserFriendlyMessage(errMsg)
		// If we couldn't make it friendly, use a generic message
		if userFriendly == errMsg {
			return http.StatusInternalServerError, "An internal error occurred. Please try again later."
		}
		return http.StatusInternalServerError, userFriendly
	}

	return http.StatusInternalServerError, makeUserFriendlyMessage(errMsg)
}

func makeUserFriendlyMessage(errMsg string) string {
	mappings := map[string]string{
		"password token is expired":   "Your session has expired. Please login again.",
		"license is required":         "You need to purchase this app first.",
		"subscription required":       "A subscription is required for this app.",
		"temporarily unavailable":     "The service is temporarily unavailable. Please try again later.",
		"failed to send http request": "Network error occurred. Please check your connection.",
		"invalid":                     "Invalid request. Please check your input.",
	}

	for key, friendly := range mappings {
		if strings.Contains(strings.ToLower(errMsg), strings.ToLower(key)) {
			return friendly
		}
	}

	return errMsg
}
