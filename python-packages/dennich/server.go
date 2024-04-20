package main

import (
	"encoding/json"
	"io"
	"log"
	"net"
	"sync"
	"time"
)

// RunningPomodoro represents the shared state of the server.
type RunningPomodoro struct {
	mu              sync.Mutex // Protects access to the runningPomodoro
	runningPomodoro *Pomodoro
}

// NewServerState creates a new instance of ServerState.
func NewServerState() *RunningPomodoro {
	return &RunningPomodoro{}
}

// SetRunningPomodoro safely sets the currently running Pomodoro.
func (s *RunningPomodoro) SetRunningPomodoro(p *Pomodoro) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.runningPomodoro = p
}

// GetRunningPomodoro safely retrieves the currently running Pomodoro.
func (s *RunningPomodoro) GetRunningPomodoro() *Pomodoro {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.runningPomodoro
}

func handleConnection(conn net.Conn, running *RunningPomodoro) {
	defer conn.Close()

	var req Request
	decoder := json.NewDecoder(conn)
	if err := decoder.Decode(&req); err != nil {
		if err != io.EOF {
			log.Printf("Error decoding request: %v", err)
		}
		return
	}

	if req.Action == "status" {
		status(conn, running.GetRunningPomodoro())
	} else {
		log.Println("Received unknown action, ignoring.")
	}
}

func status(conn net.Conn, pomodoro *Pomodoro) {
	encoder := json.NewEncoder(conn)

	if pomodoro == nil {
		response := StatusResponse{
			StatusCode: 404,
			TaskName:   "No pomodoro running",
		}
		if err := encoder.Encode(response); err != nil {
			log.Printf("Error encoding response: %v", err)
		}
		return
	}

	elapsedTime := time.Since(pomodoro.StartTime)
	remainingTime := pomodoro.Duration - elapsedTime.Minutes()
	response := StatusResponse{
		StatusCode:    200,
		RemainingTime: remainingTime,
		TaskName:      pomodoro.Todo.Name,
	}

	if err := encoder.Encode(response); err != nil {
		log.Printf("Error encoding response: %v", err)
	}
}
