package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"

	"github.com/jlaffaye/ftp"
	"github.com/skorobogatov/input"
)

func interact(client *ftp.ServerConn) {
	quit := false
	for {
		fmt.Printf("command = ")
		command := input.Gets()
		switch command {
		case "quit":
			quit = true
			if err := client.Quit(); err != nil {
				log.Fatal(err)
			}
		case "save":
			fmt.Printf("path on server = ")
			path := input.Gets()
			fmt.Printf("name of file = ")
			name := input.Gets()
			file, err := os.Open(name)
			if err != nil {
				log.Fatal(err)
			}
			var data io.Reader
			data = file
			path += name
			err = client.Stor(path, data)
			if err != nil {
				log.Fatal(err)
			}
			file.Close()
			defer file.Close()
		case "load":
			fmt.Printf("path = ")
			path := input.Gets()
			r, err := client.Retr(path)
			if err != nil {
				log.Fatal(err)
			}
			for strings.Contains(path, "/") {
				if strings.Index(path, "/") == len(path)-1 {
					log.Fatal("Wrong path")
				}
				path = path[strings.Index(path, "/")+1:]
			}
			outfile, err := os.Create(path)
			if err != nil {
				log.Fatal(err)
			}
			_, err = io.Copy(outfile, r)
			if err != nil {
				log.Fatal(err)
			}
			outfile.Close()
			defer outfile.Close()
			r.Close()
			defer r.Close()
		case "mkDir":
			fmt.Printf("name = ")
			name := input.Gets()
			err := client.MakeDir(name)
			if err != nil {
				log.Fatal(err)
			}
		case "removeDir":
			fmt.Printf("name = ")
			name := input.Gets()
			err := client.RemoveDirRecur(name)
			if err != nil {
				log.Fatal(err)
			}
		case "cd":
			fmt.Printf("name = ")
			name := input.Gets()
			err := client.ChangeDir(name)
			if err != nil {
				log.Fatal(err)
			}
		case "delete":
			fmt.Printf("path = ")
			path := input.Gets()
			err := client.Delete(path)
			if err != nil {
				log.Fatal(err)
			}
		case "up":
			err := client.ChangeDirToParent()
			if err != nil {
				log.Fatal(err)
			}
		case "ls":
			cur, err := client.CurrentDir()
			if err != nil {
				log.Fatal(err)
			}
			fmt.Println(cur)
			fmt.Println()
			w := client.Walk(cur)
			for w.Next() {
				fmt.Println(w.Path()[1:])
			}
			fmt.Println()
		default:
			fmt.Printf("error: unknown command\n")
			continue

		}
		if quit {
			break
		}
	}
}
func main() {
	client, err := ftp.Dial("localhost:2121")
	if err != nil {
		log.Fatal(err)
	}
	err = client.Login("Dan", "1234")
	if err != nil {
		log.Fatal(err)
	}
	interact(client)
}
