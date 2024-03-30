package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/urfave/cli/v2"
)

func main() {
	app := &cli.App{
		Name:  "pdf2remarkable",
		Usage: "Transfer PDF or Epub document to a reMarkable tablet",
		Flags: []cli.Flag{
			&cli.BoolFlag{
				Name:  "r",
				Usage: "Restart Xochitl after transfer",
			},
		},
		Action: func(c *cli.Context) error {
			if c.NArg() < 1 {
				cli.ShowAppHelpAndExit(c, 1)
			}

			remarkableHost := "remarkable"
			remarkableXochitlDir := ".local/share/remarkable/xochitl/"
			targetDir := fmt.Sprintf("%s:%s", remarkableHost, remarkableXochitlDir)
			restartXochitl := c.Bool("r")

			tmpdir, err := os.MkdirTemp("", "pdf2remarkable")
			if err != nil {
				return fmt.Errorf("failed to create temporary directory: %w", err)
			}
			// defer os.RemoveAll(tmpdir)

			for i := 0; i < c.NArg(); i++ {
				filename := c.Args().Get(i)
				if err := processFile(filename, tmpdir, targetDir); err != nil {
					fmt.Fprintf(os.Stderr, "Error processing file %s: %v\n", filename, err)
					continue
				}
			}

			if restartXochitl {
				fmt.Println("Restarting Xochitl...")
				cmd := exec.Command("ssh", remarkableHost, "systemctl restart xochitl")
				if err := cmd.Run(); err != nil {
					return fmt.Errorf("failed to restart Xochitl: %w", err)
				}
				fmt.Println("Done.")
			}

			return nil
		},
	}

	err := app.Run(os.Args)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func processFile(filename, tmpdir, targetDir string) error {
	uuidOut, err := exec.Command("uuidgen").Output()
	if err != nil {
		return fmt.Errorf("failed to generate UUID: %w", err)
	}
	uuid := strings.TrimSpace(string(uuidOut))

	extension := filepath.Ext(filename)
	base := filepath.Base(filename)
	uuidFilename := uuid + extension
	uuidFilePath := filepath.Join(tmpdir, uuidFilename)

	input, err := os.ReadFile(filename)
	if err != nil {
		return fmt.Errorf("failed to read file %s: %w", filename, err)
	}
	if err := os.WriteFile(uuidFilePath, input, 0644); err != nil {
		return fmt.Errorf("failed to write file %s: %w", uuidFilePath, err)
	}

	metadata := fmt.Sprintf(
		`{
    "deleted": false,
    "lastModified": "%d000",
    "metadatamodified": false,
    "modified": false,
    "parent": "",
    "pinned": false,
    "synced": false,
    "type": "DocumentType",
    "version": 1,
    "visibleName": "%s"
}`,
		// today's date in unix timestamp
		time.Now().Unix(),
		strings.TrimSuffix(
			base,
			extension,
		),
	) // You might want to replace `int64(0)` with the actual lastModified time
	if err := os.WriteFile(filepath.Join(tmpdir, uuid+".metadata"), []byte(metadata), 0644); err != nil {
		return fmt.Errorf("failed to write metadata for %s: %w", uuid, err)
	}

	content := `{
    "extraMetadata": {
    },
    "fileType": "pdf",
    "fontName": "",
    "lastOpenedPage": 0,
    "lineHeight": -1,
    "margins": 100,
    "pageCount": 1,
    "textScale": 1,
    "transform": {
        "m11": 1,
        "m12": 1,
        "m13": 1,
        "m21": 1,
        "m22": 1,
        "m23": 1,
        "m31": 1,
        "m32": 1,
        "m33": 1
    }
}`
	if extension == ".pdf" || extension == ".epub" {
		if extension == ".epub" {
			content = `{
    "fileType": "epub"
}`
		}
		if err := os.WriteFile(filepath.Join(tmpdir, uuid+".content"), []byte(content), 0644); err != nil {
			return fmt.Errorf("failed to write content for %s: %w", uuid, err)
		}
		for _, dir := range []string{"cache", "highlights", "thumbnails"} {
			if err := os.Mkdir(filepath.Join(tmpdir, uuid+"."+dir), 0755); err != nil {
				return fmt.Errorf("failed to create directory %s for %s: %w", dir, uuid, err)
			}
		}
	} else {
		fmt.Printf("Unknown extension: %s, skipping %s\n", extension, filename)
		return nil
	}

	fmt.Printf("Transferring %s as %s\n", filename, uuid)

	// scpCmd := exec.Command("scp", "-r", tmpdir, targetDir)
	// copy one file at a time
	for _, file := range []string{uuidFilename, uuid + ".metadata", uuid + ".content"} {
		fmt.Printf("Transferring %s\n", file)
		if err := transferFile(file, tmpdir, targetDir); err != nil {
			return err
		}
	}

	return nil
}

func transferFile(file, tmpdir, targetDir string) error {
	scpCmd := exec.Command("scp", filepath.Join(tmpdir, file), targetDir)
	if output, err := scpCmd.CombinedOutput(); err != nil {
		return fmt.Errorf("failed to transfer file %s: %v. Output: %s", file, err, string(output))
	}
	return nil
}
