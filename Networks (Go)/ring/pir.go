package main

import (
	log "github.com/mgutz/logxi/v1"
	"github.com/webview/webview"
)

func main() {
	log.Info("1")
	debug := true
	w := webview.New(debug)
	defer w.Destroy()
	w.SetTitle("Minimal webview example")
	w.SetSize(800, 600, webview.HintNone)
	w.Navigate("https://en.m.wikipedia.org/wiki/Main_Page")
	w.Run()
}
