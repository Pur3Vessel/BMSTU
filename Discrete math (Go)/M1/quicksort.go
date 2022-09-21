package main

import "fmt"

var arr = make([]int, 0)

func less(i, j int) bool {
	return arr[i] < arr[j]
}
func swap(i, j int) {
	arr[i], arr[j] = arr[j], arr[i]
}
func partition(low int,high int,less func(i, j int) bool, swap func(i, j int)) int {
	i := low
	j := low
	for j < high {
		if less(j, high) {
			swap(i, j)
			i++
		}
		j++
	}
	swap(i, high)
	return i
}
func qsortRec(low int,high int,less func(i, j int) bool, swap func(i, j int)) {
	if low < high {
		q := partition(low, high, less, swap)
		qsortRec(low, q-1, less, swap)
		qsortRec(q+1, high, less, swap)
	}
}
func qsort(n int, less func(i, j int) bool, swap func(i, j int))  {
	qsortRec(0, n - 1, less, swap)
}
func main()  {
	var n, e int
	fmt.Scanf("%d", &n)
	for i := 0; i < n; i++ {
		fmt.Scanf("%d", &e)
		arr = append(arr, e)
	}
	/*for _, x := range arr {
		fmt.Printf("%d ", x)
	}
	fmt.Printf("\n") */
	qsort(n, less, swap)
	for _, x := range arr {
		fmt.Printf("%d ", x)
	}
}

//Купил мужчина шляпу, а она ему как раз.
