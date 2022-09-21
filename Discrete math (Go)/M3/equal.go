package main

import (
	"fmt"
	"os"
	"sort"
)
var count = 0
func ratatatata(exit [][]string, crossover [][]int, start int)  {
	fmt.Println("digraph {")
	fmt.Println("rankdir = LR")
	fmt.Println("dummy [label = \"\", shape = none]")
	for i, _ := range exit {
		fmt.Printf("%d [shape = circle]\n", i)
	}
	fmt.Printf("dummy -> %d\n", start)
	for i, _ := range crossover {
		for j, x := range crossover[i] {
			fmt.Printf("%d -> %d [label = \"%s(%s)\"]\n", i, x, string(j + 97), exit[i][j])
		}
	}
	fmt.Println("}")
}

type state struct {
	i int
	pii int
	depth int
	parent *state
	color int
	canon int
}

func canon(exit [][]string, crossover [][]int, mu int, start int)  ([][]string, [][]int){
	states := make([]*state, 0)
	for i := 0; i < len(crossover); i++ {
		var shrek state
		shrek.i = i
		shrek.color = 0
		shrek.canon = -1
		states = append(states, &shrek)
	}
	DFS(&states, crossover, mu, start)
	m := len(crossover)
	statesNorm := make([]*state, 0)
	for _, q := range states {
		statesNorm = append(statesNorm, q)
	}
	for i := 0; i < len(states); i++ {
		if states[i].canon == -1 {
			m--
			copy(states[i:], states[i+1:])
			states[len(states) - 1] = nil
			states = states[:len(states) - 1]
			i--
		}
	}
	canExit := make([][]string, 0)
	for i := 0; i < m; i++ {
		c := make([]string, mu)
		canExit = append(canExit, c)
	}

	canCrossover := make([][]int, 0)
	for i := 0; i < m; i++ {
		c := make([]int, mu)
		canCrossover = append(canCrossover, c)
	}
	sort.Slice(states, func(i, j int) bool {
		return states[i].canon < states[j].canon
	})
	for j, q := range states {
		for i := 0; i < mu; i++ {
			canCrossover[j][i] = statesNorm[crossover[q.i][i]].canon
		}
		canExit[j] = exit[q.i]
	}
	return canExit, canCrossover
}
func DFS(states *[]*state, crossover [][]int, mu int, v int)  {
	//fmt.Println(v, )
	(*states)[v].color = 1
	(*states)[v].canon = count
	count++
	for i := 0; i < mu; i++ {
		if (*states)[crossover[(*states)[v].i][i]].color == 0 {
			DFS(states, crossover, mu, crossover[(*states)[v].i][i])
		}
	}
}
func find(v *state)  *state {
	a := v
	for a.parent != a {
		a = a.parent
	}
	return a
}
func union(v, u *state)  {
	ancestor1 := find(v)
	ancestor2 := find(u)
	if ancestor1.depth > ancestor2.depth {
		ancestor2.parent = ancestor1
	} else {
		if ancestor1.depth == ancestor2.depth {
			ancestor1.depth++
			ancestor2.parent = ancestor1
		} else {
			ancestor1.parent = ancestor2
		}
	}

}
func split1(exit [][]string, mu int, states []*state)  (int, []*state){
	pi := make([]*state, len(states))
	m := len(states)
	for _, q := range states {
		q.depth = 0
		q.parent = q
	}
	for k, q1 := range states {
		for j, q2 := range states {
			if j <= k {
				continue
			}
			if find(q1) != find(q2) {
				eq := true
				for i := 0; i < mu; i++ {
					if exit[q1.i][i] != exit[q2.i][i] {
						eq = false
						break
					}
				}
				if eq {
					union(q1, q2)
					m--
				}
			}
		}
	}
	for _, q := range states {
		pi[q.i] = find(q)
	}
	return m, pi
}
func indexOf(s []int, a int)  bool {
	for _, h := range s {
		if h == a {
			return true
		}
	}
	return false
}
// Вообще эта фунция делалать для другого, но ее можно упростить. Ее задача - уменьшить числа у вершин состояний
// Чтоб можно было 2 раз сделать canon в этой кривой проге)
func supports(pi []*state)  []*state {
	var max = make([]int, 0)
	for _, q := range pi {
		q.pii = q.i
		if !indexOf(max, q.i) {
			max = append(max, q.i)
		}
	}
	var min = 100000000
	for i := 0; i < len(max); i++ {
		e := true
		for _, q := range pi {
			if q.pii == i {
				e = false
				break
			}
			if q.pii < min && q.pii > i{
				min = q.pii
			}
		}
		if e {
			for _, q := range pi {
				if q.pii == min {
					q.pii = i
				}
			}
		}
		min = 100000000
	}
	return pi
}
func Split(crossover [][]int, mu int, states []*state, pi[]*state)  (int, []*state) {
	m := len(states)
	for _, q := range states {
		q.depth = 0
		q.parent = q
	}
	for k, q1 := range states {
		for j, q2 := range states {
			if j <= k {
				continue
			}
			if  find(q1) != find(q2) && pi[q1.i] == pi[q2.i] {
				eq := true
				for i := 0; i < mu; i++ {
					w1 := crossover[q1.i][i]
					w2 := crossover[q2.i][i]
					if pi[w1] != pi[w2] {
						eq = false
					}
				}
				if eq {
					union(q1, q2)
					m--
				}
			}
		}
	}
	for _, q := range states {
		pi[q.i] = find(q)
	}
	return m, pi
}
// Чтоб состояние не повторялись
func fofaind(states []*state, qq *state)  bool {
	for _, q := range states {
		if qq == q {
			return true
		}
	}
	return false
}
func AufenkampHohn(crossover [][]int, exit [][]string, mu int, start int)  ([][]int, [][]string){
	states := make([]*state, 0)
	for i := 0; i < len(crossover); i++ {
		var shrek state
		shrek.i = i
		states = append(states, &shrek)
	}
	m, pi := split1(exit, mu, states)

	for {
		var m1 int
		m1, pi = Split(crossover, mu, states, pi)
		if m == m1 {
			break
		}
		m = m1
	}
	papich := make([]*state, 0)
	exitMin := make([][]string, 0)
	crossoverMin := make([][]int, 0)

	pi = supports(pi)
	//fmt.Println()
	//for _, q := range pi {
	//	fmt.Println(*q)
	//}


	for _, q := range states {
		papanyaTheGreat := pi[q.i]
		if !fofaind(papich, papanyaTheGreat) {
			papich = append(papich, papanyaTheGreat)
			eBuf := make([]string, 0)
			cBuf := make([]int, 0)
			for i := 0; i < mu; i++ {
				cBuf = append(cBuf, pi[crossover[q.i][i]].pii)
				eBuf = append(eBuf, exit[q.i][i])
			}
			exitMin = append(exitMin, eBuf)
			crossoverMin = append(crossoverMin, cBuf)
		}
	}
	return crossoverMin, exitMin
}
func main() {
	var n, m, start, cr, start1, m1, n1 int
	var sym string
	_, _ = fmt.Scan(&n)
	crossover := make([][]int, n)
	exit := make([][]string, n)
	_, _ = fmt.Scan(&m)
	_, _ = fmt.Scan(&start)
	for i := 0; i < n; i++ {
		crossover[i] = make([]int, 0)
		for j := 0; j < m; j++ {
			_, _ = fmt.Scan(&cr)
			crossover[i] = append(crossover[i], cr)
		}
	}
	for i := 0; i < n; i++ {
		exit[i] = make([]string, 0)
		for j := 0; j < m; j++ {
			_, _ = fmt.Scan(&sym)
			exit[i] = append(exit[i], sym)
		}
	}
	_, _ = fmt.Scan(&n1)
	crossover1 := make([][]int, n1)
	exit1 := make([][]string, n1)
	_, _ = fmt.Scan(&m1)
	_, _ = fmt.Scan(&start1)
	for i := 0; i < n1; i++ {
		crossover1[i] = make([]int, 0)
		for j := 0; j < m1; j++ {
			_, _ = fmt.Scan(&cr)
			crossover1[i] = append(crossover1[i], cr)
		}
	}
	for i := 0; i < n1; i++ {
		exit1[i] = make([]string, 0)
		for j := 0; j < m1; j++ {
			_, _ = fmt.Scan(&sym)
			exit1[i] = append(exit1[i], sym)
		}
	}
	exit, crossover = canon(exit, crossover, m, start)
	crossoverMin, exitMin := AufenkampHohn(crossover, exit, m, 0)
	count = 0
	exitMin ,crossoverMin = canon(exitMin, crossoverMin, m, 0)
	count = 0
	exit1, crossover1 = canon(exit1, crossover1, m1, start1)
	count = 0
	crossoverMin1, exitMin1 := AufenkampHohn(crossover1, exit1, m1, 0)
	exitMin1, crossoverMin1 = canon(exitMin1, crossoverMin1, m1, 0)
	if len(crossoverMin) == len(crossoverMin1) && len(crossoverMin[0]) == len(crossoverMin1[0]) {
		for i := 0; i < len(crossoverMin); i++ {
			for j := 0; j < len(crossoverMin[0]); j++ {
				if crossoverMin[i][j] != crossoverMin1[i][j] || exitMin[i][j] != exitMin1[i][j] {
					fmt.Println("NOT EQUAL")
					os.Exit(0)
				}
			}
 		}
 		fmt.Println("EQUAL")
	} else {
		fmt.Println("NOT EQUAL")
	}
}
/*
Слепой заходит в магазин, берет собаку–поводыря и начинает раскручивать её над головой.
— Мужчина, что вы делаете?!!
— Да так, осматриваюсь...
 */