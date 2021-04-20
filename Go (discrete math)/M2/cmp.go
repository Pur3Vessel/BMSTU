package main

import (
	"fmt"
	"strconv"
	"strings"
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
		if u == numV && indexOf ((*listIncidence)[u].graphEdges, u) != -1 {
			Blue(listIncidence, u)
		}
		(*listIncidence)[u].comp = count
		for u != numV {
			u = s.pop()
			(*listIncidence)[u].comp = count
			Blue(listIncidence, u)
		}
		count++
	}
}
type graphVertex struct {
	name int
	index int
	погоняло string
	dist int
	w int
	graphEdges []int
	parent []int // чтоб окрашивать в красный
	t1 int
	low int
	comp int
	color int // 0 - empty, 1- red, 2 - blue
}
// Просто очень полезно
func indexOf(slice []int, element int) int {
	for i, x := range slice {
		if x == element {
			return i
		}
	}
	return -1
}
func relax(u, v *graphVertex, w int) bool {
	changed := u.dist + w > v.dist
	if changed {
		v.dist = u.dist + w
		//fmt.Printf("Блинб, путь в %s меняется на %d\n", v.погоняло, v.dist)
		v.parent = make([]int, 0)
		v.parent = append(v.parent, u.name)
	}
	if u.dist + w == v.dist {
		if indexOf(v.parent, u.name) == -1 {
			v.parent = append(v.parent, u.name) // Так как нужно найи все пути
		}
	}
	//fmt.Println("Chill out", changed)
	return changed
}
// Прочитал в википедии про метод эстафеты :) (работает максимально в лоб)
func relayRace(listIncidence *[]graphVertex)  {
	finish := false
	for i, _ := range *listIncidence {
		if (*listIncidence)[i].color != 2 {
			for _, e := range (*listIncidence)[i].graphEdges {
				if relax(&(*listIncidence)[i], &(*listIncidence)[e], (*listIncidence)[e].w) {
					finish = true
				}
			}
		}
	}
	if finish {
		relayRace(listIncidence)
	}
}
// Красим в синенький
func Blue(listIncidence *[]graphVertex, i int)  {
	//fmt.Println("Синячим")
	(*listIncidence)[i].color = 2
	(*listIncidence)[i].dist = -1 // выключаем
	for _, e := range (*listIncidence)[i].graphEdges {
		if (*listIncidence)[e].color != 2 {
			Blue(listIncidence, e)
		}
	}
}
// Красим в красненький
func Red(listIncidence *[]graphVertex, i int)  {
	(*listIncidence)[i].color = 1
	for _, e := range (*listIncidence)[i].parent {
		if (*listIncidence)[e].color != 1 {
			Red(listIncidence, e)
		}
	}
}
func main()  {
	// Тут немного перемудренное заполнение графа, но в результате получается все удобно
	var next, connect bool = false, false
	listIncidence := make([]graphVertex, 0)
	ohShitImSorry := make(map[string]int)
	token1 := ""
	tokenProm := ""
	token2 := ""
	fmt.Scanf("%s %s", &token1, &tokenProm)
	nnnext := strings.Index(token1, ";")
	if nnnext != -1 {
		next = true
		token1 = strings.Replace(token1, token1[nnnext:], "",-1)
	}
	cutting1 := strings.Index(token1, "(")
	cutting2 := strings.Index(token1, ")")
	w, _:= strconv.Atoi(token1[cutting1 + 1 : cutting2])
	token1 = strings.Replace(token1, token1[cutting1:], "", -1)
	var shrek graphVertex
	ohShitImSorry[token1] = 0
	shrek.color = 0
	shrek.name = 0
	shrek.graphEdges = make([]int, 0)
	shrek.погоняло = token1
	shrek.parent = make([]int, 0)
	shrek.w = w
	shrek.comp = -1
	shrek.dist = w
	listIncidence = append(listIncidence, shrek)
	c := 1
	//fmt.Println(tokenProm, next, tokenProm == "" && !next)
	if !(tokenProm == "" && !next) {
		for {
			if next {
				connect = true
				next = false
			}
			tokenProm = ""
			fmt.Scanf("%s %s", &token2, &tokenProm)
			nnnext = strings.Index(token2, ";")
			if nnnext != -1 {
				next = true
				token2 = strings.Replace(token2, token2[nnnext:], "",-1)
			}
			cutting1 = strings.Index(token2, "(")
			if cutting1 != -1 {
				cutting2 = strings.Index(token2, ")")
				w, _ = strconv.Atoi(token2[cutting1 + 1 : cutting2])
				token2 = strings.Replace(token2, token2[cutting1:], "", -1)
				ohShitImSorry[token2] = c
				shrek.name = c
				shrek.color = 0
				shrek.graphEdges = make([]int, 0)
				shrek.погоняло = token2
				shrek.parent = make([]int, 0)
				shrek.w = w
				shrek.comp = -1
				shrek.dist = w
				listIncidence = append(listIncidence, shrek)
				if !connect {
					t := ohShitImSorry[token1]
					if indexOf(listIncidence[t].graphEdges, c) == -1 {
						listIncidence[t].graphEdges = append(listIncidence[t].graphEdges, c)
					}
				}
				c++
			} else {
				if !connect {
					t := ohShitImSorry[token1]
					if indexOf(listIncidence[t].graphEdges, ohShitImSorry[token2]) == -1 {
						listIncidence[t].graphEdges = append(listIncidence[t].graphEdges, ohShitImSorry[token2])
					}

				}
			}
			token1 = token2
			if tokenProm == "" && !next{
				break
			}
			connect = false
		}
	}

	// Суть в том, что алгоритм Тарьяна позволяет выявить КСС (а следовательно и циклы) -> он окрашивает все в синий
	Tarjan(&listIncidence)
	// Далее запускается "эстафета", цель которой выявить для каждой вершины максимальную длину пути
	relayRace(&listIncidence)

	maxD := listIncidence[0].dist
	for i, _ := range listIncidence {
		if listIncidence[i].dist > maxD && listIncidence[i].color != 2{
			maxD = listIncidence[i].dist
		}
	}
	for i, _ := range listIncidence {
		if listIncidence[i].dist == maxD && listIncidence[i].color != 2{
			Red(&listIncidence, i)
		}
	}
	/*
	for _, v := range listIncidence {
		fmt.Println(v.погоняло, v.dist, v.parent, v.graphEdges)
		if v.color == 2 {
			fmt.Println("Синий")
		}
		if v.color == 1 {
			fmt.Println("Красный")
		}
	}
	*/


	fmt.Println("digraph {")
	for _, v := range listIncidence {
		if v.color == 0 {
			fmt.Printf("%s [label = \"%s(%d)\"]\n", v.погоняло, v.погоняло, v.w)
		}
		if v.color == 1 {
			fmt.Printf("%s [label = \"%s(%d)\", color = red]\n", v.погоняло, v.погоняло, v.w)
		}
		if v.color == 2 {
			fmt.Printf("%s [label = \"%s(%d)\", color = blue]\n", v.погоняло, v.погоняло, v.w)
		}
	}
	for _, v := range listIncidence {
		for _, e := range v.graphEdges {
			if v.color == 2 {
				fmt.Printf("%s -> %s [color = blue]\n", v.погоняло, listIncidence[e].погоняло)
			}
			if v.color == 1 && listIncidence[e].color == 1 {
				if indexOf(listIncidence[e].parent, v.name) != -1 {
					fmt.Printf("%s -> %s [color = red]\n", v.погоняло, listIncidence[e].погоняло)
				} else {
					fmt.Printf("%s -> %s\n", v.погоняло, listIncidence[e].погоняло)
				}
			}
			if v.color == 0 || (v.color == 1 && listIncidence[e].color != 1) {
				fmt.Printf("%s -> %s\n", v.погоняло, listIncidence[e].погоняло)
			}
		}
	}
	fmt.Println("}")
}

/*Однажды молодой человек пришел к мудрецу и сказал ему:
— Учитель, я хочу жениться и выбираю девственницу.
На что мудрец спросил его:
— А почему ты выбираешь именно девственницу?
Человек ответил:
— Выбирая девственницу, я могу быть уверен, что моя жена добродетельна.
Тогда учитель поднялся и ушел в комнату. Вернувшись, он держал в руках два кусочка говна: один целый, а второй надкушенный.
Старый мудрец предложил молодому человеку попробовать кусочки говна.
Юноша попробовал надкушенный кусочек говна — говно оказалось старое и несвежее.
Тогда юноша откусил свежий кусочек говна — говно оказалось мерзкое и вонючее.
Человек в недоумении развел руками:
— И что же, Учитель? Так какую жену мне выбрать-то?
Учитель ответил:
— Мужик, ты только что говна поел.

 */