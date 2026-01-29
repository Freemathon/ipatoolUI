package cmd

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/99designs/keyring"
	cookiejar "github.com/juju/persistent-cookiejar"
	"github.com/majd/ipatool/v2/pkg/appstore"
	"github.com/majd/ipatool/v2/pkg/http"
	"github.com/majd/ipatool/v2/pkg/keychain"
	"github.com/majd/ipatool/v2/pkg/log"
	"github.com/majd/ipatool/v2/pkg/util"
	"github.com/majd/ipatool/v2/pkg/util/machine"
	"github.com/majd/ipatool/v2/pkg/util/operatingsystem"
	"github.com/rs/zerolog"
)

var dependencies = Dependencies{}

// Dependencies holds all the server dependencies.
type Dependencies struct {
	Logger    log.Logger
	OS        operatingsystem.OperatingSystem
	Machine   machine.Machine
	CookieJar http.CookieJar
	Keychain  keychain.Keychain
	AppStore  appstore.AppStore
}

// newLogger creates a new logger instance for server mode.
// Server mode always uses JSON format for structured logging.
func newLogger(verbose bool) log.Logger {
	writer := zerolog.SyncWriter(os.Stdout)
	return log.NewLogger(log.Args{
		Verbose: verbose,
		Writer:  writer,
	})
}

// newCookieJar returns a new cookie jar instance.
func newCookieJar(machine machine.Machine) http.CookieJar {
	return util.Must(cookiejar.New(&cookiejar.Options{
		Filename: filepath.Join(machine.HomeDirectory(), ConfigDirectoryName, CookieJarFileName),
	}))
}

// newKeychain creates a new keychain instance for server mode.
// Server mode is non-interactive, so keychain passphrase must be provided via environment variable
// or the keychain must be unlocked beforehand.
func newKeychain(machine machine.Machine, logger log.Logger) keychain.Keychain {
	// Check for keychain passphrase in environment variable (for server mode)
	keychainPassphrase := os.Getenv("IPATOOL_KEYCHAIN_PASSPHRASE")

	ring := util.Must(keyring.Open(keyring.Config{
		AllowedBackends: []keyring.BackendType{
			keyring.KeychainBackend,
			keyring.SecretServiceBackend,
			keyring.FileBackend,
		},
		ServiceName: KeychainServiceName,
		FileDir:     filepath.Join(machine.HomeDirectory(), ConfigDirectoryName),
		FilePasswordFunc: func(s string) (string, error) {
			// Server mode: use environment variable if available
			if keychainPassphrase != "" {
				return keychainPassphrase, nil
			}

			// If no passphrase provided, try to extract path and provide helpful error
			path := ""
			if parts := strings.Split(s, " unlock "); len(parts) > 1 {
				path = parts[1]
			}

			if path != "" {
				return "", fmt.Errorf("keychain passphrase required for %s (set IPATOOL_KEYCHAIN_PASSPHRASE environment variable)", path)
			}

			return "", errors.New("keychain passphrase required (set IPATOOL_KEYCHAIN_PASSPHRASE environment variable)")
		},
	}))

	return keychain.New(keychain.Args{Keyring: ring})
}

// initServer initializes all dependencies for server mode.
// Server mode uses JSON logging format and non-interactive keychain access.
func initServer(verbose bool) {
	dependencies.Logger = newLogger(verbose)
	dependencies.OS = operatingsystem.New()
	dependencies.Machine = machine.New(machine.Args{OS: dependencies.OS})
	dependencies.CookieJar = newCookieJar(dependencies.Machine)
	dependencies.Keychain = newKeychain(dependencies.Machine, dependencies.Logger)
	dependencies.AppStore = appstore.NewAppStore(appstore.Args{
		CookieJar:       dependencies.CookieJar,
		OperatingSystem: dependencies.OS,
		Keychain:        dependencies.Keychain,
		Machine:         dependencies.Machine,
	})

	util.Must("", createConfigDirectory(dependencies.OS, dependencies.Machine))
}

// createConfigDirectory creates the configuration directory for the server, if needed.
func createConfigDirectory(os operatingsystem.OperatingSystem, machine machine.Machine) error {
	configDirectoryPath := filepath.Join(machine.HomeDirectory(), ConfigDirectoryName)
	_, err := os.Stat(configDirectoryPath)

	if err != nil && os.IsNotExist(err) {
		err = os.MkdirAll(configDirectoryPath, 0700)
		if err != nil {
			return fmt.Errorf("failed to create config directory: %w", err)
		}
	} else if err != nil {
		return fmt.Errorf("could not read metadata: %w", err)
	}

	return nil
}
