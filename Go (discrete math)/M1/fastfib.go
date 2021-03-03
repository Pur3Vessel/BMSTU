package main

import (
	"fmt"
	"math/big"
)
// для перемножения двух матриц 2x2
func matrixMultiplication(M1, M2 [2][2]*big.Int)  (resultM [2][2]*big.Int) {
	resultM[0][0] = big.NewInt(0)
	resultM[1][0] = big.NewInt(0)
	resultM[0][1] = big.NewInt(0)
	resultM[1][1] = big.NewInt(0)
	for i := 0; i < 2; i++ {
		for j := 0; j < 2; j++ {
			for s := 0; s < 2; s++ {
				p := big.NewInt(0)
				p.Mul(M1[i][s], M2[s][j])
				resultM[i][j].Add(resultM[i][j],p)
			}
		}
	}
	return
}
func main()  {
	var n int
	fmt.Scanf("%d", &n)
	if (n == 1 && n == 2) {
		fmt.Println(1)

	} else {
		var startMatrix [2][2] *big.Int
		var finalMatrix [2][2] *big.Int
		startMatrix[0][0] = big.NewInt(1)
		startMatrix[1][0] = big.NewInt(1)
		startMatrix[0][1] = big.NewInt(1)
		startMatrix[1][1] = big.NewInt(0)
		finalMatrix[0][0] = big.NewInt(1)
		finalMatrix[1][0] = big.NewInt(0)
		finalMatrix[0][1] = big.NewInt(0)
		finalMatrix[1][1] = big.NewInt(1)
		step := n - 1
		//быстрое возведение в степень
		for step > 0 {
			if step & 1 == 1{
				finalMatrix = matrixMultiplication(finalMatrix, startMatrix)
			}
			startMatrix = matrixMultiplication(startMatrix, startMatrix)
			step >>= 1
		}
		fib := big.NewInt(0)
		fib.Add(finalMatrix[1][0], finalMatrix[1][1])
		fmt.Println(fib)
	}

}
 /* Шел рыцарь по пустыне.
 Долгим был его путь.
 По пути он потерял коня, шлем и доспехи.
 Остался только меч.
 Рыцарь был голоден, и его мучила жажда.
 Вдруг вдалеке он увидел озеро.
 Собрал рыцарь все свои оставшиеся силы и пошел к воде.
 Но у самого озера сидел трехглавый дракон.
 Рыцарь выхватил меч и из последних сил начал сражаться с чудовищем.
 Сутки бился, вторые бился. Две головы дракона уже отрубил.
 На третьи сутки дракон упал без сил.
 Рядом упал обессиленный рыцарь, не в силах уже более стоять на ногах и держать меч.
 И тогда из последних сил дракон спросил:
 - Рыцарь, а ты чего хотел-то?
 - Воды попить.
 - Ну, так и пил бы...
  */
 