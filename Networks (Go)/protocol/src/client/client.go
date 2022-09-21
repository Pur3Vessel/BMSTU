package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"net"
	"proto"
	"strconv"

	"github.com/skorobogatov/input"
)

// interact - функция, содержащая цикл взаимодействия с сервером.
func interact(conn *net.TCPConn) {
	defer conn.Close()
	encoder, decoder := json.NewEncoder(conn), json.NewDecoder(conn)
	for {
		// Чтение команды из стандартного потока ввода
		fmt.Printf("command = ")
		command := input.Gets()

		// Отправка запроса.
		switch command {
		case "quit":
			send_request(encoder, "quit", nil)
			return
		case "create":
			err := false
			fmt.Printf("array = ")
			var a proto.Array
			a.Container = make([]int, 0)
			arr := input.Gets()
			for i := 0; i < len(arr); i++ {
				if arr[i] == 32 {
					continue
				}
				if arr[i] < 48 || arr[i] > 57 {
					err = true
					break
				} else {
					s := i
					i = help(arr, i)
					n, _ := strconv.Atoi(arr[s:i])
					a.Container = append(a.Container, n)
				}
			}
			if err {
				fmt.Println("not int")
				continue
			} else {
				send_request(encoder, "create", &a)
			}
		case "update":
			var a proto.Duo
			fmt.Printf("index = ")
			b, err := strconv.Atoi(input.Gets())
			if err != nil {
				fmt.Println("not int")
				continue
			} else {
				a.Index = b
			}

			fmt.Printf("value = ")
			c, err := strconv.Atoi(input.Gets())
			if err != nil {
				fmt.Println("not int")
				continue
			} else {
				a.Number = c
			}
			send_request(encoder, "update", &a)
		case "sum":
			var a proto.Duo
			fmt.Printf("left = ")
			b, err := strconv.Atoi(input.Gets())
			if err != nil {
				fmt.Println("not int")
				continue
			} else {
				a.Index = b
			}

			fmt.Printf("right = ")
			c, err := strconv.Atoi(input.Gets())
			if err != nil {
				fmt.Println("not int")
				continue
			} else {
				a.Number = c
			}
			send_request(encoder, "sum", &a)
		default:
			fmt.Printf("error: unknown command\n")
			continue
		}

		// Получение ответа.
		var resp proto.Response
		if err := decoder.Decode(&resp); err != nil {
			fmt.Printf("error: %v\n", err)
			break
		}

		// Вывод ответа в стандартный поток вывода.
		switch resp.Status {
		case "ok":
			fmt.Printf("ok\n")
		case "failed":
			if resp.Data == nil {
				fmt.Printf("error: data field is absent in response\n")
			} else {
				var errorMsg string
				if err := json.Unmarshal(*resp.Data, &errorMsg); err != nil {
					fmt.Printf("error: malformed data field in response\n")
				} else {
					fmt.Printf("failed: %s\n", errorMsg)
				}
			}
		case "result":
			if resp.Data == nil {
				fmt.Printf("error: data field is absent in response\n")
			} else {
				var a int
				if err := json.Unmarshal(*resp.Data, &a); err != nil {
					fmt.Printf("error: malformed data field in response\n")
				} else {
					fmt.Printf("result: %d\n", a)
				}
			}
		default:
			fmt.Printf("error: server reports unknown status %q\n", resp.Status)
		}
	}
}

// send_request - вспомогательная функция для передачи запроса с указанной командой
// и данными. Данные могут быть пустыми (data == nil).
func send_request(encoder *json.Encoder, command string, data interface{}) {
	var raw json.RawMessage
	raw, _ = json.Marshal(data)
	encoder.Encode(&proto.Request{command, &raw})
}

func main() {
	// Работа с командной строкой, в которой может указываться необязательный ключ -addr.
	var addrStr string
	flag.StringVar(&addrStr, "addr", "127.0.0.1:6000", "specify ip address and port")
	flag.Parse()

	// Разбор адреса, установка соединения с сервером и
	// запуск цикла взаимодействия с сервером.
	if addr, err := net.ResolveTCPAddr("tcp", addrStr); err != nil {
		fmt.Printf("error: %v\n", err)
	} else if conn, err := net.DialTCP("tcp", nil, addr); err != nil {
		fmt.Printf("error: %v\n", err)
	} else {
		interact(conn)
	}
}

func help(s string, i int) int {

	for i < len(s) {
		if !(s[i] >= 48 && s[i] <= 57) {
			return i
		}
		i++
	}

	return len(s)
}
