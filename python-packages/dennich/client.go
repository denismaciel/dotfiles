package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"net"
)

func runClient() {
	// Connect to the server
	conn, err := net.Dial("tcp", "127.0.0.1:12350")
	if err != nil {
		log.Fatalf("Failed to connect to server: %v", err)
	}
	defer conn.Close()

	// Send a "get status" request
	request := Request{Action: "status"}
	if err := json.NewEncoder(conn).Encode(request); err != nil {
		log.Fatalf("Failed to send request: %v", err)
	}

	// Read the response
	response := readResponse(conn)
	if response.StatusCode == 200 {
		fmt.Printf("Pomodoro Status: %s\n", response.TaskName)
		fmt.Printf("Remaining Time: %.2f minutes\n", response.RemainingTime)
	} else {
		fmt.Printf("Failed to get pomodoro status: %s\n", response.TaskName)
	}
}

func readResponse(conn net.Conn) StatusResponse {
	var response StatusResponse
	reader := bufio.NewReader(conn)
	if err := json.NewDecoder(reader).Decode(&response); err != nil {
		log.Fatalf("Failed to read response: %v", err)
	}
	return response
}
