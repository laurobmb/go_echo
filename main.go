package main

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		fmt.Fprintf(w, "--- OpenShift NodePort Demo ---\n")
		fmt.Fprintf(w, "Time: %s\n", time.Now().Format(time.RFC1123))
		fmt.Fprintf(w, "Pod Hostname: %s\n", hostname)
		fmt.Fprintf(w, "Remote Addr: %s\n", r.RemoteAddr)
	})

	fmt.Println("Server starting on :8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}