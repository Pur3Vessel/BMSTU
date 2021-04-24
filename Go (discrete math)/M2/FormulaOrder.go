package main

import (
	"bufio"
	"fmt"
	//"github.com/skorobogatov/input"
	"os"
	"sort"
	"strings"
)
var fVert = make(map[string]int) // Соотносит переменные и вершины, которые их содержат
type Tag int
var t1 = 0
type Lexem struct {
	Tag
	Image string
}
const (
	ERROR Tag = 1 << iota
	NUMBER
	VAR
	PLUS
	MINUS
	MUL
	DIV
	LPAREN
	RPAREN
)
type graphVertex struct {
	name int
	formula string
	output string
	graphEdges []int
	color int // 0 - white, 1- gray, 2 - black
	exit int
}
// "Скипать", пока идет число
func getNum (expr string, ind int, length int)  int{

	for ind < length && expr[ind] >= 48 && expr[ind] <= 57  {
		ind++
	}
	return ind
}
// "Скипать", пока идет переменная
func getVar(expr string, ind int, length int)  int{
	for ind < length && ((expr[ind] >= 48 && expr[ind] <= 57) || (expr[ind] >= 65 && expr[ind] <= 90) || (expr[ind] >= 97 && expr[ind] <= 122))  {
		ind++
	}
	return ind
}
func lexer(expr string, lexems []Lexem, length int) []Lexem {
	var closeIndex int
	var el Lexem
	for i := 0; i < length; i++ {
		switch expr[i] {
		// (
		case 40:
			el.Tag = 128
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		// )
		case 41:
			el.Tag = 256
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		// *
		case 42:
			el.Tag = 32
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		// +
		case 43:
			el.Tag = 8
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		// -
		case 45:
			el.Tag = 16
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		// /
		case 47:
			el.Tag = 64
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		// Перенос строки
		case 10:
			continue
		// Пробел
		case 32:
			continue
		default:
			if expr[i] >= 48 && expr[i] <= 57 {
				closeIndex = getNum(expr, i, length)
				el.Tag = 2
				el.Image = expr[i : closeIndex]
				lexems = append(lexems, el)
				i = closeIndex - 1
			} else {
				if (expr[i] >= 65 && expr[i] <= 90) || (expr[i] >= 97 && expr[i] <= 122) {
					closeIndex = getVar(expr, i, length)
					el.Tag = 4
					el.Image = expr[i : closeIndex]
					lexems = append(lexems, el)
					//fmt.Println(el.Image)
					i = closeIndex - 1
				} else {
					el.Tag = 1
					lexems = append(lexems, el)
				}
			}
			break
		}
	}
	return lexems
}
//<E>
func parseExpr(index *int, length, c int, lexArr []Lexem, listIncidence *[]graphVertex)  {
	parseTT(index, length, c ,lexArr, listIncidence)
	parseE(index, length, c ,lexArr, listIncidence)
}
//<E`>
func parseE(index *int, length, c int, lexArr []Lexem, listIncidence *[]graphVertex)  {
	var lx Lexem
	if *index < length {
		lx = lexArr[*index]
	}
	//fmt.Println("E: " ,lx.Image, lx.Tag)
	if lx.Tag & PLUS != 0 {
		*index++
		parseTT(index, length, c ,lexArr, listIncidence)
		parseE(index, length, c ,lexArr, listIncidence)

	}
	if lx.Tag & MINUS != 0 {
		*index++
		parseTT(index, length, c ,lexArr, listIncidence)
		parseE(index, length, c ,lexArr, listIncidence)
	}
	if lx.Tag & (VAR | NUMBER | ERROR) != 0 {
		//fmt.Println(1)
		fmt.Println("syntax error")
		os.Exit(0)
	}
}
//<T>
func parseTT(index *int, length, c int, lexArr []Lexem, listIncidence *[]graphVertex)  {
	parseF(index, length, c ,lexArr, listIncidence)
	parseT(index, length, c ,lexArr, listIncidence)
}
//<T`>
func parseT(index *int, length, c int, lexArr []Lexem, listIncidence *[]graphVertex)  {
	var lx Lexem
	if *index < length {
		lx = lexArr[*index]
	}
	//fmt.Println(*index)
	//fmt.Println("T:" ,lx.Image, lx.Tag)
	if lx.Tag & DIV != 0 {
		*index++
		parseF(index, length, c ,lexArr, listIncidence)
		parseT(index, length, c ,lexArr, listIncidence)

	}
	if lx.Tag & MUL != 0 {
		*index++
		parseF(index, length, c ,lexArr, listIncidence)
		parseT(index, length, c ,lexArr, listIncidence)
	}
	if lx.Tag & (VAR | NUMBER | ERROR) != 0 {
		//fmt.Println(2)
		fmt.Println("syntax error")
		os.Exit(0)
	}

}

