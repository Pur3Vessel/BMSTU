package main

import (
	"fmt"
	"os"
	"sort"
)

type graphVertex struct {
	name int
	graphEdges []int
	com int
}

func DFS(listIncidence *[]graphVertex)  int {
	island := 0
	for i, _ := range *listIncidence {
		if (*listIncidence)[i].com == -1 && len((*listIncidence)[i].graphEdges) != 0 {
			visitVertex(listIncidence, i, island)
			island += 2
		}
	}
	return island
}
func visitVertex(listIncidence *[]graphVertex, v int, island int)  {
	(*listIncidence)[v].com = island
	for _, e := range (*listIncidence)[v].graphEdges {
		if (*listIncidence)[v].com == (*listIncidence)[e].com {
			fmt.Println("No solution")
			os.Exit(0)
		}
		if (*listIncidence)[e].com == -1 {
			if island % 2 == 0 {
				visitVertex(listIncidence, e, island + 1)
			} else {
				visitVertex(listIncidence, e, island - 1)
			}
		}
	}
}
// Сравнивает две одинаковые по размеру группы
func compareGroups(g1, g2 []int)  []int{
	for i, _ := range g1 {
		if g1[i] > g2[i] {
			return g2
		}
		if g2[i] > g1[i] {
			return g1
		}
	}
	return g1
}
// Для сочетаний
func rekur(resultGroup *[]int, startGroup []int, GoodGays []int, soch []int, teamsList [][][]int, index int, n int)  {
	if index == len(teamsList) {
		tryGroup := startGroup
		for i, _ := range soch {
			if soch[i] == 0 {
				for _, v := range teamsList[i][0] {
					tryGroup = append(tryGroup, v)
				}
			} else {
				for _, v := range teamsList[i][1] {
					tryGroup = append(tryGroup, v)
				}
			}
		}
		c := 0
		for len(tryGroup) < n/2 {
			tryGroup = append(tryGroup, GoodGays[c])
			c++
		}
		sort.Ints(tryGroup)
		if len(tryGroup) <= n/2 && len(tryGroup) >= len(*resultGroup) {
			if len(tryGroup) > len(*resultGroup) {
				*resultGroup = tryGroup
			} else {
				*resultGroup = compareGroups(tryGroup, *resultGroup)
			}
		}
	} else {
		soch[index] = 0
		rekur(resultGroup, startGroup, GoodGays, soch, teamsList, index + 1, n)
		soch[index] = 1
		rekur(resultGroup, startGroup, GoodGays, soch, teamsList, index + 1, n)
	}
}
func main()  {
	listIncidence := make([]graphVertex, 0)
	var n int
	var sym string
	_, _ = fmt.Scan(&n)
	for i := 0; i < n; i++ {
		var shrek graphVertex
		shrek.com = -1
		shrek.name = i
		shrek.graphEdges = make([]int, 0)
		listIncidence = append(listIncidence, shrek)
	}
	for i := 0; i < n; i++ {
		for j := 0; j < n; j++ {
			if i > j {
				_, _ = fmt.Scan(&sym)
				continue
			} else {
				_, _ = fmt.Scan(&sym)
				if sym == "+" {
					listIncidence[i].graphEdges = append(listIncidence[i].graphEdges, j)
					listIncidence[j].graphEdges = append(listIncidence[j].graphEdges, i)
				}
			}
		}
	}
	// Цель обхода в глубину, рассмотеть двудольность графа по всем компонетам связности (если граф не двудольный - No solution)
	island := DFS(&listIncidence)

	var startTeam = make([]int, 0) // От нее начнется отбор команд
	var teamsList = make([][][]int, 0) // Страшно...
	// Смотрим все возможные группы антагонистов:
	for i := 0; i <= island; i += 2 {
		t1 := make([]int, 0)
		t2 := make([]int, 0)
		for _, v := range listIncidence {
			if v.com == i {
				t1 = append(t1, v.name)
			}
			if v.com == i + 1 {
				t2 = append(t2, v.name)
			}
		}
		if len(t1) == len(t2) { // Если длины равны, имеет смысл хранить только наименьшуюю
			t := compareGroups(t1 ,t2)
			for _, e := range t {
				startTeam = append(startTeam, e)
			}
		} else { // Иначе нет
			teamPair := make([][]int, 2)
			teamPair[0] = t1
			teamPair[1] = t2
			teamsList = append(teamsList, teamPair)
		}
	}
	sort.Ints(startTeam)
	// Составим массив дружелюбных ребят
	GoodGays := make([]int, 0)
	for _, v := range listIncidence {
		if v.com == -1 {
			GoodGays = append(GoodGays, v.name)
		}
	}
	// А теперь начинаем сочетать...
	resultTeam := startTeam
	soch := make([]int, len(teamsList))
	rekur(&resultTeam, startTeam, GoodGays, soch, teamsList, 0, n)
	for _, v := range resultTeam {
		fmt.Printf("%d ", v + 1)
	}
}
/* Царь-плотник, царь-шкипер, император-бомбардир Петр Первый иногда одевал простую одежду, ходил по своей новой, еще строящейся столице и беседовал с простыми людьми. Многие его не узнавали, что ни удивительно для того времени - ведь телевидения, интернета и газет ещё не было. Однажды вечером Пётр зашел в кабак, и там стал свидетелем того, как один солдат за выпивку заложил свой палаш - это такая прямая и тяжелая сабля. Переодетый и неузнанный царь спросил у своего солдата – как же он будет воевать без оружия?

Тот объяснил так: мол, я пока выстругаю деревянную палку и вложу её в ножны, а как только получу жалованье, так сразу выкуплю.

Наутро Пётр приехал в полк, в котором служил тот солдат, и устроил смотр. Прошел по рядам, узнал хитреца, остановился перед ним и приказал: "Руби меня палашом!".

Солдат, естественно, побледнел, вспотел, онемел, и замотал головой. Царь повторил: "Руби! Не то прикажу тебя повесить!"...

Делать нечего. Солдат схватился за деревянный эфес, и проорал в небо: "Господи Боже, обрати сие грозное оружие в древо!" – выждал эффектную паузу для преображения стали в деревяшку, и отрубил Петру голову.

Это был другой солдат.

 */