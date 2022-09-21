package main

import (
	"fmt" // пакет для форматированного ввода вывода
	"html/template"
	"io/ioutil"
	"net/http" // пакет для поддержки HTTP протокола

	"strings" // пакет для работы с UTF-8 строками

	"log" // пакет для логирования
)

func HomeRouterHandler(w http.ResponseWriter, r *http.Request) {

	r.ParseForm() //анализ аргументов,

	fmt.Println(r.Form) // ввод информации о форме на стороне сервера

	fmt.Println("path", r.URL.Path)

	fmt.Println("scheme", r.URL.Scheme)

	fmt.Println(r.Form["url_long"])

	for k, v := range r.Form {

		fmt.Println("key:", k)

		fmt.Println("val:", strings.Join(v, ""))

	}

	tmpl, err := template.ParseFiles("main/index.html")
	if err != nil {
		log.Fatalln(err)
	}
	err = tmpl.Execute(w, nil)
	if err != nil {
		log.Fatalln(err)
	}
	//fmt.Fprintf(w, "Test!") // отправляем данные на клиентскую сторону

}
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
	http.HandleFunc("/", HomeRouterHandler)  // установим роутер
	err := http.ListenAndServe(":9000", nil) // задаем слушать порт
	if err != nil {
		log.Fatal("ListenAndServe: ", err)

	}

}
