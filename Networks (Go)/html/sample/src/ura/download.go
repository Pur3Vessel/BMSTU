package main

import (
	"net/http"

	log "github.com/mgutz/logxi/v1"
	"golang.org/x/net/html"
)

func getAttr(node *html.Node, key string) string {
	for _, attr := range node.Attr {
		if attr.Key == key {
			return attr.Val
		}
	}
	return ""
}

func getChildren(node *html.Node) []*html.Node {
	var children []*html.Node
	for c := node.FirstChild; c != nil; c = c.NextSibling {
		children = append(children, c)
	}
	return children
}

func isElem(node *html.Node, tag string) bool {
	return node != nil && node.Type == html.ElementNode && node.Data == tag
}

func isText(node *html.Node) bool {
	return node != nil && node.Type == html.TextNode
}

func isDiv(node *html.Node, class string) bool {
	return isElem(node, "div") && getAttr(node, "class") == class
}
func isLi(node *html.Node, class string) bool {
	return isElem(node, "li") && getAttr(node, "class") == class
}

type Item struct {
	Ref, Time, Title string
	Imp              int
}

func readItem(item *html.Node, imp int) *Item {
	if a := item.FirstChild.NextSibling; isElem(a, "a") {
		if cs := getChildren(a); len(cs) == 3 && isElem(cs[1], "span") && isText(cs[2]) {
			if imp == 0 {
				return &Item{
					Ref:   getAttr(a, "href"),
					Time:  cs[1].FirstChild.Data,
					Title: cs[2].Data,
					Imp:   0,
				}
			} else {
				return &Item{
					Ref:   getAttr(a, "href"),
					Time:  cs[1].FirstChild.Data,
					Title: cs[2].Data,
					Imp:   1,
				}
			}
		}
	}
	return nil
}

func search(node *html.Node) []*Item {
	if isDiv(node, "list-news") {
		var items []*Item
		node = node.FirstChild.NextSibling.FirstChild.NextSibling.NextSibling.NextSibling
		for c := node.FirstChild; c != nil; c = c.NextSibling {
			if isLi(c, "list-scroll-item ") {
				if item := readItem(c, 0); item != nil {
					items = append(items, item)
				}
			}
			if isLi(c, "list-scroll-item list-scroll-item-important") {
				if item := readItem(c, 1); item != nil {
					items = append(items, item)
				}
			}
		}
		return items
	}
	for c := node.FirstChild; c != nil; c = c.NextSibling {
		if items := search(c); items != nil {
			return items
		}
	}
	return nil
}

func downloadNews() []*Item {
	log.Info("sending request to ura.news")
	if response, err := http.Get("https://ura.news/msk"); err != nil {
		log.Error("request to ura.news failed", "error", err)
	} else {
		defer response.Body.Close()
		status := response.StatusCode
		log.Info("got response from ura.news", "status", status)
		if status == http.StatusOK {
			if doc, err := html.Parse(response.Body); err != nil {
				log.Error("invalid HTML from ura.news", "error", err)
			} else {
				log.Info("HTML from ura.news parsed successfully")
				return search(doc)
			}
		}
	}
	return nil
}
