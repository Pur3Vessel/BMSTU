package main

import (
	"fmt"
	"log"
	"os"

	"github.com/skorobogatov/input"
	"golang.org/x/crypto/ssh"
)

func main() {

	username := "ddd"
	password := "06092002"
	hostname := "127.0.0.1"
	port := "3000"

	// SSH client config
	config := &ssh.ClientConfig{
		User: username,
		Auth: []ssh.AuthMethod{
			ssh.Password(password),
		},
		// Non-production only
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	// Connect to host
	client, err := ssh.Dial("tcp", hostname+":"+port, config)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	// Create sesssion
	sess, err := client.NewSession()
	if err != nil {
		log.Fatal("Failed to create session: ", err)
	}
	defer sess.Close()

	// StdinPipe for commands
	stdin, err := sess.StdinPipe()
	if err != nil {
		log.Fatal(err)
	}
	if len(os.Args) == 1 {
		// Enable system stdout
		sess.Stdout = os.Stdout
		sess.Stderr = os.Stderr

		// Start remote shell
		err = sess.Shell()
		if err != nil {
			log.Fatal(err)
		}

		for {
			var cmd string
			cmd = input.Gets()
			_, err = fmt.Fprintf(stdin, "%s\n", cmd)
			if err != nil {
				log.Fatal(err)
			}
			if cmd == "exit" {
				sess.Close()
				break
			}
		}
	} else {
		// setup standard out and error
		// uses writer interface
		sess.Stdout = os.Stdout
		sess.Stderr = os.Stderr
		cmd := ""
		for i := 1; i < len(os.Args); i++ {
			cmd += os.Args[i]
			if i != len(os.Args)-1 {
				cmd += " "
			}
		}
		// run single command
		err = sess.Run(cmd)
		if err != nil {
			fmt.Println("hi")
			log.Fatal(err)
		}
	}

}
