package main

import (
	"fmt"
)
// не нашел в golang готовых очередей
type queue struct {
	data []*graphVertex
	cap int
	count int
	head int
	tail int
}

func (q *queue) init(n int)  {
	(*q).data = make([]*graphVertex, n)
	(*q).cap = n
	(*q).count = 0
	(*q).head = 0
	(*q).tail = 0
}
func (q *queue) enqueue(g *graphVertex)  {
	(*q).data[(*q).tail] = g
	(*q).tail++
	if (*q).tail ==  (*q).cap {
		(*q).tail = 0
	}
	(*q).count++
}
func (q *queue) dequeue() *graphVertex {
	g := (*q).data[(*q).head]
	(*q).head++
	if (*q).head == (*q).cap {
		(*q).head = 0
	}
	(*q).count--
	return g
}
type graphVertex struct {
	mark int // 0  - white, 1 - black
	parent *graphVertex
	comp int
	name int // поле, нужное чисто для отладки
	graphEdges []int // так как здесь у ребер нет атрибутов, то они характеризуются только номером второй инцидентной вершины
}

func DFS1(listIncidence *[]graphVertex, q *queue, bridges *int)  {
	for i, v := range *listIncidence {          // ОБОЖАЮ УКАЗАТЕЛИ, УКАЗАТЕЛИ КЛАСС!!!!
		if v.mark == 0 {
			*bridges-- // Уже существующая компонента, поэтому тут моста нет
			VisitVertex1(listIncidence, q, &(*listIncidence)[i])
		}
	}
}
func VisitVertex1(listIncidence *[]graphVertex, q *queue, vertex *graphVertex)  {
	(*vertex).mark = 1
	(*q).enqueue(vertex)
	//fmt.Printf("%d\n",(*vertex).name)
	for _, e := range (*vertex).graphEdges {
		if (*listIncidence)[e].mark == 0 {
			//fmt.Printf("parent: %d son: %d\n", (*vertex).name, (*listIncidence)[e].name)
			(*listIncidence)[e].parent = vertex
			VisitVertex1(listIncidence, q, &((*listIncidence)[e]))
		}
	}
}
func DFS2(listIncidence *[]graphVertex, q *queue, bridges *int)   {
	var shrek *graphVertex
	component := 0
	for (*q).count > 0 {
		shrek = (*q).dequeue()
		//fmt.Println(shrek.name)
		if (*shrek).comp == -1 {
			VisitVertex2(listIncidence, shrek, component)
			*bridges++
			component++
		}
	}

}
func VisitVertex2(listIncidence *[]graphVertex, vertex *graphVertex, component int)  {
	(*vertex).comp = component
	for _, e := range (*vertex).graphEdges {
		if ((*listIncidence)[e].comp == -1) && ((*listIncidence)[e].parent != vertex) {
			VisitVertex2(listIncidence, &((*listIncidence)[e]), component)
		}
	}
}
// для решения задачи достаточно проделать алгоритм постоения компонент реберной двусвязности
// логично, что количество мостов = количество таких компонент
func main()  {
	var n, m, v1, v2 int
	fmt.Scan(&n)
	fmt.Scan(&m)
	listIncidence := make([]graphVertex, 0)
	var q queue
	q.init(n)
	for i := 0; i < n; i++ {
		var shrek graphVertex
		shrek.mark = 0
		shrek.name = i
		shrek.comp = -1
		shrek.graphEdges = make([]int, 0)
		listIncidence = append(listIncidence, shrek)
	}
	for i := 0; i < m; i++ {
		fmt.Scanf("%d %d", &v1, &v2)
		listIncidence[v1].graphEdges = append(listIncidence[v1].graphEdges, v2)
		listIncidence[v2].graphEdges = append(listIncidence[v2].graphEdges, v1)
	}
	bridges := 0
	DFS1(&listIncidence, &q, &bridges)
	DFS2(&listIncidence, &q, &bridges)
	//for i, v := range listIncidence {
		//fmt.Printf("%d: %d\n", i, v.comp)
	//}
	fmt.Println(bridges)
}

//Поручик Ржевский:
//- А не сыграть ли нам, господа, в новую игру? "Хартстоун" называется.
//- Научите поручик! Надоел преферанс!
//- Игра очень простая. Сдавайте карты, господа. И сразу на кон по рублю. Я быстро научу.
//Карты раздали, банк замутили. Ждут. Ржевский кладет свои карты на стол:
//- Залупа! - и сгребает деньги.
//- А в чем же смысл, поручик?
//- Всё просто, господа. Кто первый карты на стол бросит с криком "Залупа!" - того и банк.
//Понятно. После следующей раздачи все резко кидают карты на стол с криками:
//- ЗАЛУПА!!!
//Ржевский, спокойно и невозмутимо кладет карты на стол:
//- Легендарная залупа, господа