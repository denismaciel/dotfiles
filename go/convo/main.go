package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/spinner"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/glamour"
	"github.com/rs/zerolog"
)

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

type Author string

const (
	AuthorAssistant Author = "assistant"
	AuthorUser      Author = "user"
)

type Message struct {
	author  Author
	content string
}

// This function listens for user input on the user channel, sends it to Claude
// and writes the response to the llm channel.
func talkToLLM(logger *zerolog.Logger, llm chan rune, user <-chan []Message) tea.Cmd {
	return func() tea.Msg {
		for {
			convo := <-user
			reader, closefn, err := callClaude(logger, convo)
			if err != nil {
				fmt.Fprintf(os.Stderr, "error: %v\n", err)
				os.Exit(1)
			}
			defer closefn()
			processClaudeOutput(reader, llm)
		}
	}
}

func processClaudeOutput(reader *bufio.Reader, llm chan rune) {
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


func readLLMOutput(ch chan rune) tea.Cmd {
	return func() tea.Msg {
		character := <-ch
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
	return tea.Batch(
		m.spinner.Tick,
		talkToLLM(m.logger, m.llm, m.user),
		readLLMOutput(m.llm),
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
	// Character got sent from readLLMOutput. We then handle it by appending
	// it to the message. We then reschedule readLLMOutpu to wait for
	// the next character.
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
		return m, readLLMOutput(m.llm)
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
		rendered, err := renderMessage(msg)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
		s += rendered
	}
	s += "\n"
	s += m.textInput.View()
	s += "\n"

	return s
}

func initialModel() model {
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
		user:      make(chan []Message, 10),
		spinner:   spinner.New(spinner.WithSpinner(spinner.Monkey)),
		convo:     []Message{},
		textInput: ti,
	}
}

func renderMessage(msg Message) (string, error) {
	const width = 100

	renderer, err := glamour.NewTermRenderer(
		glamour.WithAutoStyle(),
		glamour.WithWordWrap(width),
	)
	if err != nil {
		return "", err
	}

	str, err := renderer.Render(msg.content)
	if err != nil {
		return "", err
	}

	return str, nil
}

func main() {
	p := tea.NewProgram(initialModel())
	if err := p.Start(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v", err)
		os.Exit(1)
	}
}
