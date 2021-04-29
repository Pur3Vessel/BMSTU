package main

import (
	"bufio"
	"fmt"
	"os"
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
// Думаю, что будет удобно парсить каждую функцию по-отдельности
// <function> ::= <ident>(<formal-args-list>) := <expr>;
// <formal-args-list> ::= <ident> <ident-list> | e
// <ident-list> ::= , <ident> | e
// <expr> ::= <comparison_expr> <next_expr>
// <next_expr> ::= ? <comparison_expr> : <expr> | e
// <comparison_expr> ::= <arith_expr> <end_comp>
// <end_comp> ::= <comparison_op> <arith_expr> | e
// <comparison_op> ::= = | <> | < | > | <= | >=
// Для парсера arith_expr актуальна часть с arith.go (только там еще добавляется ident со скобочками):
// <factor> ::= <number> | (<expr>) | - <factor> | <s_ident>
// <s_ident> ::= <ident> <e_ident>
// <e_ident> ::= (<actual_args_list>) | e
// <actual_args_list> ::= <expr-list> | e
// <expr-list> :: = <expr> <end_list>
// <end-list> :: = ,<expr> | e
type Tag int
type callFunc struct {
	name string // ее имя
	count int // кол-во ее параметров
}
var names = make([]string, 0)
var call = make([]callFunc, 0)
var ohShitImSorry = make(map[string]int) // функция -> кол-во ее формальных параметров
var fArgsNames = make(map[string][]string) // функия -> имена ее аргументов
var fVert = make(map[string]int) // функция -> номер вершины
var nVert = 0
var fZav = make(map[string][]string) // зависимости
const (
	ERROR Tag = 1 << iota
	NUMBER  // 2
	VAR  // 4
	PLUS // 8
	MINUS // 16
	MUL // 32
	DIV // 64
	LPAREN // 128
	RPAREN // 256
	COMMA // 512
	QUESTION // 1024
	COLON // 2048
	SEMICOLON // 4096
	EQUALLY //8192
	MORE // 16 384
	LESS // 32768
)
type Lexem struct {
	Tag
	Image string
}
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
		case 44:
			el.Tag = 512
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		case 63:
			el.Tag = 1024
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		case 58:
			el.Tag = 2048
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		case 59:
			el.Tag = 4096
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		case 61:
			el.Tag = 8192
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		case 62:
			el.Tag = 16384
			el.Image = expr[i:i+1]
			lexems = append(lexems, el)
			break
		case 60:
			el.Tag = 32768
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
func indexOf(slice []string, element string) int {
	for i, x := range slice {
		if x == element {
			return i
		}
	}
	return -1
}
func parse_program(lexArr []Lexem, i *int, listIncidence *[]graphVertex)  {
	for *i < len(lexArr) {
		//fmt.Printf("Парсим функцию которая начинается с %s\n", lexArr[*i].Image)
		parse_func(lexArr, i, listIncidence)
	}
}
func parse_func(lexArr []Lexem, i *int, listIncidence *[]graphVertex)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("Прочли переменную %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & VAR == 0 {
		//fmt.Println(2)
		fmt.Println("error")
		os.Exit(0)
	}
	fName := lx.Image
	fVert[fName] = nVert
	nVert++
	fZav[fName] = make([]string, 0)
	names = append(names, fName)
	*i++
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	if lx.Tag & LPAREN == 0 {
		//fmt.Println(3)
		fmt.Println("error")
		os.Exit(0)
	}
	*i++
	parse_formal_list(lexArr, i, fName, 0)
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	if lx.Tag & COLON== 0 {
		//fmt.Println(4)
		fmt.Println("error")
		os.Exit(0)
	}
	*i++
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	if lx.Tag & EQUALLY == 0 {
		//fmt.Println(5)
		fmt.Println("error")
		os.Exit(0)
	}
	*i++
	parse_expr(lexArr, i, listIncidence, fName)
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	if lx.Tag & SEMICOLON == 0 {
		//fmt.Println(666)
		fmt.Println("error")
		os.Exit(0)
	}
	*i++
}
func parse_formal_list(lexArr []Lexem, i *int, fun string, c int)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Println("Парсим список аргументов")
	fArgsNames[fun] = make([]string, 0)
	if lx.Tag & (VAR | RPAREN) != 0 {
		if lx.Tag & RPAREN != 0 {
			ohShitImSorry[fun] = c
			*i++
		} else {
			*i++
			fArgsNames[fun] = append(fArgsNames[fun], lx.Image)
			parse_ident_list(lexArr, i, fun, c + 1)
		}
	} else {
		//fmt.Println(6)
		fmt.Println("error")
		os.Exit(0)
	}
}
func parse_ident_list(lexArr []Lexem, i *int, fun string, c int) {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("IDENT LIST %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & RPAREN != 0 {
		ohShitImSorry[fun] = c
		*i++
	} else {
		if lx.Tag & COMMA == 0 {
			//fmt.Println(7)
			fmt.Println("error")
			os.Exit(0)
		}
		*i++
		if *i < len(lexArr) {
			lx = lexArr[*i]
		}
		//fmt.Printf("Ident continue %s %d\n", lexArr[*i].Image, *i)
		if lx.Tag & VAR != 0 {
			fArgsNames[fun] = append(fArgsNames[fun], lx.Image)
			*i++
			parse_ident_list(lexArr, i, fun, c+1)
		} else {
			//fmt.Println(8)
			fmt.Println("error")
			os.Exit(0)
		}
	}

}
func parse_expr(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	//fmt.Println("Парсим очередное expr")
	parse_compration_expr(lexArr, i, listIncidence, fName)
	//fmt.Printf("Вышли с comparison на позиции %s %d\n", lexArr[*i].Image, *i)
	parse_next_expr(lexArr, i, listIncidence, fName)
	//fmt.Printf("Вышли с next на позиции %s %d\n", lexArr[*i].Image, *i)
}
func parse_compration_expr(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	//fmt.Printf("Парсим очередное compration\n")
	parse_arith_expr(lexArr, i, listIncidence, fName)
	//fmt.Printf("Вышлли из arith на позиции %s %d\n", lexArr[*i].Image, *i)
	parse_end_comp(lexArr, i, listIncidence, fName)
}
func parse_next_expr(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("next стартует с %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & QUESTION != 0 {
		*i++
		parse_compration_expr(lexArr, i, listIncidence, fName)
		if *i < len(lexArr) {
			lx = lexArr[*i]
		}
		//fmt.Printf("next продолжает на %s %d\n", lexArr[*i].Image, *i)
		if lx.Tag & COLON == 0 {
		//	fmt.Println(9)
			fmt.Println("error")
			os.Exit(0)
		}
		*i++
		parse_expr(lexArr, i, listIncidence, fName)
	}
}
func parse_arith_expr(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	//fmt.Printf("Парсим очередное arith\n")
	parse_t(lexArr, i, listIncidence, fName)
	parse_ea(lexArr, i, listIncidence, fName)
}
func parse_end_comp(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("end_comp на позиции %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & (LESS | MORE | EQUALLY) != 0 {
		parse_comparison_expr(lexArr, i, listIncidence, fName)
		parse_arith_expr(lexArr, i, listIncidence, fName)
	}
}
func parse_comparison_expr(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("comparison на позиции %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & EQUALLY != 0 {
		*i++
	} else {
		if lx.Tag & LESS != 0 {
			*i++
			if *i < len(lexArr) {
				lx = lexArr[*i]
			}
			if lx.Tag & (MORE | EQUALLY) != 0 {
				*i++
			}
		} else {
			*i++
			if *i < len(lexArr) {
				lx = lexArr[*i]
			}
			if lx.Tag & (LESS | EQUALLY) != 0 {
				*i++
			}
		}
	}
}
func parse_ea(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("Плюсики на позиции %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & PLUS != 0 {
		*i++
		parse_t(lexArr, i, listIncidence, fName)
		parse_ea(lexArr, i, listIncidence, fName)
	}
	if lx.Tag & MINUS != 0 {
		*i++
		parse_t(lexArr, i, listIncidence, fName)
		parse_ea(lexArr, i, listIncidence, fName)
	}
	if lx.Tag & (VAR | NUMBER | ERROR) != 0 {
		//fmt.Println(10)
		fmt.Println("error")
		os.Exit(0)
	}
}
func parse_t(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	parse_f(lexArr, i, listIncidence, fName)
	parse_et(lexArr, i, listIncidence, fName)
}
func parse_et(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("Умножение на позиции %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & DIV != 0 {
		*i++
		parse_f(lexArr, i, listIncidence, fName)
		parse_et(lexArr, i, listIncidence, fName)
	}
	if lx.Tag & MUL != 0 {
		*i++
		parse_f(lexArr, i, listIncidence, fName)
		parse_et(lexArr, i, listIncidence, fName)
	}
	if lx.Tag & (VAR | NUMBER | ERROR) != 0 {
		//fmt.Println(11)
		fmt.Println("error")
		os.Exit(0)
	}
}
func parse_f(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	} else {
		//fmt.Println(12)
		fmt.Println("error")
		os.Exit(0)
	}
	//fmt.Printf("Переменная на позиции %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & (VAR | NUMBER | MINUS | LPAREN) == 0 {
		//fmt.Println(13)
		fmt.Println("error")
		os.Exit(0)
	}
	if lx.Tag & VAR != 0 {
		pogon := lx.Image
		*i++
		if *i < len(lexArr) {
			lx = lexArr[*i]
		}
		if lx.Tag & LPAREN != 0 {
			if indexOf(fZav[fName], pogon) == -1 {
				fZav[fName] = append(fZav[fName], pogon)
			}
			c := 1
			*i++
			parse_actual_args(lexArr, i, listIncidence, fName, &c)
			var cal callFunc
			cal.count = c
			cal.name = pogon
			call = append(call, cal)
			var nul Lexem
			lx = nul
		} else {
			if indexOf(fArgsNames[fName], pogon) == -1 {
				//fmt.Println(777)
				fmt.Println("error")
				os.Exit(0)
			}
		}
	}
	if lx.Tag & NUMBER != 0 {
		*i++
	}
	if lx.Tag & MINUS != 0 {
		*i++
		parse_f(lexArr, i, listIncidence, fName)
	}
	if lx.Tag & LPAREN != 0 {
		*i++
		parse_expr(lexArr, i, listIncidence, fName)
		if *i < len(lexArr) {
			lx = lexArr[*i]
			*i++
		}
		if lx.Tag & RPAREN == 0{
			//fmt.Println(15)
			fmt.Println("error")
			os.Exit(0)
		}
	}
}
func parse_actual_args(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string, c *int)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("Актуалочка на позиции %s %d\n", lx.Image, *i)
	if lx.Tag & RPAREN == 0 {
		parse_expr(lexArr, i, listIncidence, fName)
		*c++
		//fmt.Printf("Заходим в end_list на %s %d\n", lexArr[*i].Image, *i)
		if *i < len(lexArr) {
			lx = lexArr[*i]
		}
		if lx.Tag & RPAREN == 0 {
			parse_end_list(lexArr, i, listIncidence, fName, c)
		} else {
			*c--
		}
		//fmt.Printf("Вышли с кончи на %s %d\n", lexArr[*i].Image, *i)
		*i++
	} else {
		*c--
		*i++
	}
}
func parse_end_list(lexArr []Lexem, i *int, listIncidence *[]graphVertex, fName string, c *int)  {
	var lx Lexem
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("Конча на %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & COMMA == 0 {
		//fmt.Println(16)
		fmt.Println("error")
		os.Exit(0)
	}
	*i++
	parse_expr(lexArr, i, listIncidence, fName)
	if *i < len(lexArr) {
		lx = lexArr[*i]
	}
	//fmt.Printf("Конча сдвинулась на %s %d\n", lexArr[*i].Image, *i)
	if lx.Tag & RPAREN == 0 {
		*c++
		parse_end_list(lexArr, i, listIncidence, fName, c)
	}

}
type graphVertex struct {
	name int
	graphEdges []int
	t1 int
	low int
	comp int

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
		(*listIncidence)[u].comp = count
		for u != numV {
			u = s.pop()
			(*listIncidence)[u].comp = count
		}
		count++
	}
}
// Задача решается просто алгоритмом Тарьяна
func main()  {
	var f string = " "
	sc := bufio.NewScanner(os.Stdin)
	program := ""
	listIncidence := make([]graphVertex, 0)
	for sc.Scan() {
		f = sc.Text()
		if f == "" {
			break
		}
		program += f
	}
	lexArr := make([]Lexem, 0)
	lexArr = lexer(program, lexArr, len(program))
	i := 0
	parse_program(lexArr, &i, &listIncidence)
	for _, v := range call {
		if ohShitImSorry[v.name] != v.count {
			//fmt.Println(v.count, v.name)
			//fmt.Println(888)
			fmt.Println("error")
			os.Exit(0)
		}
		if indexOf(names, v.name) == -1 {
			///fmt.Println(999)
			fmt.Println("error")
			os.Exit(0)
		}
	}
	//fmt.Println("Фух, запарсили")

	for j := 0; j < nVert; j++ {
		var shrek graphVertex
		shrek.name = j
		shrek.graphEdges = make([]int, 0)
		shrek.comp = -1
		shrek.t1 = 0
		listIncidence = append(listIncidence, shrek)
	}
	for f, ar := range fZav {
		for _, he := range ar {
			listIncidence[fVert[f]].graphEdges = append(listIncidence[fVert[f]].graphEdges, fVert[he])
		}
	}
	Tarjan(&listIncidence)
	fmt.Println(count)
}
/*
Заходят два дракона в бар.
Один другого спрашивает:
-хули тут так жарко?
Другой отвечает:
-а ты ебало закрой
*/