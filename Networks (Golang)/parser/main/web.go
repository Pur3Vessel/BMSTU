package main

import (
	"fmt"      // пакет для форматированного ввода вывода
	"net/http" // пакет для поддержки HTTP протокола
	"strings"  // пакет для работы с UTF-8 строками
	"text/template"

	"github.com/mmcdole/gofeed"

	"log" // пакет для логирования
)

func HomeRouterHandler(w http.ResponseWriter, r *http.Request) {

	r.ParseForm() //анализ аргументов,
	fmt.Println(1)
	fmt.Println(r.Form) // ввод информации о форме на стороне сервера
	fmt.Println(1)
	fmt.Println("path", r.URL.Path)
	fmt.Println(1)
	fmt.Println("scheme", r.URL.Scheme)
	fmt.Println(1)
	fmt.Println(r.Form["url_long"])
	fmt.Println(1)
	for k, v := range r.Form {

		fmt.Println("key:", k)

		fmt.Println("val:", strings.Join(v, ""))

	}
	fp := gofeed.NewParser()
	feed, _ := fp.ParseURL("https://news.mail.ru/rss/90/")

	content := ` <html lang="ru"> <head> <title>Тест</title> <meta http-equiv="Content-type" content="text/html;charset=UTF-8" /> </head> <body>`
	content += `<h1 style="font-size: 30px;">` + feed.Title + `</h1>`
	content += `<br>`
	for _, x := range feed.Items {
		content += `<div>`
		content += `<a href="` + x.Link + `" style="font-size: 23px;">` + x.Title + `</a>`
		content += `<p>` + x.Description + `</p>`
		content += `<p>` + x.Published + `</p>`
		content += `</div>`
		content += `<br>`
	}
	content += `</body> </html>`
	tmpl, _ := template.New("example").Parse(content)
	tmpl.Execute(w, content)

}

func main() {
	http.HandleFunc("/", HomeRouterHandler)  // установим роутер
	err := http.ListenAndServe(":9000", nil) // задаем слушать порт
	if err != nil {
		log.Fatal("ListenAndServe: ", err)

	}

}
