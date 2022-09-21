package main
// И опять тут п&*(*ц как перемудрено
import (
	"fmt"
	"strconv"
	//"github.com/skorobogatov/input"
	"input"
)
var errorCode bool = false // Если при синтаксическом анализе нашлась ошибка
var variables = make([]string, 0) // Каждый раз, когда встречаем переменную, запоминаем ее (для отображения)
var ohShitImSorry = make(map[string]int) // Чтоб потом получить значение переменной
var lexArr = make([]Lexem, 0)
var actions = make([]string, 0)
var length, index  int
// Решил отказаться использовать потоки в парсере, поскольку возникала проблема с тем, что невозможно посмотреть верхнее
// значение, не достав его. Для расчета выражения я составляю стэк машину и формирую последовательность командд для нее
type Tag int
type Lexem struct {
	Tag
	Image string
}
type Stack struct {
	data []int
	top int
}


func stackPush(stack Stack, v int) Stack{
	stack.data[stack.top] = v
	stack.top++
	return stack
}
func stackPop(stack Stack) (int, Stack) {
	stack.top--
	return stack.data[stack.top], stack
}

func stackMachine()  {
	var stack Stack
	var billy, van int
	var ricardo error
	stack.top = 0
	stack.data = make([]int, 10000)
	for _, x := range actions {
		//fmt.Println(x)
		switch x[0] {
		case 42:
			billy, stack = stackPop(stack)
			van, stack = stackPop(stack)
			billy = billy * van
			stack = stackPush(stack, billy)
			break
		case 43:
			billy, stack = stackPop(stack)
			van, stack = stackPop(stack)
			billy = billy + van
			stack= stackPush(stack, billy)
			break
		case 47:
			billy, stack = stackPop(stack)
			van, stack = stackPop(stack)
			billy = van / billy
			stack = stackPush(stack, billy)
			break
		case 45:
			billy, stack = stackPop(stack)
			billy *= -1
			stack = stackPush(stack, billy)
			break
		default:
			if x[0] >= 48 && x[0] <= 57 {
				billy, ricardo = strconv.Atoi(x)
				if ricardo != nil {
				}
				stack =  stackPush(stack, billy)
			} else {
				billy = ohShitImSorry[x]
				stack = stackPush(stack, billy)
			}
			break
		}

	}
	var ans int
	ans, stack = stackPop(stack)
	fmt.Println(ans)
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
// "Скипать", пока идет число
func getNum (expr string, ind int)  int{
	
	for ind < length && expr[ind] >= 48 && expr[ind] <= 57  {
		ind++
	}
	return ind
}
// "Скипать", пока идет переменная
func getVar(expr string, ind int)  int{
	for ind < length && ((expr[ind] >= 48 && expr[ind] <= 57) || (expr[ind] >= 65 && expr[ind] <= 90) || (expr[ind] >= 97 && expr[ind] <= 122))  {
		ind++
	}
	return ind
}
func lexer(expr string, lexems chan Lexem) {
	var closeIndex int
	var el Lexem
	for i := 0; i < length; i++ {
		switch expr[i] {
		// (
		case 40:
			el.Tag = 128
			el.Image = expr[i:i+1]
			lexems <- el
			break
		// )
		case 41:
			el.Tag = 256
			el.Image = expr[i:i+1]
			lexems <- el
			break
		// *
		case 42:
			el.Tag = 32
			el.Image = expr[i:i+1]
			lexems <- el
			break
		// +
		case 43:
			el.Tag = 8
			el.Image = expr[i:i+1]
			lexems <- el
			break
		// -
		case 45:
			el.Tag = 16
			el.Image = expr[i:i+1]
			lexems <- el
			break
		// /
		case 47:
			el.Tag = 64
			el.Image = expr[i:i+1]
			lexems <- el
			break
		// Пробел
		case 32:
			continue
		// Перенос строки
		case 10:
			continue
		default:
			if expr[i] >= 48 && expr[i] <= 57 {
				closeIndex = getNum(expr, i)
				el.Tag = 2
				el.Image = expr[i : closeIndex]
				lexems <- el
				i = closeIndex - 1
			} else {
				if (expr[i] >= 65 && expr[i] <= 90) || (expr[i] >= 97 && expr[i] <= 122) {
					closeIndex = getVar(expr, i)
					el.Tag = 4
					el.Image = expr[i : closeIndex]
					//fmt.Println(el.Image)
					lexems <- el
					i = closeIndex - 1
				} else {
					el.Tag = 1
					lexems <- el
				}
			}
			break
		}
	}
}
//<E>
func parseExpr()  {
	parseTT()
	parseE()
}
//<E`>
func parseE()  {
	var lx Lexem
	if index < length {
		lx = lexArr[index]
	}
	//fmt.Println("E: " ,lx.Image, lx.Tag)
	if lx.Tag & PLUS != 0 {
		if !errorCode {
			index++
			parseTT()
			actions = append(actions, lx.Image)
			parseE()
		}
	}
	if lx.Tag & MINUS != 0 {
		if !errorCode {
			index++
			parseTT()
			actions = append(actions, lx.Image)
			actions = append(actions, "+")
			parseE()
		}
	}
	if lx.Tag & (VAR | NUMBER) != 0 {
		//fmt.Println(1)
		errorCode = true
	}
}
//<T>
func parseTT()  {
	parseF()
	parseT()
}
//<T`>
func parseT()  {
	var lx Lexem
	if index < length {
		lx = lexArr[index]
	}
	//fmt.Println("T: " ,lx.Image, lx.Tag)
	if lx.Tag & DIV != 0 {
		if !errorCode {
			index++
			parseF()
			actions = append(actions, lx.Image)
			parseT()
		}
	}
	if lx.Tag & MUL != 0 {
		if !errorCode {
			index++
			parseF()
			actions = append(actions, lx.Image)
			parseT()
		}
	}
	if lx.Tag & (VAR | NUMBER) != 0 {
		//fmt.Println(2)
		errorCode = true
	}

}
//Чтоб запрашивать переменную только 1 раз
func contains(a []string, x string)  bool {
	for _, n := range a {
		if x == n {
			return true
		}
	}
	return false
}
//<F>
func parseF()  {
	var lx Lexem
	if index < length {
		lx = lexArr[index]
	} else {
		//fmt.Println(3)
		errorCode = true
	}
	//fmt.Println("F: ", lx.Image, lx.Tag)
	if lx.Tag & (ERROR | RPAREN | PLUS | DIV | MUL)!= 0 {
		//fmt.Println(4)
		errorCode = true
	}
	if lx.Tag & (NUMBER | VAR) != 0 {
		index++
		actions = append(actions, lx.Image)
		if lx.Tag & VAR != 0 {
			if !contains(variables, lx.Image) {
				variables = append(variables, lx.Image)
			}
		}
	}
	if lx.Tag & MINUS != 0 {
		index++
		parseF()
		actions = append(actions, lx.Image)
	}
	if lx.Tag & LPAREN != 0 {
		index++
		parseExpr()
		if index < length {
			lx = lexArr[index]
			index++
		}
		if lx.Tag & RPAREN == 0{
			//fmt.Println(5)
			errorCode = true
		}
	}

}
// Почему в задании написано про командную строку, хотя на деле это не так?
func main() {
	//expression := os.Args[1]
	var expression string
	var Ъеъ int
	expression = input.Gets()
	//fmt.Println(([]rune)(expression))
	length = len(expression)
	//fmt.Println(length)
	lexems := make(chan Lexem, length)
	lexer(expression, lexems)
	close(lexems)
	for x := range lexems {
		lexArr = append(lexArr, x)
	}
	index = 0
	length = len(lexArr)
	//fmt.Println(lexArr)
	parseExpr()
	//fmt.Println(actions)
	if !errorCode {
		for _, x := range variables {
			input.Scanf("%d", &Ъеъ)
			ohShitImSorry[x] = Ъеъ
		}
		stackMachine()
	} else {
		fmt.Println("error")
	}
}

// Мокрый негр зашёл в бар и попросил сухого белого.
