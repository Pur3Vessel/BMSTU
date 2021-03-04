package main

import (
	"fmt"
	//"github.com/skorobogatov/input"
)
// Эта чертила загрузилась на сервак с 40 раза
// Гребанная поломанная задача
func main()  {
	var (
		s, xx, yy string
		point1 bool = false
		point2 bool = false
		count int = 0
		ran int = 1000001
	)
	//s = input.Gets()
	//input.Scanf("%s %s", &xx, &yy)
	fmt.Scanf("%s ", &s)
	fmt.Scanf("%s", &xx)
	fmt.Scanf("%s", &yy)
	sym1 := ([]rune)(xx)
	sym2 := ([]rune)(yy)
	//fmt.Printf("%s\n", xx)
	//fmt.Printf("%s\n", yy)
	for _, x := range s {
		if x == sym1[0]{
			if point1 {
				count = -1
			}
			if point2 {
				if count < ran {
					ran = count
				}
				count = 0
				point2 = false
			}
			if (!point1) {
				count = -1
			}
			point1 = true
		}
		if x == sym2[0]{
			if point2 {
				count = -1
			}
			if point1 {
				if count < ran {
					ran = count
				}
				count = 0
				point1 = false
			}
			if (!point2) {
				count = -1
			}
			point2 = true
		}
		if point1 || point2 {
			count++
		}
		if (ran == 0) {
			break
		}
	}
	fmt.Printf("%d", ran)


}

// Что общего между пчелкой и инвалидом?
// Жалко