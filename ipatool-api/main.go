package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/majd/ipatool/v2/cmd"
)

func main() {
	var (
		port   = flag.Int("port", 8080, "HTTP server port")
		apiKey = flag.String("api-key", "", "API key for authentication (optional)")
	)
	flag.Parse()

	if err := cmd.RunServer(*port, *apiKey); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
