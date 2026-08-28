package templates

import "time"

type TIL struct {
	Date time.Time
	HTML string
}

type TILCrumb struct {
	Label string
	Path  string
}

func (til TIL) Path() string {
	return "/til/" + til.Date.Format("2006/01/02")
}

func TILCrumbs(date time.Time, depth int) []TILCrumb {
	crumbs := []TILCrumb{
		{Label: date.Format("2006"), Path: "/til/" + date.Format("2006")},
		{Label: date.Format("01"), Path: "/til/" + date.Format("2006/01")},
		{Label: date.Format("02"), Path: "/til/" + date.Format("2006/01/02")},
	}
	if depth < 0 || depth > len(crumbs) {
		depth = len(crumbs)
	}
	return crumbs[:depth]
}
