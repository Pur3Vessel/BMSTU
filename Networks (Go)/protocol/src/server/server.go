package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"net"
	"proto"
	"strings"

	log "github.com/mgutz/logxi/v1"
)

// Client - состояние клиента.
type Client struct {
	logger log.Logger    // Объект для печати логов
	conn   *net.TCPConn  // Объект TCP-соединения
	enc    *json.Encoder // Объект для кодирования и отправки сообщений
	array  []int         // Массив
	tree   []int
}

// NewClient - конструктор клиента, принимает в качестве параметра
// объект TCP-соединения.
func NewClient(conn *net.TCPConn) *Client {
	return &Client{
		logger: log.New(fmt.Sprintf("client %s", conn.RemoteAddr().String())),
		conn:   conn,
		enc:    json.NewEncoder(conn),
		array:  make([]int, 0),
		tree:   make([]int, 0),
	}
}

// serve - метод, в котором реализован цикл взаимодействия с клиентом.
// Подразумевается, что метод serve будет вызаваться в отдельной go-программе.
func (client *Client) serve() {
	defer client.conn.Close()
	decoder := json.NewDecoder(client.conn)
	for {
		var req proto.Request
		if err := decoder.Decode(&req); err != nil {
			client.logger.Error("cannot decode message", "reason", err)
			break
		} else {
			client.logger.Info("received command", "command", req.Command)
			if client.handleRequest(&req) {
				client.logger.Info("shutting down connection")
				break
			}
		}
	}
}

// handleRequest - метод обработки запроса от клиента. Он возвращает true,
// если клиент передал команду "quit" и хочет завершить общение.
func (client *Client) handleRequest(req *proto.Request) bool {
	switch req.Command {
	case "quit":
		client.respond("ok", nil)
		return true

	case "create":
		errorMsg := ""
		if req.Data == nil {
			errorMsg = "data field is absent"
		} else {
			var a proto.Array
			if err := json.Unmarshal(*req.Data, &a); err != nil {
				errorMsg = "malformed data field"
			} else {
				client.array = make([]int, 0)
				for i := 0; i < len(a.Container); i++ {
					client.array = append(client.array, a.Container[i])
				}
				client.tree = treeBuild(client.array)
				x, _ := json.Marshal(client.array)
				client.logger.Info("performing addition", "value", strings.Trim(string(x), "[]"))
			}
		}
		if errorMsg == "" {
			client.respond("ok", nil)
		} else {
			client.logger.Error("addition failed", "reason", errorMsg)
			client.respond("failed", errorMsg)
		}
	case "update":
		errorMsg := ""
		if req.Data == nil {
			errorMsg = "data field is absent"
		} else {
			var a proto.Duo
			if err := json.Unmarshal(*req.Data, &a); err != nil {
				errorMsg = "malformed data field"
			} else {
				if len(client.array) == 0 {
					errorMsg = "no array"
				} else {
					if a.Index >= len(client.array) {
						errorMsg = "out of array"

					} else {
						if a.Index < 0 {
							errorMsg = "neg index"
						} else {
							client.array[a.Index] = a.Number
							update(&client.tree, a.Number, a.Index, 0, len(client.array)-1, 1)
						}
					}
				}
			}
		}
		if errorMsg == "" {
			client.respond("ok", nil)
		} else {
			client.logger.Error("addition failed", "reason", errorMsg)
			client.respond("failed", errorMsg)
		}
	case "sum":
		var ans int
		errorMsg := ""
		if req.Data == nil {
			errorMsg = "data field is absent"
		} else {
			var a proto.Duo
			if err := json.Unmarshal(*req.Data, &a); err != nil {
				errorMsg = "malformed data field"
			} else {
				if len(client.array) == 0 {
					errorMsg = "no array"
				} else {
					if a.Index < 0 || a.Number < 0 {
						errorMsg = "neg border"

					} else {
						if a.Index > a.Number {
							errorMsg = "wrong borders"
						} else {
							if a.Number >= len(client.array) {
								errorMsg = "out of array"
							} else {
								ans = sum(&client.tree, a.Index, a.Number, 0, len(client.array)-1, 1)
							}
						}
					}
				}
			}
		}
		if errorMsg == "" {
			client.respond("result", ans)
		} else {
			client.logger.Error("addition failed", "reason", errorMsg)
			client.respond("failed", errorMsg)
		}
	default:
		client.logger.Error("unknown command")
		client.respond("failed", "unknown command")
	}
	return false
}

// respond - вспомогательный метод для передачи ответа с указанным статусом
// и данными. Данные могут быть пустыми (data == nil).
func (client *Client) respond(status string, data interface{}) {
	var raw json.RawMessage
	raw, _ = json.Marshal(data)
	client.enc.Encode(&proto.Response{status, &raw})
}

func main() {
	// Работа с командной строкой, в которой может указываться необязательный ключ -addr.
	var addrStr string
	flag.StringVar(&addrStr, "addr", "127.0.0.1:6000", "specify ip address and port")
	flag.Parse()

	// Разбор адреса, строковое представление которого находится в переменной addrStr.
	if addr, err := net.ResolveTCPAddr("tcp", addrStr); err != nil {
		log.Error("address resolution failed", "address", addrStr)
	} else {
		log.Info("resolved TCP address", "address", addr.String())

		// Инициация слушания сети на заданном адресе.
		if listener, err := net.ListenTCP("tcp", addr); err != nil {
			log.Error("listening failed", "reason", err)
		} else {
			// Цикл приёма входящих соединений.
			for {
				if conn, err := listener.AcceptTCP(); err != nil {
					log.Error("cannot accept connection", "reason", err)
				} else {
					log.Info("accepted connection", "address", conn.RemoteAddr().String())

					// Запуск go-программы для обслуживания клиентов.
					go NewClient(conn).serve()
				}
			}
		}
	}
}

func treeBuild(arr []int) []int {
	tree := make([]int, len(arr)*20)
	build(arr, 0, len(arr)-1, 1, &tree)
	return tree
}
func build(arr []int, a, b, tier int, tree *[]int) {
	if a == b {
		(*tree)[tier] = arr[a]
	} else {
		middle := (a + b) / 2
		build(arr, a, middle, 2*tier, tree)
		build(arr, middle+1, b, 2*tier+1, tree)
		(*tree)[tier] = (*tree)[tier*2] + (*tree)[tier*2+1]
	}
}

func update(tree *[]int, value, index, a, b, tier int) {
	if a == b {
		(*tree)[tier] = value
	} else {
		middle := (a + b) / 2
		if index <= middle {
			update(tree, value, index, a, middle, tier*2)
		} else {
			update(tree, value, index, middle+1, b, tier*2+1)
		}
		(*tree)[tier] = (*tree)[tier*2] + (*tree)[tier*2+1]
	}
}

func sum(tree *[]int, left, right, a, b, tier int) int {
	if left == a && right == b {
		return (*tree)[tier]
	} else {
		middle := (a + b) / 2
		if right <= middle {
			return sum(tree, left, right, a, middle, 2*tier)
		} else {
			if left > middle {
				return sum(tree, left, right, middle+1, b, 2*tier+1)
			} else {
				return sum(tree, left, middle, a, middle, 2*tier) + sum(tree, middle+1, right, middle+1, b, 2*tier+1)
			}
		}
	}

}
