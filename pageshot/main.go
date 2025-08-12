package main

import (
	"context"
	"flag"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/chromedp"
)

type Config struct {
	URL       string
	Output    string
	Wait      string
	Timeout   time.Duration
	Viewport  string
	DPR       float64
	Full      bool
	Scroll    bool
	Delay     time.Duration
	UserAgent string
	Headers   []string
	JPEG      bool
	Quality   int
	PDF       bool
	Selector  string
	Quiet     bool
}

func main() {
	config := parseFlags()

	if config.URL == "" {
		fmt.Fprintf(os.Stderr, "Usage: pageshot [options] URL\n")
		flag.PrintDefaults()
		os.Exit(1)
	}

	if err := validateAndNormalizeURL(&config.URL); err != nil {
		fmt.Fprintf(os.Stderr, "Invalid URL: %v\n", err)
		os.Exit(1)
	}

	if err := takeScreenshot(config); err != nil {
		if !config.Quiet {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		}
		os.Exit(1)
	}
}

func parseFlags() Config {
	config := Config{
		Output:   "screenshot.png",
		Wait:     "idle",
		Timeout:  30 * time.Second,
		Viewport: "1280x800",
		DPR:      2.0,
		Full:     true,
		Quality:  90,
	}

	flag.StringVar(&config.Output, "out", config.Output, "Output file path")
	flag.StringVar(&config.Wait, "wait", config.Wait, "Wait strategy: load, dom, idle")
	timeoutMs := flag.Int("timeout", 30000, "Timeout in milliseconds")
	flag.StringVar(&config.Viewport, "viewport", config.Viewport, "Initial viewport (e.g., 1280x800)")
	flag.Float64Var(&config.DPR, "dpr", config.DPR, "Device pixel ratio (1-3)")
	flag.BoolVar(&config.Full, "full", config.Full, "Take full-page screenshot")
	flag.BoolVar(&config.Scroll, "scroll", config.Scroll, "Progressive scroll before screenshot")
	delayMs := flag.Int("delay", 0, "Extra delay before screenshot (ms)")
	flag.StringVar(&config.UserAgent, "user-agent", "", "Override user agent")

	var headers arrayFlags
	flag.Var(&headers, "header", "HTTP headers (repeatable: 'Name: Value')")

	flag.BoolVar(&config.JPEG, "jpeg", config.JPEG, "Output as JPEG instead of PNG")
	flag.IntVar(&config.Quality, "quality", config.Quality, "JPEG quality (0-100)")
	flag.BoolVar(&config.PDF, "pdf", config.PDF, "Output as PDF instead of image")
	flag.StringVar(&config.Selector, "selector", "", "Wait for selector before screenshot")
	flag.BoolVar(&config.Quiet, "quiet", config.Quiet, "Suppress info logs")

	flag.Parse()

	config.Timeout = time.Duration(*timeoutMs) * time.Millisecond
	config.Delay = time.Duration(*delayMs) * time.Millisecond
	config.Headers = headers

	// URL is provided as the last positional argument
	if flag.NArg() > 0 {
		config.URL = flag.Arg(flag.NArg() - 1) // Take the last argument as URL
	}

	config.Timeout = time.Duration(*timeoutMs) * time.Millisecond
	config.Delay = time.Duration(*delayMs) * time.Millisecond
	config.Headers = headers

	// URL can be provided as --url flag or as the last positional argument
	if config.URL == "" && flag.NArg() > 0 {
		config.URL = flag.Arg(flag.NArg() - 1) // Take the last argument as URL
	}

	return config
}

type arrayFlags []string

func (af *arrayFlags) String() string {
	return strings.Join(*af, ", ")
}

func (af *arrayFlags) Set(value string) error {
	*af = append(*af, value)
	return nil
}

func validateAndNormalizeURL(urlStr *string) error {
	if !strings.HasPrefix(*urlStr, "http://") && !strings.HasPrefix(*urlStr, "https://") {
		*urlStr = "https://" + *urlStr
	}

	u, err := url.Parse(*urlStr)
	if err != nil {
		return err
	}

	if u.Scheme != "http" && u.Scheme != "https" {
		return fmt.Errorf("unsupported scheme: %s", u.Scheme)
	}

	*urlStr = u.String()
	return nil
}

