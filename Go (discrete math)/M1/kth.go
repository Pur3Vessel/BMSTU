package main

import (
	"fmt"
	"math"
)
// определяет количество цифр в числе
func numberOfDigits(x uint64) uint64 {
	var n uint64 = 0
	for i := x; i > 0; i /= 10 {
		n += 1
	}
	return n
}
// определяет количество цифр до числа k
func digitsForK(k uint64)  uint64{
	var (
		rank uint64 = 1
		nDig uint64 = 1
		c uint64 = 0
		curFig uint64 = rank * 10 - rank
	)
	for k >= curFig {
		c += curFig * nDig
		nDig++
		rank *= 10
		k -= curFig
		curFig = rank * 10 - rank
	}
	c += k * nDig
	return c
}
func main()  {
	var k uint64
	fmt.Scanf("%d", &k)
	k++
	//fmt.Printf("%d\n", digitsForK(15))
	var (
		left uint64 = 0
		right uint64 = uint64(math.Pow(2, 64))
		mid uint64
		requiredNumber uint64
		startI uint64
		position uint64

	)
	//fmt.Printf("%d\n", right)
	for right - 1 > left {
		mid = (right + left) / 2
		//fmt.Printf("%d\n", mid)
		//fmt.Printf("IWT1\n")
		if digitsForK(mid) >= k {
			right = mid
		} else {
			left = mid
		}
	}
	if digitsForK(left) <= k {
		requiredNumber = right
	} else {
		requiredNumber = left
	}
	startI = digitsForK(requiredNumber - 1)
	//fmt.Printf("%d\n", digitsForK(1000000000))
	position = k - startI
	//fmt.Printf("%d %d %d\n", position, numberOfDigits(requiredNumber), requiredNumber)
	position = numberOfDigits(requiredNumber) - position
	//fmt.Printf("%d\n", position)
	for position > 0 {
		//fmt.Printf("IWT2\n")
		requiredNumber /= 10
		position--
	}
	fmt.Printf("%d", requiredNumber % 10)
}
