package proto

import "encoding/json"

// Request -- запрос клиента к серверу.
type Request struct {
	// Поле Command может принимать следующие значения:
	// * "quit"
	// * create
	// * "update"
	// * "sum"
	Command string `json:"command"`

	Data *json.RawMessage `json:"data"`
}

// Response -- ответ сервера клиенту.
type Response struct {
	Status string `json:"status"`

	Data *json.RawMessage `json:"data"`
}

type Duo struct {
	number int `json:"number"`
	index  int `json:"index"`
}

type Array struct {
	arr []int `json:"arr"`
}
