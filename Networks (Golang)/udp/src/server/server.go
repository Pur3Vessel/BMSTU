package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"main/src/proto"
	"math"
	"net"
	"os"
	"strconv"

	log "github.com/mgutz/logxi/v1"
)

func main() {
	var (
		serverAddrStr string
		helpFlag      bool
	)
	flag.StringVar(&serverAddrStr, "addr", "127.0.0.1:6000", "set server IP address and port")
	flag.BoolVar(&helpFlag, "help", false, "print options list")

	if flag.Parse(); helpFlag {
		fmt.Fprint(os.Stderr, "server [options]\n\nAvailable options:\n")
		flag.PrintDefaults()
	} else if serverAddr, err := net.ResolveUDPAddr("udp", serverAddrStr); err != nil {
		log.Error("resolving server address", "error", err)
	} else if conn, err := net.ListenUDP("udp", serverAddr); err != nil {
		log.Error("creating listening connection", "error", err)
	} else {
		log.Info("server listens incoming messages from clients")
		buf := make([]byte, 32)
		for {
			if bytesRead, addr, err := conn.ReadFromUDP(buf); err != nil {
				log.Error("receiving message from client", "error", err)
			} else {
				jsonRequest := buf[:bytesRead]
				var request proto.Request
				err := json.Unmarshal(jsonRequest, &request)
				if err != nil {
					log.Error("Cannot unmarshal json", "json", string(jsonRequest))
				}
				switch request.Func {
				case "sin":
					if arg, err := strconv.ParseFloat(request.Data, 64); err != nil {
						log.Error("Wrong argument", "arg", request.Data)
						var response proto.Response
						response.Status = "error"
						response.Err = "Wrong argument"
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client")
						}
					} else {
						answer := math.Sin(arg)
						var response proto.Response
						response.Status = "ok"
						response.Data = fmt.Sprintf("%f", answer)
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client", "func", request.Func, "arg", request.Data, "answer", response.Data)
						}
					}
				case "cos":
					if arg, err := strconv.ParseFloat(request.Data, 64); err != nil {
						log.Error("Wrong argument", "arg", request.Data)
						var response proto.Response
						response.Status = "error"
						response.Err = "Wrong argument"
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client")
						}
					} else {
						answer := math.Cos(arg)
						var response proto.Response
						response.Status = "ok"
						response.Data = fmt.Sprintf("%f", answer)
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client", "func", request.Func, "arg", request.Data, "answer", response.Data)
						}
					}
				case "tg":
					if arg, err := strconv.ParseFloat(request.Data, 64); err != nil {
						log.Error("Wrong argument", "arg", request.Data)
						var response proto.Response
						response.Status = "error"
						response.Err = "Wrong argument"
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client")
						}
					} else {
						answer := math.Tan(arg)
						var response proto.Response
						response.Status = "ok"
						response.Data = fmt.Sprintf("%f", answer)
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client", "func", request.Func, "arg", request.Data, "answer", response.Data)
						}
					}
				case "ctg":
					if arg, err := strconv.ParseFloat(request.Data, 64); err != nil {
						log.Error("Wrong argument", "arg", request.Data)
						var response proto.Response
						response.Status = "error"
						response.Err = "Wrong argument"
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client")
						}
					} else {
						answer := 1 / math.Tan(arg)
						var response proto.Response
						response.Status = "ok"
						response.Data = fmt.Sprintf("%f", answer)
						jsonResponse, _ := json.Marshal(response)
						if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
							log.Error("sending message to client", "error", err, "client", addr.String())
						} else {
							log.Info("successful interaction with client", "func", request.Func, "arg", request.Data, "answer", response.Data)
						}
					}
				default:
					log.Error("Wrong func", "func", request.Func)
					var response proto.Response
					response.Status = "error"
					response.Err = "Wrong func"
					jsonResponse, _ := json.Marshal(response)
					if _, err = conn.WriteToUDP(jsonResponse, addr); err != nil {
						log.Error("sending message to client", "error", err, "client", addr.String())
					} else {
						log.Info("successful interaction with client")
					}
				}
			}
		}
	}
}
