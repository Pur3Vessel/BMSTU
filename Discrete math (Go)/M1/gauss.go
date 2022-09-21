package main
// в общем-то основной кошмар (часов 5 непрерывной дрочильни) был с ребилдом, потому как для одних тестов работал начальный вариант, дял других же вариант с up-down
// в конце концов я немного психанул и объединил эти две разные реализации
// а вообще мне кажется, что я кошмарно тут перемудрил
import (
	"fmt"
	"math"
)

func gcd(a, b int)  int {
	for a > 0 && b > 0 {
		if a >= b {
			a %= b
		} else {
			b %= a
		}
	}
	return a | b
}
// Вывод в формате дробей решил сделать с помощью структуры, символизирующей собой дробь
type Fraction struct {
	numerator, denominator int
}

// Инициализация дроби
func (f *Fraction) init(num, den int) {
	(*f).numerator = num
	(*f).denominator = den
}
// Сокращение дроби 
func (f *Fraction) reduce()  {
	h1 := int(math.Abs(float64((*f).numerator)))
	h2 := (*f).denominator
	if h1 == 0 {
		h2 = 0
	}
	h1 = gcd(h1, h2)
	if h1 != 0 {
		(*f).numerator /= h1
		(*f).denominator /= h1
	}

}
// Сложение
func (f *Fraction) fAdd(f1, f2 Fraction)  {
	h1 := f1.denominator
	h2 := f2.denominator
	h1 = gcd(h1, h2)
	h1 = (f1.denominator * f2.denominator) / h1
	dop1 := h1 / f1.denominator
	dop2 := h1 / f2.denominator
	f1.numerator *= dop1
	f1.denominator *= dop1
	f2.numerator *= dop2
	(*f).denominator = f1.denominator
	(*f).numerator = f1.numerator + f2.numerator
	f.reduce()
}
// Умножение на число
func (f *Fraction) fIntMul(a int)  {
	(*f).numerator *= a
	f.reduce()
}
// Вычитание
func (f *Fraction) fDif(f1, f2 Fraction)  {
	f2.fIntMul(-1)
	f.fAdd(f1, f2)
}
// Умножение
func (f *Fraction) fMul(f1, f2 Fraction)  {
	(*f).numerator = f1.numerator * f2.numerator
	(*f).denominator = f2.denominator * f1.denominator
	f.reduce()
}
// Деление
func (f *Fraction) fDiv(f1, f2 Fraction)  {
	if f2.numerator >= 0 {
		f2.numerator, f2.denominator = f2.denominator, f2.numerator
	} else {
		f2.numerator *= -1
		f2.denominator *= -1
		f2.numerator, f2.denominator = f2.denominator, f2.numerator
	}
	f.fMul(f1, f2)
}
// копирует матрицу (нужно для того, чтобы исходная матрица не менялась при посчете ранга)
func copy(m [][] Fraction, row, col int) [][] Fraction {
	var cm = make([][]Fraction, row)
	for i := 0; i < row; i++ {
		cm[i] = make([]Fraction, col)
		for j := 0; j < col; j++ {
			cm[i][j] = m[i][j]
		}
	}
	return cm
}
// меняет местами два столбца
func swapCol(m [][] Fraction, col1, col2, row int)  [][] Fraction {
	for i := 0; i < row; i++ {
		m[i][col1], m[i][col2] = m[i][col2], m[i][col1]
	}
	return m
}
// меняет местами две строки
func swapRow(m [][] Fraction, row1, row2, col int) [][] Fraction {
	for i := 0; i < col; i++ {
		m[row1][i], m[row2][i] = m[row2][i], m[row1][i]
	}
	return m
}
// высчитывает ранг матрицы (для теоремы Кронекера-Капелли)
func rank(m [][]Fraction, C, R int)  int {
	rank := C
	var h, hh Fraction
	for row := 0; row < rank; row++ {
		if m[row][row].numerator != 0 {
			for col := 0; col < R; col++ {
				if col != row {
					hh.fDiv(m[row][col], m[row][row])
					for i := 0; i < rank; i++ {
						h.fMul(hh, m[i][row])
						m[i][col].fDif(m[i][col], h)
					}
				}
			}
		} else {
			reduce := true
			for i := row + 1; i < R; i++ {
				if m[row][i].numerator != 0 {
					m = swapCol(m, row, i, rank)
					reduce = false
					break
				}
			}
			if reduce {
				rank--
				for i := 0; i < R; i++ {
					m[row][i] = m[rank][i]
				}
			}
			row--
		}

	}
	return rank
}
// Перестаивает матрицу, чтоб на главной диагонали не было нулей
func rebuild(m [][] Fraction, n, alt int) [][] Fraction {
	isSwap := false
	yep := true
	z := 0
	for i := 0; i < n; i++ {
		if m[i][i].numerator == 0 {
			yep = false
			for j := 0; j < n; j++ {
				if m[j][i].numerator != 0 {
					z = j
				}
				if m[j][i].numerator != 0 && m[i][j].numerator != 0{
					swapRow(m, i, j, n + 1)
					isSwap = true
					break
				}
			}
			if !isSwap {
				swapRow(m, i, z, n + 1 )
			}
		}
	}
	if !yep {
		alt++
		if alt > 20 {
			m = rebuildDown(m , n)
		} else {
			m = rebuild(m, n, alt)
		}
	}
	return  m
}
func rebuildUp(m [][] Fraction, n int ) [][]Fraction {
	yep := true
	for i := 0; i < n; i++ {
		if m[i][i].numerator == 0 {
			yep = false
			if i != n - 1 {
				m = swapRow(m,i, i + 1, n + 1)
			} else {
				m = swapRow(m, i, 0, n + 1)
			}

		}
	}
	if !yep {
		m = rebuildDown(m, n)
	}
	return m
}
func rebuildDown(m [][] Fraction, n int ) [][]Fraction {
	yep := true
	for i := n - 1; i >= 0; i-- {
		if m[i][i].numerator == 0 {
			yep = false
			if i != 0 {
				m = swapRow(m,i, i - 1, n + 1)
			} else {
				m = swapRow(m, i, n - 1, n + 1)
			}

		}
	}
	if !yep {
		m = rebuildUp(m, n)
	}
	return m
}
func main()  {
	var n, iTmp int
	var fTmp, fTmp2 Fraction
	fmt.Scan(&n)
	var gaussMatrix = make([][]Fraction, n)
	var solution = make([]Fraction, n)
	// Составляем матрицу
	for i := 0; i < n; i++ {
		gaussMatrix[i] = make([]Fraction, 0)
		for j := 0; j <= n; j++ {
			fmt.Scan(&iTmp)
			fTmp.init(iTmp,1)
			gaussMatrix[i] = append(gaussMatrix[i], fTmp)
		}
	}
	copyMatrix := copy(gaussMatrix, n, n)
	r1 := rank(copyMatrix, n, n)
	copyMatrix = copy(gaussMatrix, n, n + 1)
	r2 := rank(copyMatrix, n, n + 1)
	//fmt.Println(gaussMatrix)
	//fmt.Println(r1, r2)

	if r1 == r2 && r1 == n{
		gaussMatrix = rebuild(gaussMatrix, n, 0)
		//fmt.Println(gaussMatrix)
		// Прямой ход Гаусса
		for k := 0; k < n - 1; k++ {
			for i := k + 1; i < n; i++ {
				for j := k; j < n + 1; j++ {
					if j == k {
						fTmp = gaussMatrix[i][k]
					}
					if gaussMatrix[k][k].numerator != 0 {
						fTmp2.fDiv(fTmp, gaussMatrix[k][k])
					}
					fTmp2.fMul(fTmp2, gaussMatrix[k][j])
					gaussMatrix[i][j].fDif(gaussMatrix[i][j], fTmp2)
				}
			}
		}
		// Обратный ход Гаусса
		if gaussMatrix[n-1][n-1].numerator != 0{
			solution[n - 1].fDiv(gaussMatrix[n - 1][n], gaussMatrix[n - 1][n - 1])
		}
		for k := n - 2; k >= 0; k--{
			fTmp.init(0, 1)
			l := k + 1
			fTmp2.fMul(gaussMatrix[k][l], solution[l])
			fTmp.fAdd(fTmp, fTmp2)
			l++
			for l < n {
				fTmp2.fMul(gaussMatrix[k][l], solution[l])
				fTmp.fAdd(fTmp, fTmp2)
				l++
			}
			fTmp2.fDif(gaussMatrix[k][n], fTmp)
			if gaussMatrix[k][k].numerator != 0 {
				solution[k].fDiv(fTmp2, gaussMatrix[k][k])
			}
		}
		// Выводим решения
		for i := 0; i < n; i++ {
			if solution[i].numerator == 0 {
				solution[i].denominator = 1
			}
			fmt.Printf("%d/%d\n", solution[i].numerator, solution[i].denominator)
		}
	} else {
		fmt.Println("No solution")
	}
}
/*
Студент решил подработать. Товарищи посоветовали ему устроиться ночным сторожем или дворником. Он пошел в одно место, там места заняты, пошел в другое - то же. Пришел в зоопарк, но там ему сказали, что и сторож и дворник есть и предложили:
- У нас недавно подохла обезьяна. Вы бы могли ее заменить.
- Не знаю, смогу ли, - сомневается студент.
- А вы спортом занимались?
- Занимался.
- Шкура у нас есть и платить будем больше, чем сторожу или дворнику. Ну, студент согласился. Вот, сидит он в клетке, лазает, рожи посетителям строит, на кольцах крутится, посетители довольны. Вечером, когда посетителей уже стало мало, он спрыгнул на пол, но неудачно, и провалился в клетку, стоявшую под той, в которой он находился. Видит, прямо на него идет лев. Ну, студент думает: "Зря я согласился. Даже за такие деньги". А лев подходит и говорит человеческим голосом:
- Привет! Ты с какого факультета?
*/
 