package main

import (
	"fmt"
	"sort"
)
var count = 1
type stack struct {
	data []*graphVertex
	top int
}

func (s *stack) push(vertex *graphVertex)  {
	s.data[s.top] = vertex
	s.top++
}
func (s *stack) pop() *graphVertex {
	s.top--
	return s.data[s.top]
}
type graphVertex struct {
	name int // Нужно для отладки
	dead bool // Показывает, является ли команда "мертвой"
	time int // Время вхождения
	command string
	operand int   // Нужны для создания графа
	parent *graphVertex
	ancestor *graphVertex
	idom *graphVertex
	sdom *graphVertex
	label *graphVertex
	graphEdgesTo []*graphVertex // Исходящие ребра
	graphEdgesFrom []*graphVertex // Входящие ребра
	bucket []*graphVertex
}

func FindMin(v *graphVertex, s *stack)  *graphVertex{
	var min *graphVertex
	if v.ancestor == nil {
		min = v
	} else {
		s.top = 0
		var u = v
		for u.ancestor.ancestor != nil {
			s.push(u)
			u = u.ancestor
		}
		for s.top != 0 {
			v = s.pop()
			if v.ancestor.label.sdom.time < v.label.sdom.time {
				v.label = v.ancestor.label
			}
			v.ancestor = u.ancestor
		}
		min = v.label
	}
	return min
}
func Dominators(listIncidence []*graphVertex, n int) []*graphVertex{
	var s stack
	s.data = make([]*graphVertex, n)
	//fmt.Println("Доминация началась")
	for _, w := range listIncidence {
		if w.time == 1 {
			continue
		}
		for _, v := range w.graphEdgesFrom {
			u := FindMin(v, &s)
			if u.sdom.time < w.sdom.time {
				w.sdom = u.sdom
			}
		}
		w.ancestor = w.parent
		w.sdom.bucket = append(w.sdom.bucket, w)
		for _, v := range w.parent.bucket {
			u := FindMin(v, &s)
			if u.sdom == v.sdom {
				v.idom = v.sdom
			} else {
				v.idom = u
			}
		}
		w.parent.bucket = nil
	}
	//fmt.Println("Доминация продолжается")
	for _, w := range listIncidence {
		if w.time == 1 {
			continue
		}
		if w.idom != w.sdom {
			w.idom = w.idom.idom
		}
	}
	//fmt.Println("Доминация закончилась")
	listIncidence[len(listIncidence) - 1].idom = nil
	return listIncidence
}
// Цель обхода: заполнить поля time и parent, а также выявить "мертвые команды"
func DFS(r *graphVertex)  {
	r.dead = false
	r.time = count
	count++
	for e, _ := range r.graphEdgesTo {
		if r.graphEdgesTo[e].dead {
			r.graphEdgesTo[e].parent = r
			DFS(r.graphEdgesTo[e])
		}
	}
}

