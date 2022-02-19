package main

import (
	"log"

	filedriver "github.com/goftp/file-driver"
	"github.com/goftp/server"
)

func main() {
	factory := &filedriver.FileDriverFactory{
		RootPath: "serverFiles",
		Perm:     server.NewSimplePerm("user", "group"),
	}
	opts := &server.ServerOpts{
		Factory:  factory,
		Port:     2121,
		Hostname: "localhost",
		Auth:     &server.SimpleAuth{Name: "Dan", Password: "1234"},
	}
	log.Printf("Start ftp server on %v %v", opts.Hostname, opts.Port)
	server := server.NewServer(opts)
	err := server.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}
