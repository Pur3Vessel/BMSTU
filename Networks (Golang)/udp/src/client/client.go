package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"main/src/proto"
	"net"
	"os"
	"strconv"
	"time"

	log "github.com/mgutz/logxi/v1"
	"github.com/skorobogatov/input"
)

func control() {
	log.Info("control it")
}
func main() {
	var (
		serverAddrStr string
		n             uint
		helpFlag      bool
	)
	flag.StringVar(&serverAddrStr, "server", "127.0.0.1:6000", "set server IP address and port")
	flag.UintVar(&n, "n", 10, "set the number of requests")
	flag.BoolVar(&helpFlag, "help", false, "print options list")

	if flag.Parse(); helpFlag {
		fmt.Fprint(os.Stderr, "client [options]\n\nAvailable options:\n")
		flag.PrintDefaults()
	} else if serverAddr, err := net.ResolveUDPAddr("udp", serverAddrStr); err != nil {
		log.Error("resolving server address", "error", err)
	} else if conn, err := net.DialUDP("udp", nil, serverAddr); err != nil {
		log.Error("creating connection to server", "error", err)
	} else {
		defer conn.Close()
		buf := make([]byte, 100)
		for i := uint(0); i < n; i++ {
			var request proto.Request
			fmt.Print("Function - ")
			request.Func = input.Gets()
			fmt.Print("Argument - ")
			request.Data = input.Gets()
			jsonRequest, _ := json.Marshal(request)
			if _, err := conn.Write(jsonRequest); err != nil {
				log.Error("sending request to server", "error")
			} else {
				conn.SetReadDeadline(time.Now().Add(time.Second * 2))
				if bytesRead, err := conn.Read(buf); err != nil {
					log.Error("Try again, please")
					i--
				} else {
					jsonResponse := buf[:bytesRead]
					var response proto.Response
					err := json.Unmarshal(jsonResponse, &response)
					if err != nil {
						log.Error("Cannot unmarshal json", "json", string(jsonResponse))
					}
					if response.Status == "error" {
						log.Error("There was an error", "message", response.Err)
					} else {
						if _, err := strconv.ParseFloat(response.Data[:len(response.Data)-1], 64); err != nil {
							log.Error("cannot parse answer", "answer", response.Data, "error", err)
						} else {
							log.Info("successful interaction with server", "function", request.Func, "argument", request.Data, "answer", response.Data)
						}
					}
					conn.SetReadDeadline(time.Now().Add(time.Second * 1))
					for {
						_, err = conn.Read(buf)
						if err != nil {
							break
						}
					}
				}
			}
		}
	}
}