//<F>
func parseF(index *int, length,c int, lexArr []Lexem, listIncidence *[]graphVertex)  {
	var lx Lexem
	if *index < length {
		lx = lexArr[*index]
	} else {
		//fmt.Println(3)
		fmt.Println("syntax error")
		os.Exit(0)
	}
	//fmt.Println("F: ", lx.Image, lx.Tag)
	if lx.Tag & (ERROR | RPAREN | PLUS | DIV | MUL | ERROR)!= 0 {
		//fmt.Println(4)
		fmt.Println("syntax error")
		os.Exit(0)
	}
	if lx.Tag & VAR != 0 {
		*index++
		n, ok := fVert[lx.Image]
		if !ok {
			fmt.Println("syntax error")
			os.Exit(0)
		}
		if indexOf((*listIncidence)[n].graphEdges, c) == -1 {
			(*listIncidence)[n].graphEdges = append((*listIncidence)[n].graphEdges, c)
		}
	}
	if lx.Tag & NUMBER != 0 {
		*index++
	}
	if lx.Tag & MINUS != 0 {
		*index++
		parseF(index, length, c ,lexArr, listIncidence)
	}
	if lx.Tag & LPAREN != 0 {
		*index++
		parseExpr(index, length, c ,lexArr, listIncidence)
		if *index < length {
			lx = lexArr[*index]
			*index++
		}
		if lx.Tag & RPAREN == 0{
			//fmt.Println(5)
			fmt.Println("syntax error")
			os.Exit(0)
		}
	}

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
func DFS(listIncidence *[]graphVertex)  {
	for i, _ := range *listIncidence {
		if (*listIncidence)[i].color == 0 {
			visitVertex(listIncidence, i)
		}
		if (*listIncidence)[i].color == 1 {
			fmt.Println("cycle")
			os.Exit(0)
		}
	}
}
func visitVertex(listIncidence *[]graphVertex, v int)  {
	(*listIncidence)[v].color = 1
	for _, e := range (*listIncidence)[v].graphEdges {
		if (*listIncidence)[e].color == 0 {
			visitVertex(listIncidence, e)
		}
		if (*listIncidence)[e].color == 1 {
			fmt.Println("cycle")
			os.Exit(0)
		}
	}
	(*listIncidence)[v].exit = t1
	t1++
	(*listIncidence)[v].color = 2
}
// Проверка имени переменной
func check(v string)  {
	if (v[0] < 65 || v[0] > 90) && (v[0] < 97 || v[0] > 122) {
		fmt.Println("syntax error")
		os.Exit(0)
	}
	for i := 1; i < len(v); i++ {
		if (v[i] < 65 || v[i] > 90) && (v[i] < 97 || v[i] > 122) && (v[i] < 48 || v[i] > 57) {
			fmt.Println("syntax error")
			os.Exit(0)
		}
	}
}
func main()  {
	// В вводе из строки сначала выпиливаются все пробелы, затем просходит проверка на одинаковое количество запятых и на эксклюзивность переменных
	var f string = " "
	listIncidence := make([]graphVertex, 0)
	var f1, f2 string
	c := 0
	var shrek graphVertex
	sc := bufio.NewScanner(os.Stdin)
	for sc.Scan() {
		f = sc.Text()
		if f == "" {
			break
		}
		out := f
		f = strings.Replace(f, " ", "", -1)
		cuttingPoint := strings.Index(f, "=")
		if cuttingPoint == -1 {
			fmt.Println("syntax error")
			os.Exit(0)
		}
		f1 = f[:cuttingPoint]
		f2 = f[cuttingPoint + 1:]
		if f1 == "" || f2 == "" {
			fmt.Println("syntax error")
			os.Exit(0)
		}
		z1 := 0
		z2 := 0
		for strings.Index(f1, ",") != -1 || strings.Index(f2, ",") != -1{
			cut1 := strings.Index(f1, ",")
			cut2 := strings.Index(f2, ",")
			if cut1 != -1 {
				z1++
			}
			if cut2 != -1 {
				z2++
			}
			if cut1 == -1 {
				break
			}
			f3 := f1[:cut1]
			if _, ok := fVert[f3]; ok {
				fmt.Println("syntax error")
				os.Exit(0)
			}
			check(f3)
			fVert[f3] = c
			f1 = f1[cut1 + 1:]
			f2 = f2[cut2 + 1:]
		}
		if z1 != z2 {
			fmt.Println("syntax error")
			os.Exit(0)
		}
		if _, ok := fVert[f1]; ok {
			fmt.Println("syntax error")
			os.Exit(0)
		}
		check(f1)
		fVert[f1] = c
		if z1 != z2 {
			fmt.Println("syntax error")
			os.Exit(0)
		}
		f1 = f[:cuttingPoint]
		shrek.name = c
		shrek.formula = f
		shrek.graphEdges = make([]int, 0)
		shrek.color = 0
		shrek.output = out
		listIncidence = append(listIncidence, shrek)
		c++
	}
	// Задачи парсера - проверить формулы на синт. ошибки и задать дуги
	for i, _ := range listIncidence {
		cuttingPoint := strings.Index(listIncidence[i].output, "=")
		ex := listIncidence[i].output[cuttingPoint + 1:]
		for strings.Index(ex, ",") != -1{
			ex1 := ex[:strings.Index(ex, ",")]
			lexArr := make([]Lexem, 0)
			lexArr = lexer(ex1, lexArr, len(ex1))
			//for _, v := range lexArr {
			//	fmt.Println(v.Image, v.Tag)
			//}
			index := 0
			parseExpr(&index, len(lexArr), i, lexArr, &listIncidence)
			ex = ex[strings.Index(ex, ",") + 1:]
		}
		lexArr := make([]Lexem, 0)
		lexArr = lexer(ex, lexArr, len(ex))
		//for _, v := range lexArr {
			//fmt.Println(v.Image, v.Tag)
		//}
		index := 0
		parseExpr(&index, len(lexArr), i, lexArr, &listIncidence)
	}
	//for _, v := range listIncidence {
		//fmt.Println(v.formula, v.graphEdges)
	//}
	//for i, v := range fVert {
		//fmt.Println(i , v)
	//}
	DFS(&listIncidence)
	sort.Slice(listIncidence, func(i, j int) bool {
		return listIncidence[i].exit > listIncidence[j].exit
	})
	for _, v := range listIncidence {
		fmt.Println(v.output)
	}
}
/*
Пришел зек из тюрьмы - отгулял с женой за встречу, ну, как принято, бутылочку уговорили. Ну, зек за бутылочкой жене про зону рассказывает, про понятия блатные.
Наутро просыпаются - она ему:
- Вась, вот я вчера про все понятия поняла, только про пидора расскажи поподробней.
Он ей:
- Ну какая ты, Маруся, бестолковая! Вот тебе пример - подходит ко мне утром Федька и говорит
- давай, Вась, я тебя сейчас в жопу трахну, а вечером тушенку занесу.
Жена ему:
- Ну?
- Да не занес, пидор.
*/