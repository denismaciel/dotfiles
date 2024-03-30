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

	"github.com/charmbracelet/bubbles/spinner"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/rs/zerolog"
)

// Create a logger that writes to a file

const CHAR_DELAY = 15 * time.Millisecond

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

func callClaude(
	logger *zerolog.Logger,
	convo []Message) (*bufio.Reader, func() error, error) {
	messages := []map[string]string{}
	for _, m := range convo {
		messages = append(messages, map[string]string{
			"role":    string(m.author),
			"content": m.content,
		})
	}
	payload := map[string]interface{}{
		"model":      "claude-3-opus-20240229",
		"max_tokens": 1024,
		"messages":   messages,
		"stream":     true,
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
		logger.Printf("Error creating request: %v\n", err)
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

type Author string

const (
	AuthorAssistant Author = "assistant"
	AuthorUser      Author = "user"
)

type Message struct {
	author  Author
	content string
}

func write(logger *zerolog.Logger, llm chan rune, user <-chan []Message) tea.Cmd { return func() tea.Msg { for {
			convo := <-user
			reader, closefn, err := callClaude(logger, convo)
			if err != nil {
				fmt.Fprintf(os.Stderr, "error: %v\n", err)
				os.Exit(1)
			}
			defer closefn()
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
						for _, c := range delta.Delta.Text {
							llm <- c
							time.Sleep(CHAR_DELAY)
						}
					case EventMessageStart,
						EventContentBlockStart,
						EventContentBlockStop,
						EventMessageStop,
						EventPing:
					default:
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
	}
}

func read(sub chan rune) tea.Cmd {
	return func() tea.Msg {
		character := <-sub
		return Character(character)
	}
}

type model struct {
	logger    *zerolog.Logger
	user      chan []Message
	llm       chan rune
	spinner   spinner.Model
	convo     []Message
	textInput textinput.Model
}

func (m model) Init() tea.Cmd {
	m.logger.Println("Init")
	return tea.Batch(
		m.spinner.Tick,
		write(m.logger, m.llm, m.user),
		read(m.llm),
		textinput.Blink,
	)
}

type Character rune

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg.(type) {
	case tea.KeyMsg:
		switch msg.(tea.KeyMsg).Type {
		case tea.KeyCtrlC, tea.KeyEsc:
			return m, tea.Quit
		case tea.KeyEnter:
			m.convo = append(m.convo, Message{
				author:  AuthorUser,
				content: m.textInput.Value(),
			})
			m.user <- m.convo
			m.textInput.SetValue("")
			return m, nil
		default:
			m.textInput, _ = m.textInput.Update(msg)
			return m, nil
		}
	// The Character got sent from convertToStream We then handle it by
	// appending it to the message and then we reschedule convertToStream to
	// wait for the next character.
	case Character:
		c := msg.(Character)
		last := m.convo[len(m.convo)-1]
		if last.author == AuthorAssistant {
			last.content += string(c)
			m.convo[len(m.convo)-1] = last
		} else {
			m.convo = append(m.convo, Message{
				author:  AuthorAssistant,
				content: string(c),
			})
		}
		return m, read(m.llm)
	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
	default:
		return m, nil
	}
}
func (m model) View() string {
	s := fmt.Sprintf(
		"\n %s \n\n",
		m.spinner.View(),
	)
	for _, msg := range m.convo {
		s += fmt.Sprintf("%s: %s\n", msg.author, msg.content)
	}
	s += "\n"
	s += m.textInput.View()

	return s
}

func initialModel0() model {
	ti := textinput.New()
	ti.Placeholder = ""
	ti.Focus()
	ti.CharLimit = 300
	ti.Width = 80

	// initialize a logger that write to a file log.txt
	file, err := os.OpenFile("log.txt", os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0666)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
	logger := zerolog.New(file).With().Timestamp().Logger()	
	logger.Println("Hello, log file!")
      logger.Printf("Hello, %s", "log file2!")

	return model{
		logger:    &logger,
		llm:       make(chan rune),
		user:      make(chan []Message),
		spinner:   spinner.New(),
		convo:     []Message{},
		textInput: ti,
	}
}

func main() {
	p := tea.NewProgram(initialModel0())
	if err := p.Start(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v", err)
		os.Exit(1)
	}
}
