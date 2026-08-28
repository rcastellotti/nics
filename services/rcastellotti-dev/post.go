package main

import (
	"bytes"
	"fmt"
	"io/fs"
	"path"
	"slices"
	"strings"
	"time"

	chromahtml "github.com/alecthomas/chroma/v2/formatters/html"
	"github.com/rcastellotti/www/templates"
	"github.com/yuin/goldmark"
	highlighting "github.com/yuin/goldmark-highlighting/v2"
	"github.com/yuin/goldmark/extension"
)

func loadPosts(files fs.FS, dir string) ([]templates.BlogPost, error) {
	entries, err := fs.ReadDir(files, dir)
	if err != nil {
		return nil, fmt.Errorf("read posts: %w", err)
	}

	markdown := markdownRenderer()
	posts := make([]templates.BlogPost, 0, len(entries))
	for _, entry := range entries {
		if entry.IsDir() || path.Ext(entry.Name()) != ".md" {
			continue
		}

		source, err := fs.ReadFile(files, path.Join(dir, entry.Name()))
		if err != nil {
			return nil, fmt.Errorf("read post %q: %w", entry.Name(), err)
		}
		post, body, err := parsePost(entry.Name(), source)
		if err != nil {
			return nil, err
		}

		var rendered bytes.Buffer
		if err := markdown.Convert(body, &rendered); err != nil {
			return nil, fmt.Errorf("render post %q: %w", entry.Name(), err)
		}
		post.HTML = rendered.String()
		posts = append(posts, post)
	}

	slices.SortFunc(posts, func(a, b templates.BlogPost) int { return b.Date.Compare(a.Date) })
	return posts, nil
}

func markdownRenderer() goldmark.Markdown {
	return goldmark.New(goldmark.WithExtensions(
		extension.GFM,
		highlighting.NewHighlighting(
			highlighting.WithStyle("modus-operandi"),
			highlighting.WithFormatOptions(
				chromahtml.WithClasses(true),
				chromahtml.WithModeClasses(true),
			),
		),
	))
}

func findPost(posts []templates.BlogPost, slug string) (templates.BlogPost, bool) {
	for _, post := range posts {
		if post.Slug == slug {
			return post, true
		}
	}
	return templates.BlogPost{}, false
}

func parsePost(filename string, source []byte) (templates.BlogPost, []byte, error) {
	post := templates.BlogPost{Slug: strings.TrimSuffix(filename, path.Ext(filename))}
	body := source

	if bytes.HasPrefix(source, []byte("---\n")) {
		frontMatter, markdownBody, found := bytes.Cut(source[4:], []byte("\n---\n"))
		if !found {
			return templates.BlogPost{}, nil, fmt.Errorf("post %q has unclosed front matter", filename)
		}
		for _, line := range strings.Split(string(frontMatter), "\n") {
			key, value, ok := strings.Cut(line, ":")
			if !ok {
				continue
			}
			value = strings.Trim(strings.TrimSpace(value), `"'`)
			switch strings.TrimSpace(key) {
			case "title":
				post.Title = value
			case "description":
				post.Description = value
			case "date":
				date, err := time.Parse("2006-01-02", value)
				if err != nil {
					return templates.BlogPost{}, nil, fmt.Errorf("post %q has invalid date: %w", filename, err)
				}
				post.Date = date
			}
		}
		body = markdownBody
	}

	return post, body, nil
}
