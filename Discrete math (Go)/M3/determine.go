package main

import (
	"fmt"
	"sort"
)

type edge struct {
	to int
	word string
}

type stack struct {
	data [][]int
	top int
}

func (s *stack) push(vertex []int)  {
	s.data[s.top] = vertex
	s.top++
}
func (s *stack) pop() []int {
	s.top--
	return s.data[s.top]
}
func dfs(crossover [][]edge, q int, c *[]int, isState*(map[int]bool)) {
	_, ok := (*isState)[q]
	if !ok {
		(*isState)[q] = true
		*c = append(*c, q)
		for _, v := range crossover[q]{
			if v.word == "lambda" {
				dfs(crossover, v.to, c, isState)
			}
		}
	}
}
func closure(crossover [][]edge, z []int)  []int {
	var c = make([]int, 0)
	var isState = make(map[int]bool)
	for _, x := range z {
		dfs(crossover, x, &c, &isState)
	}
	sort.Ints(c)
	return c
}
func in(states [][]int, z []int)  bool {
	for _, z1 := range states {
		if len(z) == len(z1) {
			nope := true
			for i, x := range z {
				if x != z1[i] {
					nope = false
					break
				}
			}
			if nope {
				return true
			}
		}
	}
	return false
}
func operator (s1 []int, s2 []int)  bool{
	if len(s1) != len(s2) {
		return false
	}
	for i, x := range s1 {
		if x != s2[i] {
			return false
		}
	}
	return true
}
func det(alphabet []string, crossover [][]edge, final []int, start int) ([][]int, [][]int, [][]int){
	var z = make([]int, 0)
	ch := 0
	z = append(z, start)
	q0 := closure(crossover, z)
	var s stack
	s.data = make([][]int, 100)
	s.top = 0
	s.push(q0)
	var F = make([][]int, 0)
	var states = make([][]int, 0)
	states = append(states, q0)
	var zv = make([][]int, 0)
	var d = make([][][]int, 1)
	for s.top > 0 {
		z = s.pop()
		for _, u := range z {
			if final[u] == 1 {
				F = append(F, z)
			}
		}
		for i, a := range alphabet {
			var delta_u = make([]int, 0)
			for _, x := range z {
				for _, y := range crossover[x] {
					if y.word == a {
						delta_u = append(delta_u, y.to)
					}
				}
			}
			z1 := closure(crossover, delta_u)
			if !in(states, z1) {
				states = append(states, z1)
				s.push(z1)
				var h [][]int
				d = append(d, h)
			}
			if i == 0 {
				zv = append(zv, z)
				ch++
			}
			d[ch - 1] = append(d[ch - 1], z1)
 		}
	}
	var delta = make([][]int, len(d))
	for i := 0; i < len(d); i++ {
		delta[i] = make([]int, len(alphabet))
	}
	for i, x := range d {
		for y, _ := range alphabet {
			h := 0
			for _, xx := range zv {
				if operator(xx, x[y]) {
					break
				}
				h++
			}
			delta[i][y] = h
		}
	}
	return delta, zv, F
}
func main() {
	var m, n, start, i, num, to int
	var sym string
	_, _ = fmt.Scan(&n)
	_, _ = fmt.Scan(&m)
	var crossover = make([][]edge, n) // crossover[i] - массив i-тых исходных состояний
	for i = 0; i < n; i++ {
		crossover[i] = make([]edge, 0)
	}
 	var accept = make([]int, n)
	var alphabet = make([]string,0)
	var isSym = make(map[string]bool) // Добавление строк в алфавит
	for i = 0; i < m; i++ {
		_, _ = fmt.Scan(&num, &to, &sym)
		var shrek edge
		shrek.to = to
		shrek.word = sym
		crossover[num] = append(crossover[num], shrek)
		_, ok := isSym[sym]
		if !ok && sym != "lambda" {
			isSym[sym] = true
			alphabet = append(alphabet, sym)
		}
	}
	for i = 0; i < n; i++ {
		_, _ = fmt.Scan(&accept[i])
	}
	_, _ = fmt.Scan(&start)
	delta, zv, f := det(alphabet, crossover, accept ,start)
	fmt.Println("digraph {")
	fmt.Println("rankdir = LR")
	fmt.Println("dummy [label = \"\", shape = none]")

	for i, x := range zv {
		var b bool
		for _, ff := range f {
			b = operator(ff, x)
			if b {
				break
			}
		}
		if b {
			fmt.Printf("%d [label = \"%v\", shape = doublecircle]\n", i, x)
		} else {
			fmt.Printf("%d [label = \"%v\", shape = circle]\n", i, x)
		}
	}
	fmt.Println("dummy -> 0")
	for i, x := range delta {
		var isState = make(map[int]bool)
		for y, a := range alphabet {
			_, ok := isState[x[y]]
			if !ok {
				isState[x[y]] = true
				fmt.Printf("%d -> %d [label = \"%s", i, x[y], a)
				for q := y + 1; q < len(alphabet); q++ {
					if x[q] == x[y] {
						fmt.Printf(", %s", alphabet[q])
					}
				}
				fmt.Println("\"]")
			}
		}
	}
	fmt.Println("}")
 }
 // Если мысли сходятся, то они ограничены.