package main

import (
	"fmt"
	"sort"
)
// Состояние Мура
type state struct {
	q int
	y string
}

func ratatatata(crossover [][]int, states []state, input []string)  {
	fmt.Println("digraph {")
	fmt.Println("rankdir = LR")
	for i, _ := range states {
		fmt.Printf("%d [label = \"(%d,%s)\"]\n", i, states[i].q, states[i].y)
	}
	for i, _ := range crossover {
		for j, x := range crossover[i] {
			fmt.Printf("%d -> %d [label = \"%s\"]\n", i, x, input[j])
		}
	}
	fmt.Println("}")
}
// По факту
func SanyaLoh(states []state, shrek state)  int {
	for i, s := range states {
		if shrek.q == s.q && shrek.y == s.y {
			return i
		}
	}
	return -1
}
func main() {
	var n, m, cr, m1 int
	var sym string
	inputAlphabet := make([]string, 0)
	_, _ = fmt.Scan(&m)
	for i := 0; i < m; i++ {
		_, _ = fmt.Scan(&sym)
		inputAlphabet = append(inputAlphabet, sym)
	}
	outputAlphabet := make([]string, 0)
	_, _ = fmt.Scan(&m1)
	for i := 0; i < m1; i++ {
		_, _ = fmt.Scan(&sym)
		outputAlphabet = append(outputAlphabet, sym)
	}
	_, _ = fmt.Scan(&n)
	crossover := make([][]int, n)
	exit := make([][]string, n)
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
	// Составим массив состояний Мура
	states := make([]state, 0)
	for i, _ := range crossover {
		for j, x := range crossover[i] {
			var shrek state
			shrek.q = x
			shrek.y = exit[i][j]
			if SanyaLoh(states, shrek) == -1{
				states = append(states, shrek)
			}
		}
	}
	sort.Slice(states, func(i, j int) bool {
		return states[i].q < states[j].q
	})
	newCrossover := make([][]int, len(states))
	for i := 0; i < len(states); i++ {
		newCrossover[i] = make([]int, m)	
		for j := 0; j < m; j++ {
			var shrek state
			shrek.q = crossover[states[i].q][j]
			shrek.y = exit[states[i].q][j]
			newCrossover[i][j] = SanyaLoh(states, shrek)
		}
	}
	ratatatata(newCrossover, states, inputAlphabet)
}
/*
В самолете блюет пассажир. Все смеются.
Стюардесса видит, что скоро потечет через край пакета и бежит за вторым.
Когда вернулась, обнаруживает, что все блюют а один смеется.
Она спрашивает: - В чем дело? - Они думали что у меня через край польется, а я взял и отхлебнул.
 */