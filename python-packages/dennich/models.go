package main

import "time"

type DummyTodo struct {
	TaskName string
}

type DummyPomodoro struct {
	StartTime time.Time
	Duration  float64 // Duration in minutes
	Todo      DummyTodo
}

type Request struct {
	Action string `json:"action"`
}

type StatusResponse struct {
	StatusCode    int     `json:"status_code"`
	RemainingTime float64 `json:"remaining_time"`
	TaskName      string  `json:"task_name"`
}
