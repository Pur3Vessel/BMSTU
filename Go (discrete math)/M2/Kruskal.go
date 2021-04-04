package main

import (
	"fmt"
	"math"
	"sort"
)


// Непосредственно вершины
type Attraction struct {
	x, y int
	ancestor *Attraction // нужно, чтобы делать проверку на цикличность, а затем объединять
	dependence int  // показывает степень зависимости других вершин от этой:
					// насколько "выше" располагается эта вершина в остовном дереве (грубо говоря: сколько раз нужно совершить итераций find'а
}
// Ребрышки
type Path struct {
	length int // для небольшой оптимизации берется без квадратного корня
	father1, father2 *Attraction
}
// Находит самого "старшего" предка
// Нужно для сравнения (чтобы не сделать цикл) и для объединения
func find(v *Attraction)  *Attraction {
	a := v
	for a.ancestor != nil {
		a = a.ancestor
	}
	return a
}
// Объединение
// Происходит посредством присоединения предка с более младшей зависимостью к предку с более старшей
// ("Веточка приделывается к абстрактному дереву")
func union(v, u *Attraction)  {
	ancestor1 := find(v)
	ancestor2 := find(u)
	if ancestor1.dependence > ancestor2.dependence {
		ancestor2.ancestor = ancestor1
	} else {
		if ancestor1.dependence == ancestor2.dependence {
			ancestor1.dependence++
			ancestor2.ancestor = ancestor1
		} else {
			ancestor1.ancestor = ancestor2
		}
	}

}
// Проще будет не формировать новое множество E', а сразу подсчитывать итоговую длину
// (И время и память будет довольны)
// При этом сравнение длин множеств E' и V(G), поскольку у двух элементов уже сформированного дерева будет один и тот же главный предок
func spanningTree(roads []Path, m int)  float64 {
	var short float64
	short = 0
	for i := 0; i < m; i++ {
		father1 := roads[i].father1
		father2 := roads[i].father2
		//fmt.Println(i)
		if find(father1) != find(father2) {
			//fmt.Println(find(father1), find(father2))
			short += math.Sqrt(float64(roads[i].length))
			union(father1, father2)
		}
	}
	return short
}
func MST_Kruskal(roads []Path, m int) float64 {
	sort.Slice(roads, func(i, j int) bool {
		return roads[i].length < roads[j].length
	})
	short := spanningTree(roads, m)
	return short
}
func main()  {
	//t := time.Now()
	var n, x, y int
	r := 0
	var shortPath float64
	var osel Attraction
	var shrek Path
	fmt.Scan(&n)
	lenRoad := n*(n-1)/2
	park := make([]Attraction, n)
	roads := make([]Path, lenRoad)
	for i := 0; i < n; i++ {
		fmt.Scanf("%d %d", &x, &y)
		osel.x = x
		osel.y = y
		osel.ancestor = nil
		osel.dependence = 1
		park[i] = osel
	}
	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ {
			shrek.father1 = &park[i]
			shrek.father2 = &park[j]
			shrek.length = (park[i].x-park[j].x)*(park[i].x-park[j].x) + (park[i].y-park[j].y)*(park[i].y-park[j].y)
			//fmt.Println(time.Since(t))
			roads[r] = shrek
			r++
		}
	}
	shortPath = MST_Kruskal(roads, lenRoad)
	sort.Slice(roads, func(i, j int) bool {
		return roads[i].length < roads[j].length
	})

	fmt.Printf("%.2f\n",shortPath)
	//fmt.Println(time.Since(t))
}
//Один программист так эффективно использовал loop' ы в своем коде, что в конце месяца ему выдали премию за loop' ы.