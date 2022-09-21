package main

import (
	"fmt"
	"strconv"
)
// Создает массив всех делителей числа (заодно заносит их в строку как вершины)
// Определям делители "попарно"
func getDividers (number int, graph string)  ([]int, string) {
	dividers := make([]int, 0)
	young := make([]int, 0)
	old := make([]int, 0) // олды тут?
	for i := 1; i * i <= number; i++ {
		if number % i == 0 {
			if i * i == number {
				young = append(young, i)
			} else {
				young  = append(young, i)
				old = append(old, number / i)
			}
		}
	}
	for _, x := range old {
		dividers = append(dividers, x)
		graph += strconv.Itoa(x) + "\n"
	}
	for i := len(young) - 1; i >= 0; i-- {
		dividers = append(dividers, young[i])
		graph += strconv.Itoa(young[i]) + "\n"
	}
	return dividers, graph

}
func main()  {
	var number int
	var dividers []int
	fmt.Scan(&number)
	graph := "graph {\n"
	dividers, graph = getDividers(number, graph)
	length := len(dividers)
	// Просто идем по массиву множителей и в тех парах, где удолетворяется условие задачи, ставим ребра
	for i := 0; i  < length; i++ {
		for j := i + 1; j < length; j++ {
			if dividers[i] % dividers[j] == 0 {
				// определили возможную, пару, теперь осталось определить отсутствие нарушения
				for lock := i + 1; lock <=  j; lock++ {
					if lock == j {
						// пара добавлена
						graph += strconv.Itoa(dividers[i]) + " -- " + strconv.Itoa(dividers[j]) + "\n"
					} else {
						if dividers[lock] % dividers[j] == 0 && dividers[i] % dividers[lock] == 0 {
							break
						}
					}
				}
			}
		}
	}
	graph += "}"
	fmt.Println(graph)
}
//Еврей Денис выстрелил своей девушке в лицо с обреза.

// (Это ужасно)