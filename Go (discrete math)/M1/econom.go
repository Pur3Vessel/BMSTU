package main

import (
	"fmt"
	"strings"
)
// смысл в том, чтобы воспользоваться функцией Replace пакета strings
// а именно искать ближайшую закрывающую скобку => она всегда завершает какое либо выражение
// с помощью replace можно вырезать все вхождения этого выражения (т.к его нужно считать всего раз) (замена идет на пробел, чтобы количество элементов в каждой скобке оставалось неизменным)
func main()  {
	var exp string
	fmt.Scan(&exp)
	var cuttingPoint int
	count := 0
	for true {
		cuttingPoint = strings.Index(exp, ")")
		if cuttingPoint == -1 {
			break
		}
		//fmt.Println(cuttingPoint)
		exp = strings.Replace(exp, exp[(cuttingPoint - 4) : (cuttingPoint + 1)], " ", -1)
		//fmt.Println(exp)
		count++
	}
	fmt.Println(count)
}

// Маленький одноногий мальчик встал не с той ноги и упал.