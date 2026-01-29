package cmd

import (
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

// Security configuration
var (
	// CORS allowed origins (comma-separated, empty means all origins for development)
	corsAllowedOrigins = getEnvOrDefault("CORS_ALLOWED_ORIGINS", "")
	// Debug mode (set to "true" to show detailed error messages)
	debugMode = getEnvOrDefault("DEBUG", "false") == "true"
	// Session timeout in hours
	sessionTimeoutHours = 24
)

// Rate limiter
type rateLimiter struct {
	requests map[string][]time.Time
	mu       sync.Mutex
	// Rate limit configuration per endpoint
	limits map[string]rateLimitConfig
}

type rateLimitConfig struct {
	maxRequests int
	window      time.Duration
}

var globalRateLimiter = &rateLimiter{
	requests: make(map[string][]time.Time),
	limits: map[string]rateLimitConfig{
		"/api/v1/auth/login": {
			maxRequests: 5, // 5 attempts per window
			window:      15 * time.Minute,
		},
		"/api/v1/purchase": {
			maxRequests: 20, // 20 purchases per window
			window:      1 * time.Hour,
		},
		"/api/v1/download": {
			maxRequests: 10, // 10 downloads per window
			window:      1 * time.Hour,
		},
		"default": {
			maxRequests: 100, // 100 requests per window
			window:      1 * time.Minute,
		},
	},
}

func (rl *rateLimiter) isAllowed(ip, path string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	// Get rate limit config for this endpoint
	config := rl.limits["default"]
	for endpoint, limitConfig := range rl.limits {
		if strings.HasPrefix(path, endpoint) {
			config = limitConfig
			break
		}
	}

	now := time.Now()
	key := ip + ":" + path

	// Clean old requests outside the window
	requests := rl.requests[key]
	validRequests := []time.Time{}
	for _, reqTime := range requests {
		if now.Sub(reqTime) < config.window {
			validRequests = append(validRequests, reqTime)
		}
	}

	// Check if limit exceeded
	if len(validRequests) >= config.maxRequests {
		return false
	}

	// Add current request
	validRequests = append(validRequests, now)
	rl.requests[key] = validRequests

	return true
}

func (rl *rateLimiter) cleanup() {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	for key, requests := range rl.requests {
		validRequests := []time.Time{}
		for _, reqTime := range requests {
			// Keep requests from last hour
			if now.Sub(reqTime) < time.Hour {
				validRequests = append(validRequests, reqTime)
			}
		}
		if len(validRequests) == 0 {
			delete(rl.requests, key)
		} else {
			rl.requests[key] = validRequests
		}
	}
}

// Start rate limiter cleanup goroutine
func init() {
	go func() {
		ticker := time.NewTicker(5 * time.Minute)
		defer ticker.Stop()
		for range ticker.C {
			globalRateLimiter.cleanup()
		}
	}()
}

// getClientIP extracts the client IP address from the request
func getClientIP(r *http.Request) string {
	// Check X-Forwarded-For header (for proxies)
	forwarded := r.Header.Get("X-Forwarded-For")
	if forwarded != "" {
		ips := strings.Split(forwarded, ",")
		if len(ips) > 0 {
			return strings.TrimSpace(ips[0])
		}
	}

	// Check X-Real-IP header
	realIP := r.Header.Get("X-Real-IP")
	if realIP != "" {
		return realIP
	}

	// Fall back to RemoteAddr
	ip := r.RemoteAddr
	if idx := strings.LastIndex(ip, ":"); idx != -1 {
		ip = ip[:idx]
	}
	return ip
}

// sanitizeFilename removes dangerous characters from filename
func sanitizeFilename(filename string) string {
	// Remove path separators and dangerous characters
	dangerous := []string{"../", "..\\", "/", "\\", "\"", "'", "<", ">", "|", ":", "?", "*", "\x00"}
	safe := filename
	for _, char := range dangerous {
		safe = strings.ReplaceAll(safe, char, "")
	}

	// Limit length
	maxLen := 255
	if len(safe) > maxLen {
		safe = safe[:maxLen]
	}

	// Remove leading/trailing dots and spaces
	safe = strings.Trim(safe, ". ")

	// Ensure it's not empty
	if safe == "" {
		safe = "download.ipa"
	}

	return safe
}

// maskSensitiveData masks sensitive information in strings
func maskSensitiveData(s string) string {
	// Mask passwords
	if strings.Contains(strings.ToLower(s), "password") {
		// Simple pattern matching for JSON-like structures
		s = maskJSONField(s, "password")
		s = maskJSONField(s, "auth_code")
	}

	// Mask API keys
	if strings.Contains(strings.ToLower(s), "api") && strings.Contains(strings.ToLower(s), "key") {
		s = maskJSONField(s, "api_key")
		s = maskJSONField(s, "X-API-Key")
	}

	return s
}

// maskJSONField masks a JSON field value
func maskJSONField(s, fieldName string) string {
	// This is a simplified version - in production, use regexp
	if strings.Contains(s, `"`+fieldName+`"`) {
		// Find and replace the value
		start := strings.Index(s, `"`+fieldName+`"`)
		if start != -1 {
			// Find the value part
			valueStart := strings.Index(s[start:], ":")
			if valueStart != -1 {
				valueStart += start
				// Find the end of the value
				valueEnd := valueStart + 1
				for valueEnd < len(s) && s[valueEnd] != ',' && s[valueEnd] != '}' && s[valueEnd] != ']' && s[valueEnd] != '\n' {
					valueEnd++
				}
				// Replace with masked value
				masked := s[:valueStart+1] + ` "***"` + s[valueEnd:]
				s = masked
			}
		}
	}

	return s
}

// getEnvOrDefault gets an environment variable or returns a default value
func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// isDebugMode returns whether debug mode is enabled
func isDebugMode() bool {
	return debugMode
}
