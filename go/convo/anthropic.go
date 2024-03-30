package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/rs/zerolog"
)

type Payload struct {
	Model     string              `json:"model"`
	MaxTokens int                 `json:"max_tokens"`
	Messages  []map[string]string `json:"messages"`
	Stream    bool                `json:"stream"`
}

func callClaude(
	logger *zerolog.Logger,
	convo []Message,
) (*bufio.Reader, func() error, error) {
	messages := []map[string]string{}
	for _, m := range convo {
		messages = append(messages, map[string]string{
			"role":    string(m.author),
			"content": m.content,
		})
	}

	payload := Payload{
		Model:     "claude-3-opus-20240229",
		MaxTokens: 1024,
		Messages:  messages,
		Stream:    true,
	}

	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return nil, nil, err
	}

	req, err := http.NewRequest(
		"POST",
		"https://api.anthropic.com/v1/messages",
		bytes.NewBuffer(jsonPayload),
	)
	if err != nil {
		logger.Printf("Error creating request: %v\n", err)
		return nil, nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("anthropic-version", "2023-06-01")
	apiKey := os.Getenv("ANTHROPIC_API_KEY")
	req.Header.Set("x-api-key", apiKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		logger.Printf("Error making request: %v\n", err)
		return nil, nil, err
	}

	if resp.StatusCode != http.StatusOK {
		logger.Printf("Error: Unexpected status code: %d\n", resp.StatusCode)
		logger.Printf("Response: %s\n", resp.Status)
		return nil, nil, fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	reader := bufio.NewReader(resp.Body)
	return reader, func() error {
		return resp.Body.Close()
	}, nil
}
