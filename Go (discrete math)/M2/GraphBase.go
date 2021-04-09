package main

import (
	"fmt"
	"sort"
)

var time = 1
var count = 0

type stack struct {
	data []int
	top int
}

func (s *stack) push(vertex int)  {
	s.data[s.top] = vertex
	s.top++
}
func (s *stack) pop() int {
	s.top--
	return s.data[s.top]
}
type graphVertex struct {
	entry bool
	t1 int
	low int
	comp int
	name int
	graphEdges []int
}

func Tarjan(listIncidence *[]graphVertex)  {
	var s stack
	s.top = 0
	s.data = make([]int, len(*listIncidence))
	for e, _ := range *listIncidence {
		if (*listIncidence)[e].t1 == 0 {
			visitVertexTarjan(listIncidence, e, &s)
		}
	}
}
// Чтоб повторки не добавлять
func indexOf(slice []int, element int)  int {
	for i, x := range slice {
		if x == element {
			return i
		}
	}
	return -1
}
func visitVertexTarjan(listIncidence *[]graphVertex, numV int, s *stack)  {
	(*listIncidence)[numV].t1 = time
	(*listIncidence)[numV].low = time
	time++
	s.push(numV)
	for _, e := range (*listIncidence)[numV].graphEdges {
		//fmt.Printf("Я вершина %d смотрю на вершину %d\n", numV, e)
		if (*listIncidence)[e].t1 == 0 {
			//fmt.Printf("Я вершина %d собираюсь посетить вершину %d\n", numV, e)
			visitVertexTarjan(listIncidence, e, s)
		}
		if ((*listIncidence)[e].comp == -1) && ((*listIncidence)[numV].low > (*listIncidence)[e].low) {
			(*listIncidence)[numV].low = (*listIncidence)[e].low
		}
	}
	if (*listIncidence)[numV].low == (*listIncidence)[numV].t1 {
		u := s.pop()
		(*listIncidence)[u].comp = count
		for u != numV {
			u = s.pop()
			(*listIncidence)[u].comp = count
		}
		count++
	}
}
func entryVertex(listIncidence *[]graphVertex, numV int)  {
	//fmt.Printf("Хо-хо зашел в компоненту %d\n", numV)
	if !(*listIncidence)[numV].entry {
		//fmt.Printf("Хо-хо щас изменю компоненту %d\n", numV)
		(*listIncidence)[numV].entry = true
		for _, e := range (*listIncidence)[numV].graphEdges {
			entryVertex(listIncidence, e)
		}
	}
}
func main()  {
	var n, m, v1, v2 int
	fmt.Scan(&n)
	fmt.Scan(&m)
	listIncidence := make([]graphVertex, 0)
	base := make([]int, 0)
	for i := 0; i < n; i++ {
		var shrek graphVertex
		shrek.name = i
		shrek.comp = -1
		shrek.t1 = 0
		shrek.graphEdges = make([]int, 0)
		listIncidence = append(listIncidence, shrek)
	}
	// В общем-то теперь добавляется только в одну вершину (т.к. граф ориентированный)
	for i := 0; i < m; i++ {
		fmt.Scanf("%d %d", &v1, &v2)
		listIncidence[v1].graphEdges = append(listIncidence[v1].graphEdges, v2)
	}
	Tarjan(&listIncidence)
	// строим конденсацию (для этого просто пройдемся по вершинам и исходящим из них ребрам и в случае несоответствия comp
	// будем заносить это в конденсацию)
	condencation := make([]graphVertex, 0)
	for i := 0; i < count; i++ {
		var shrek graphVertex
		shrek.name = i
		shrek.entry = false
		shrek.graphEdges = make([]int, 0)
		condencation = append(condencation, shrek)
	}
	for v, _ := range listIncidence {
		for _ , e := range listIncidence[v].graphEdges {
			if listIncidence[v].comp != listIncidence[e].comp {
				if indexOf(condencation[listIncidence[v].comp].graphEdges, listIncidence[e].comp) == -1 {
					condencation[listIncidence[v].comp].graphEdges = append(condencation[listIncidence[v].comp].graphEdges, listIncidence[e].comp)
				}
			}
		}
	}
	//fmt.Println(condencation)
	//for v, _ := range listIncidence {
		//fmt.Println(v , listIncidence[v].comp, listIncidence[v].graphEdges)
	//}
	// Находим базу конденсации
	// Для этого нужно найти вершины с нулевой полустепенью захода
	for v, _ := range condencation {
		if !condencation[v].entry {
			for _ , e := range condencation[v].graphEdges {
				entryVertex(&condencation, e)
			}
		}
	}
	// Осталось взять вершины с минимальным номером
	for v, _ := range condencation {
		if !condencation[v].entry {
			minV := n
			for e, _ := range listIncidence {
				if listIncidence[e].comp == v && e < minV {
					minV = e
				}
			}
			if minV != n {
				base = append(base, minV)
			}

		}
	}
	sort.Ints(base)
	//fmt.Println(base)
	for _, x := range base {
		fmt.Printf("%d ", x)
	}
}
/*
Приходит мужик в бар. Садится за стойку и рядом на стойку кладет маленькую собачку без лап. Заказывает бутылку водки, выпивает.
Бармен интересуется:
- А как зовут-то собачку?
Мужик (с чувством, вытирая слезу):
- Какая разница, блять, зови... не зови... - не прибежит нихуя.
 */