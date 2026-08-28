package templates

import "time"

type BlogPost struct {
	Slug        string
	Title       string
	Date        time.Time
	Description string
	HTML        string
}
