package main

import (
	"fmt"
	"strconv"
)
// имеет смысл составлять во время обхода всю необходиную информацию по компоненте (чтоб потом не узнавать)
type Comp struct {
	number int
	vertex int
	edge int
	minVertex int // номер минимальной вершины
}
type graphVertex struct {
	mark int // 0  - white, 1 - black
	comp int
	name int
	graphEdges []int // так как здесь у ребер нет атрибутов, то они характеризуются только номером второй инцидентной вершины
}

func DFS(listIncidence *[]graphVertex, c *Comp)  {
	var shrek Comp
	shrek.number = 0
	for i, v := range *listIncidence {          // ОБОЖАЮ УКАЗАТЕЛИ, УКАЗАТЕЛИ КЛАСС!!!!
		if v.mark == 0 {
			VisitVertex1(listIncidence, &shrek, &(*listIncidence)[i])
			if shrek.vertex > c.vertex {
				*c = shrek
			}
			if shrek.vertex == c.vertex {
				if shrek.edge > c.edge {
					*c = shrek
				}
				if shrek.edge == c.edge {
					if shrek.minVertex > c.minVertex {
						*c = shrek
					}
				}
			}
			shrek.vertex = 0
			shrek.edge = 0
			shrek.minVertex = -1
			shrek.number++
		}
	}
}
func VisitVertex1(listIncidence *[]graphVertex, component *Comp, vertex *graphVertex)  {
	(*vertex).mark = 1
	(*vertex).comp = (*component).number
	(*component).vertex++
	if (*vertex).name < (*component).minVertex {
		(*component).minVertex = (*vertex).name
	}
	for _, e := range (*vertex).graphEdges {
		(*component).edge++
		if (*listIncidence)[e].mark == 0 {
			VisitVertex1(listIncidence,  component,&((*listIncidence)[e]))
		}
	}
}

func main()  {
	color := "[color = red]"
	edges := make([][2]int , 0) // нужно для вывода ребер
	var c Comp
	c.edge = 0
	c.vertex = 0
	c.number = -1
	c.minVertex = -1
	var ve [2]int
	var n, m ,v1, v2 int
	fmt.Scan(&n)
	fmt.Scan(&m)
	listIncidence := make([]graphVertex, 0)
	for i := 0; i < n; i++ {
		var shrek graphVertex
		shrek.mark = 0
		shrek.name = i
		shrek.comp = -1
		shrek.graphEdges = make([]int, 0)
		listIncidence = append(listIncidence, shrek)
	}
	for i := 0; i < m; i++ {
		fmt.Scanf("%d %d", &v1, &v2)
		ve[0] = v1
		ve[1] = v2
		edges = append(edges, ve)
		listIncidence[v1].graphEdges = append(listIncidence[v1].graphEdges, v2)
		listIncidence[v2].graphEdges = append(listIncidence[v2].graphEdges, v1)
	}
	DFS(&listIncidence, &c) // Разделим граф по компонентам и сразу составим информацию по этим компонентам
	//for i, v := range listIncidence {
		//fmt.Printf("%d: %d\n", i, v.comp)
	//}
	fmt.Println("graph {")
	for _, v := range listIncidence {
		if v.comp == c.number {
			fmt.Println(strconv.Itoa(v.name) + " " + color)
		} else {
			fmt.Println(v.name)
		}
	}
	for _, ve := range edges {
		if listIncidence[ve[0]].comp == c.number {
			fmt.Println(strconv.Itoa(ve[0]) + " -- " + strconv.Itoa(ve[1]) + " " + color)
		} else {
			fmt.Println(strconv.Itoa(ve[0]) + " -- " + strconv.Itoa(ve[1]))
		}
	}
	fmt.Println("}")
}

// Маленькие дети залезли в шкаф к металлисту и попали в Говнарнию.