package main

import (
	"io/ioutil"
	"log"
	"net/http"
)

func makeRequest() {
	resp, err := http.Get("http://localhost:9000")
	if err != nil {
		log.Fatalln(err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln(err)
	}
	log.Println(string(body))
}
func main() {
	makeRequest()
}
