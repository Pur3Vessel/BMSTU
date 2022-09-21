package proto

// Request -- запрос клиента к серверу.
type Request struct {
	Func string `json:"function"`
	Data string `json:"data"`
}

// Response -- ответ сервера клиенту.
type Response struct {
	Status string `json:"status"`
	Err    string `json:"error"`
	Data   string `json:"data"`
}
