package main

import (
	"fmt"
	"sort"
)

var count = 0

type graphEdge struct {
	to int
	sym string
}
type graphVertex struct {
	name int
	color int
	canon int
	graphEdges []graphEdge
}

func DFS(diagram *[]graphVertex, v int)  {
	(*diagram)[v].color = 1
	(*diagram)[v].canon = count
	count++
	for _, e := range (*diagram)[v].graphEdges {
		if (*diagram)[e.to].color == 0 {
			DFS(diagram, e.to)
		}
	}
}
// Просто делается обход в глубину, и затем диаграмма сортируется относительно canon
func main()  {
	var n, m, start, cr int
	var sym string
	var shrek graphVertex
	var diagram = make([]graphVertex, 0)
	_, _ = fmt.Scan(&n)
	_, _ = fmt.Scan(&m)
	_, _ = fmt.Scan(&start)
	for i := 0; i < n; i++ {
		shrek.graphEdges = make([]graphEdge, 0)
		shrek.name = i
		shrek.color = 0
		shrek.canon = -1
		for j := 0; j < m; j++ {
			_, _ = fmt.Scan(&cr)
			var e graphEdge
			e.to = cr
			shrek.graphEdges = append(shrek.graphEdges, e)
		}
		diagram = append(diagram, shrek)
 	}
 	for i := 0; i < n; i++ {
 		for j := 0; j < m; j++ {
 			_, _ = fmt.Scan(&sym)
 			diagram[i].graphEdges[j].sym = sym
		}
 	}
 	DFS(&diagram, start)
 	// Переименуем вершины
 	for v, _ := range diagram {
 		if diagram[v].canon == -1 {
 			n--
		}
 		for e, _ := range diagram[v].graphEdges {
 			diagram[v].graphEdges[e].to = diagram[diagram[v].graphEdges[e].to].canon
		}
		diagram[v].name = diagram[v].canon
	}
	sort.Slice(diagram, func(i, j int) bool {
		return diagram[i].canon < diagram[j].canon
	})
 	fmt.Printf("%d\n%d\n0\n", n, m)
 	for _, v := range diagram {
 		if v.canon != -1 {
			for i := 0; i < m; i++ {
				fmt.Printf("%d ", v.graphEdges[i].to)
			}
			fmt.Println()
		}
 	}
	for _, v := range diagram {
		if v.canon != -1 {
			for i := 0; i < m; i++ {
				fmt.Printf("%s ", v.graphEdges[i].sym)
			}
			fmt.Println()
		}
	}
}
/*
Мужик наелся сахара с дрожжами.
Теперь ходит-бродит.
*/