func takeScreenshot(config Config) error {
	ctx, cancel := context.WithTimeout(context.Background(), config.Timeout)
	defer cancel()

	opts := []chromedp.ExecAllocatorOption{
		chromedp.NoFirstRun,
		chromedp.NoDefaultBrowserCheck,
		chromedp.Headless,
		chromedp.DisableGPU,
		chromedp.NoSandbox,                           // Required for some environments
		chromedp.Flag("disable-dev-shm-usage", true), // Required in Docker/CI environments
	}

	// Use CHROME_PATH if set, otherwise fallback to default
	if chromePath := os.Getenv("CHROME_PATH"); chromePath != "" {
		opts = append(opts, chromedp.ExecPath(chromePath))
	}

	if config.UserAgent != "" {
		opts = append(opts, chromedp.UserAgent(config.UserAgent))
	}

	allocCtx, cancelAlloc := chromedp.NewExecAllocator(ctx, opts...)
	defer cancelAlloc()

	chromeCtx, cancelChrome := chromedp.NewContext(allocCtx)
	defer cancelChrome()

	width, height, err := parseViewport(config.Viewport)
	if err != nil {
		return fmt.Errorf("invalid viewport: %v", err)
	}

	var buf []byte
	tasks := chromedp.Tasks{
		chromedp.EmulateViewport(int64(width), int64(height), chromedp.EmulateScale(config.DPR)),
		chromedp.Navigate(config.URL),
	}

	switch config.Wait {
	case "load":
		tasks = append(tasks, chromedp.WaitReady("body"))
	case "dom":
		tasks = append(tasks, chromedp.WaitReady("body", chromedp.ByQuery))
	case "idle":
		tasks = append(tasks, chromedp.Sleep(500*time.Millisecond))
	default:
		return fmt.Errorf("invalid wait strategy: %s", config.Wait)
	}

	if config.Selector != "" {
		tasks = append(tasks, chromedp.WaitVisible(config.Selector))
	}

	if config.Scroll {
		tasks = append(tasks, progressiveScroll())
	}

	if config.Delay > 0 {
		tasks = append(tasks, chromedp.Sleep(config.Delay))
	}

	if config.PDF {
		tasks = append(tasks, chromedp.ActionFunc(func(ctx context.Context) error {
			var err error
			buf, _, err = page.PrintToPDF().Do(ctx)
			return err
		}))
	} else if config.Full {
		tasks = append(tasks, chromedp.FullScreenshot(&buf, config.Quality))
	} else {
		tasks = append(tasks, chromedp.CaptureScreenshot(&buf))
	}

	if err := chromedp.Run(chromeCtx, tasks); err != nil {
		return fmt.Errorf("chromedp failed: %v", err)
	}

	ext := filepath.Ext(config.Output)
	if config.PDF && ext != ".pdf" {
		config.Output = strings.TrimSuffix(config.Output, ext) + ".pdf"
	} else if config.JPEG && ext != ".jpg" && ext != ".jpeg" {
		config.Output = strings.TrimSuffix(config.Output, ext) + ".jpg"
	}

	if err := os.WriteFile(config.Output, buf, 0644); err != nil {
		return fmt.Errorf("failed to write file: %v", err)
	}

	if !config.Quiet {
		fmt.Fprintf(os.Stderr, "Screenshot saved to: %s\n", config.Output)
	}

	return nil
}

func parseViewport(viewport string) (int, int, error) {
	parts := strings.Split(viewport, "x")
	if len(parts) != 2 {
		return 0, 0, fmt.Errorf("viewport must be in format WIDTHxHEIGHT")
	}

	width, err := strconv.Atoi(parts[0])
	if err != nil {
		return 0, 0, fmt.Errorf("invalid width: %v", err)
	}

	height, err := strconv.Atoi(parts[1])
	if err != nil {
		return 0, 0, fmt.Errorf("invalid height: %v", err)
	}

	return width, height, nil
}

func progressiveScroll() chromedp.Action {
	return chromedp.ActionFunc(func(ctx context.Context) error {
		var scrollHeight int64
		if err := chromedp.Evaluate("document.scrollingElement.scrollHeight", &scrollHeight).Do(ctx); err != nil {
			return err
		}

		var currentScroll int64 = 0
		step := int64(500)

		for currentScroll < scrollHeight {
			if err := chromedp.Evaluate(fmt.Sprintf("window.scrollTo(0, %d)", currentScroll), nil).Do(ctx); err != nil {
				return err
			}
			time.Sleep(200 * time.Millisecond)
			currentScroll += step
		}

		return chromedp.Evaluate("window.scrollTo(0, 0)", nil).Do(ctx)
	})
}
