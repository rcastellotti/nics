package main

import (
	"bytes"
	"fmt"
	"io/fs"
	"net/http"
	"path"
	"slices"
	"strings"
	"time"

	"github.com/a-h/templ"
	"github.com/rcastellotti/www/templates"
	"github.com/yuin/goldmark"
)

func loadTILs(files fs.FS, dir string, markdown goldmark.Markdown) ([]templates.TIL, error) {
	var tils []templates.TIL
	err := fs.WalkDir(files, dir, func(filename string, entry fs.DirEntry, err error) error {
		if err != nil || entry.IsDir() || path.Ext(filename) != ".md" {
			return err
		}
		rel := strings.TrimPrefix(filename, dir+"/")
		parts := strings.Split(strings.TrimSuffix(rel, ".md"), "/")
		if len(parts) != 3 {
			return nil
		}
		date, err := time.Parse("2006/01/02", strings.Join(parts, "/"))
		if err != nil {
			return fmt.Errorf("invalid TIL path %q: %w", filename, err)
		}
		source, err := fs.ReadFile(files, filename)
		if err != nil {
			return err
		}
		if strings.TrimSpace(string(source)) == "" {
			return nil
		}
		var rendered bytes.Buffer
		if err := markdown.Convert(source, &rendered); err != nil {
			return fmt.Errorf("render TIL %q: %w", filename, err)
		}
		tils = append(tils, templates.TIL{Date: date, HTML: rendered.String()})
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("load TILs: %w", err)
	}
	slices.SortFunc(tils, func(a, b templates.TIL) int { return b.Date.Compare(a.Date) })
	return tils, nil
}

func registerTILRoutes(mux *http.ServeMux, tils []templates.TIL) {
	mux.HandleFunc("GET /til", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/til/", http.StatusMovedPermanently)
	})
	mux.HandleFunc("GET /til/{$}", func(w http.ResponseWriter, r *http.Request) {
		if len(tils) == 0 {
			http.NotFound(w, r)
			return
		}
		templ.Handler(templates.TILPage(tils[0], true)).ServeHTTP(w, r)
	})
	mux.HandleFunc("GET /til/{year}", func(w http.ResponseWriter, r *http.Request) {
		filtered := filterTILs(tils, r.PathValue("year"), "")
		if len(filtered) == 0 {
			http.NotFound(w, r)
			return
		}
		templ.Handler(templates.TILArchive(r.PathValue("year"), filtered)).ServeHTTP(w, r)
	})
	mux.HandleFunc("GET /til/{year}/{month}", func(w http.ResponseWriter, r *http.Request) {
		filtered := filterTILs(tils, r.PathValue("year"), r.PathValue("month"))
		if len(filtered) == 0 {
			http.NotFound(w, r)
			return
		}
		templ.Handler(templates.TILArchive(r.PathValue("year")+"/"+r.PathValue("month"), filtered)).ServeHTTP(w, r)
	})
	mux.HandleFunc("GET /til/{year}/{month}/{day}", func(w http.ResponseWriter, r *http.Request) {
		slug := strings.Join([]string{r.PathValue("year"), r.PathValue("month"), r.PathValue("day")}, "/")
		for _, entry := range tils {
			if entry.Date.Format("2006/01/02") == slug {
				templ.Handler(templates.TILPage(entry, false)).ServeHTTP(w, r)
				return
			}
		}
		http.NotFound(w, r)
	})
}

func filterTILs(tils []templates.TIL, year, month string) []templates.TIL {
	var filtered []templates.TIL
	for _, entry := range tils {
		if entry.Date.Format("2006") == year && (month == "" || entry.Date.Format("01") == month) {
			filtered = append(filtered, entry)
		}
	}
	return filtered
}
