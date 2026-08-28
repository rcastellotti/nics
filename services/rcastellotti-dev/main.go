package main

import (
	"embed"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"net/http"

	"github.com/a-h/templ"
	"github.com/rcastellotti/www/templates"
)

//go:embed static content
var siteFiles embed.FS

func main() {
	port := flag.Int("port", 8080, "HTTP server port")
	flag.Parse()

	mux := http.NewServeMux()

	static, err := fs.Sub(siteFiles, "static")
	if err != nil {
		log.Fatal(err)
	}
	posts, err := loadPosts(siteFiles, "content/posts")
	if err != nil {
		log.Fatal(err)
	}
	tils, err := loadTILs(siteFiles, "content/til", markdownRenderer())
	if err != nil {
		log.Fatal(err)
	}
	mux.Handle("GET /static/", http.StripPrefix("/static/", http.FileServerFS(static)))
	mux.Handle("GET /{$}", templ.Handler(templates.Home()))
	registerTILRoutes(mux, tils)
	postsHandler := templ.Handler(templates.Posts(posts))
	mux.Handle("GET /posts", postsHandler)
	mux.Handle("GET /posts/{$}", postsHandler)
	mux.HandleFunc("GET /posts/{slug}", func(w http.ResponseWriter, r *http.Request) {
		post, ok := findPost(posts, r.PathValue("slug"))
		if !ok {
			http.NotFound(w, r)
			return
		}
		templ.Handler(templates.Post(post)).ServeHTTP(w, r)
	})

	addr := fmt.Sprintf(":%d", *port)

	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}