func main()  {
	var n, v1, v2 int
	var s string
	fmt.Scan(&n)
	listIncidence := make([]*graphVertex, 0)
	ohShitImSorry := make(map[int]int) // Метка -> порядковый номер в графе
	for i := 0; i < n; i++ {
		var shrek graphVertex
		shrek.name = i
		shrek.dead = true
		shrek.graphEdgesTo = make([]*graphVertex, 0)
		shrek.graphEdgesFrom = make([]*graphVertex, 0)
		shrek.bucket = make([]*graphVertex, 0)
		shrek.ancestor = nil
		shrek.sdom = &shrek
		shrek.label = &shrek
		listIncidence = append(listIncidence, &shrek)
	}
	for i , _ := range listIncidence {
		fmt.Scanf("%d %s %d\n", &v1, &s, &v2)
		//fmt.Println(v1, s)
		listIncidence[i].command = s
		if s != "ACTION" {
			listIncidence[i].operand = v2
			//fmt.Println(v2)
		}
		ohShitImSorry[v1] = i
	}
	for i, _ := range listIncidence {
		switch listIncidence[i].command {
		case "ACTION":
			if i != n - 1 {
				listIncidence[i].graphEdgesTo = append(listIncidence[i].graphEdgesTo, listIncidence[i + 1])
				listIncidence[i + 1].graphEdgesFrom = append(listIncidence[i + 1].graphEdgesFrom, listIncidence[i])
			}
			break
		case "JUMP":
			v2 = ohShitImSorry[listIncidence[i].operand]
			listIncidence[i].graphEdgesTo = append(listIncidence[i].graphEdgesTo, listIncidence[v2])
			listIncidence[v2].graphEdgesFrom = append(listIncidence[v2].graphEdgesFrom, listIncidence[i])
			break
		case "BRANCH":
			v2 = ohShitImSorry[listIncidence[i].operand]
			listIncidence[i].graphEdgesTo = append(listIncidence[i].graphEdgesTo, listIncidence[v2])
			listIncidence[v2].graphEdgesFrom = append(listIncidence[v2].graphEdgesFrom, listIncidence[i])
			if i != n - 1 {
				listIncidence[i].graphEdgesTo = append(listIncidence[i].graphEdgesTo, listIncidence[i + 1])
				listIncidence[i + 1].graphEdgesFrom = append(listIncidence[i + 1].graphEdgesFrom, listIncidence[i])
			}
			break
		}
	}
	/*
	for _, v := range listIncidence {
			fmt.Printf("Вершина %d ведет в: \n", v.name)
		for _, e := range v.graphEdgesTo {
			fmt.Println(e.name)
		}
		fmt.Printf("Вершина %d ведет из: \n", v.name)
		for _, e := range v.graphEdgesFrom {
			fmt.Println(e.name)
		}
	}*/
	DFS(listIncidence[0])
	// После обхода нужно удалить все "мертвые" команды из основного списка и из всех входящих дуг
	for i := 0; i < len(listIncidence); i++ {
		if listIncidence[i].dead {
			listIncidence[i] = listIncidence[len(listIncidence) - 1]
			listIncidence[len(listIncidence) - 1] = nil
			listIncidence = listIncidence[:len(listIncidence) - 1]
			i--
		} else {
			for j := 0; j < len(listIncidence[i].graphEdgesFrom); j++ {
				if listIncidence[i].graphEdgesFrom[j].dead {
					listIncidence[i].graphEdgesFrom[j] = listIncidence[i].graphEdgesFrom[len(listIncidence[i].graphEdgesFrom) - 1]
					listIncidence[i].graphEdgesFrom = listIncidence[i].graphEdgesFrom[:len(listIncidence[i].graphEdgesFrom) - 1]
					j--
				}
			}
		}
	}
	//for i, _ := range listIncidence{
		//fmt.Println(listIncidence[i].name)
	//}\
	sort.Slice(listIncidence, func(i, j int) bool {
		return listIncidence[i].time > listIncidence[j].time
	})
	n = len(listIncidence)

	listIncidence = Dominators(listIncidence, n)


	// Предполагем что каждая вершина может быть заголовком натурального цикла, и проверяем это, исходя из определения (1.2) и свойтв (2.1 и 2.2)
	loops := 0
	for _, v := range listIncidence {
		// (2.1) и (1.2)
		for _, e := range v.graphEdgesFrom {
			//fmt.Printf("Вершина %d пытаеться задоминировать над вершиной %d\n", v.name, e.name)
			for e != v && e!= nil {
				e = e.idom
				if e!= nil {
					//fmt.Printf("DOMINATE %d\n", e.name)
				}
			}
			if e == v {
				loops++
				break // (2.2)
			}
		}
	}
	fmt.Println(loops)

}
/*
Разговаривают две подруги. Одна спрашивает другую:
— Как там твой друг — математик?
— Да, урод он! Представляешь, звоню ему вчера вечером предлагаю пойти погулять, а он отвечает: «извини, я тут ебусь с тремя неизвестными»!
*/