package main

import "fmt"

func sum(a, b int) {
	fmt.Println(a + b)
}

func test(a, b, d string, c int, sum_arg func(a, b int)) {
	fmt.Println(a)
	fmt.Println(b + d)
	fmt.Println(c)
	sum_arg(c, 1)
}

func main() {
	sum(5, 7)
	test("Hello", "Bye", "Bye", 42, sum)
}
