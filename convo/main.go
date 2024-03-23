package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"
)

func main() {
	// reader := bufio.NewReader(strings.NewReader(testResponse))
	reader, closer, err := callClaude()
	defer closer()
	if err != nil {
		fmt.Println("Error calling Claude:", err)
		return
	}
	processResponse(reader)
}

const testResponse = `event: message_start
data: {"type": "message_start", "message": {"id": "msg_1nZdL29xx5MUA1yADyHTEsnR8uuvGzszyY", "type": "message", "role": "assistant", "content": [], "model": "claude-3-opus-20240229", "stop_reason": null, "stop_sequence": null, "usage": {"input_tokens": 25, "output_tokens": 1}}}

event: content_block_start
data: {"type": "content_block_start", "index": 0, "content_block": {"type": "text", "text": ""}}

event: ping
data: {"type": "ping"}

event: content_block_delta
data: {"type": "content_block_delta", "index": 0, "delta": {"type": "text_delta", "text": "Hello my name is Claude! \nI am a language model trained by Anthropic. \nI can help you with programming questions. \nWhat would you like to know today?"}}

event: content_block_delta
data: {"type": "content_block_delta", "index": 0, "delta": {"type": "text_delta", "text": "!"}}

event: content_block_stop
data: {"type": "content_block_stop", "index": 0}

event: message_delta
data: {"type": "message_delta", "delta": {"stop_reason": "end_turn", "stop_sequence":null, "usage":{"output_tokens": 15}}}

event: message_stop
data: {"type": "message_stop"}`

type Event string

const (
	EventContentBlockDelta Event = "content_block_delta"
	EventContentBlockStart Event = "content_block_start"
	EventContentBlockStop  Event = "content_block_stop"
	EventMessageStart      Event = "message_start"
	EventMessageStop       Event = "message_stop"
	EventPing              Event = "ping"
)

type ContentBlockDelta struct {
	Type  string `json:"type"`
	Index int    `json:"index"`
	Delta struct {
		Type string `json:"type"`
		Text string `json:"text"`
	} `json:"delta"`
}

func callClaude() (*bufio.Reader,
	// function to close the reader right the type for me: func(*bufio.Reader) error
	func() error,
	error) {

	// Set up the request payload
	payload := map[string]interface{}{
		"model":      "claude-3-opus-20240229",
		"max_tokens": 1024,
		"messages": []map[string]string{
			{"role": "user", "content": "Write a fibonnaci sequence generator in Rust"},
		},
		"stream": true, // Enable streaming
	}

	// Convert the payload to JSON
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return nil, nil, err
	}

	// Create a new HTTP request
	req, err := http.NewRequest(
		"POST",
		"https://api.anthropic.com/v1/messages",
		bytes.NewBuffer(jsonPayload),
	)
	if err != nil {
		fmt.Println("Error creating request:", err)
		return nil, nil, err
	}

	// Set the required headers
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("anthropic-version", "2023-06-01")
	apiKey := os.Getenv("ANTHROPIC_API_KEY")
	req.Header.Set("x-api-key", apiKey)

	// Send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error making request:", err)
		return nil, nil, err
	}

	if resp.StatusCode != http.StatusOK {
		fmt.Println("Error: Unexpected status code:", resp.StatusCode)
		fmt.Println("Response:", resp.Status)
		return nil, nil, fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	reader := bufio.NewReader(resp.Body)
	return reader, func() error {
		return resp.Body.Close()
	}, nil
}

func processResponse(reader *bufio.Reader) {
	var eventData string
	var eventName Event
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			break
		}

		// Remove the trailing newline character
		line = strings.TrimSuffix(line, "\n")

		if line == "" {
			// Empty line indicates the end of an event
			// Process the event based on its name
			switch eventName {
			case EventContentBlockDelta:
				var delta ContentBlockDelta
				json.Unmarshal([]byte(eventData), &delta)
				for _, char := range delta.Delta.Text {
					fmt.Print(string(char))
					time.Sleep(20 * time.Millisecond)
				}
			case EventMessageStart,
				EventContentBlockStart,
				EventContentBlockStop,
				EventMessageStop,
				EventPing:
				// TODO: remove printing
				fmt.Println("Event:", eventName)
			default:
				fmt.Println("Unknown event:", eventName)
			}

			// Reset event name and data
			eventName = ""
			eventData = ""
		} else if strings.HasPrefix(line, "event:") {
			eventName = Event(strings.TrimSpace(strings.TrimPrefix(line, "event:")))
		} else if strings.HasPrefix(line, "data:") {
			dataLine := strings.TrimSpace(strings.TrimPrefix(line, "data:"))
			eventData += dataLine
		}
	}
}
