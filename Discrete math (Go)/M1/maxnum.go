package main

import "fmt"
var array = make([]int, 0)

func reverse(a []int) []int {
	if len(a) == 0 {
		return a
	}
	return append(reverse(a[1:]), a[0])
}
// сравнение происходит относительно старших разрядов числа
func compare(a, b int)  int {
	n1 := make([]int, 0)
	n2 := make([]int, 0)
	for a > 9 {
		n1 = append(n1, a % 10)
		a /= 10
	}
	n1 = append(n1, a % 10)
	for b > 9 {
		n2 = append(n2, b % 10)
		b /= 10
	}
	n2 = append(n2, b % 10)
	//fmt.Printf("%v\n", n1)
	//fmt.Printf("%v\n", n2)
	n1 = reverse(n1)
	n2 = reverse(n2)
	i, j := 0, 0
	for  i < len(n1) && j < len(n2) {
		if n1[i] > n2[j] {
			return 1
		}
		if n1[i] < n2[j] {
			return -1
		}
		i++
		j++
	}
	if len(n1) == len(n2){
		return 0
	}
	if len(n1) > len(n2) {
		j--
		if n1[i] > n2[j] {
			return 1
		}
		if n1[i] < n2[j] {
			return -1
		}
	} else {
		i--
		if n1[i] > n2[j] {
			return 1
		}
		if n1[i] < n2[j] {
			return -1
		}
	}
/*	if len(n1) > len(n2) {
		j--
		for i < len(n1) {
			if n1[i] > n2[j] {
				return 1
			}
			if n1[i] < n2[j] {
				return -1
			}

			i++
		}
	} else {
		i--
		for j < len(n2) {
			if n1[i] > n2[j] {
				return 1
			}
			if n1[i] < n2[j] {
				return -1
			}
			j++
		}

	} */

	return 0
}
func swap(i, j int)  {
	array[i], array[j] = array[j], array[i]
}
func bSort(n int, compare func(int, int) int, swap func(int, int))  {
	t := n - 1
	for t > 0{
		bound := t
		t = 0
		i := 0
		for i < bound {
			if compare(array[i + 1], array[i]) == 1 {
				swap(i + 1, i)
				t = i
			}
			i++
		}
	}
}
func main()  {
	var n, e int
	fmt.Scanf("%d", &n)
	for i := 0; i < n; i++ {
		fmt.Scanf("%d", &e)
		array = append(array, e)
	}
	bSort(n, compare, swap)
	for i := 0; i < n; i++ {
		fmt.Printf("%d", array[i])
	}

}
/* — Скажите, а это ваш "Ягуар" стоит около выхода?
— Да.
— Я допью?
 */
