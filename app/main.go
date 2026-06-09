// Minimal sample service for the book. Exposes the endpoints the Helm chart's
// probes and ServiceMonitor expect: /health (liveness, startup), /ready
// (readiness), and /metrics (Prometheus). Replace with your real application.
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "ok")
	})
	mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "ready")
	})
	mux.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "# HELP orders_api_up 1 if the service is up")
		fmt.Fprintln(w, "# TYPE orders_api_up gauge")
		fmt.Fprintln(w, "orders_api_up 1")
	})
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "orders-api")
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("orders-api listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}
