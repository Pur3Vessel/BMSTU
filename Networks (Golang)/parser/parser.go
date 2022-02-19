package main

import (
	"fmt"

	"github.com/mmcdole/gofeed"
)

func main() {
	fp := gofeed.NewParser()
	feed, _ := fp.ParseURL("http://blagnews.ru/rss_vk.xml")
	fmt.Println(feed.Title)
	fmt.Println(feed.Generator)
	fmt.Println(feed.Description)
	fmt.Println(feed.Items[0])

}
