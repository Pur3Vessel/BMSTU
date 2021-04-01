package main

import (
	"fmt"
	"sort"
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
	mark bool
	name int
	graphEdges []int // так как здесь у ребер нет атрибутов, то они характеризуются только номером второй инцидентной вершины
}

func BFS(listIncidence []graphVertex, q queue, start int, distList *[]int)  {
	for i, _ := range listIncidence {
		listIncidence[i].mark = false
	}

	listIncidence[start].mark = true
	q.enqueue(&listIncidence[start])
	// Не имеет смысла рассматривать отдельные компоненты связности (если хотим найти равноудаленные вершины)
	// (Для этих компонент нужно будет рассмотреть отдельный случай)
	for q.count > 0 {
		v := q.dequeue()
		for _, e := range (*v).graphEdges {
			if !listIncidence[e].mark {
				(*distList)[e] =  (*distList)[v.name] + 1
				listIncidence[e].mark = true
				q.enqueue(&listIncidence[e])
			}
		}
	}
}
// Для решения задачи, для каждой опорной вершины выполним обход в ширину и запомним расстояние до всех остальных вершин
// (Чет не смог придумать поизящней)
func main() {
	var n, m, k, v1, v2 int
	fmt.Scan(&n)
	fmt.Scan(&m)
	listIncidence := make([]graphVertex, 0)
	var q queue
	q.init(n)
	for i := 0; i < n; i++ {
		var shrek graphVertex
		shrek.name = i
		shrek.mark = false
		shrek.graphEdges = make([]int, 0)
		listIncidence = append(listIncidence, shrek)
	}
	for i := 0; i < m; i++ {
		fmt.Scanf("%d %d", &v1, &v2)
		listIncidence[v1].graphEdges = append(listIncidence[v1].graphEdges, v2)
		listIncidence[v2].graphEdges = append(listIncidence[v2].graphEdges, v1)
	}
	fmt.Scan(&k)
	distances := make([][]int, k)
	for i := 0; i < k; i++ {
		fmt.Scan(&v1)
		distances[i] = make([]int, n) // массив автоматом заполнится нулями (удобно)
		BFS(listIncidence, q, v1, &distances[i])
	}
	Eq := make([]int, 0)
	// пройдемся по всем вершинам и проверим идентичность расстояний для всех опорных вершин
	// причем опорные вершины тоже будем рассматривать (я не хочу запоминать их номера), все равно они в ответ никак не попадут
	Yep := true
	for i := 0; i < n; i++ {
		Yep = true
		// Будем смотреть попарно, т.к в случае какого нибудь несовпадения, это так или иначе станет заметно
		// (И отдельная проверка для компонент связности)
		for j := 0; j < k - 1; j++ {
			if distances[j][i] != distances[j + 1][i] || distances[j][i] == 0 {
				Yep = false
				break
			}
		}
		if Yep {
			Eq = append(Eq, i)
		}
	}
	//fmt.Println(distances)
	sort.Ints(Eq)
	if len(Eq) == 0 {
		fmt.Println("-")
	} else {
		for _, e := range Eq {
			fmt.Printf("%d ", e)
		}
	}
}
/*
Приходит актёр в провинциальный театр устраиваться на работу. А там ему говорят:
- Мест нет, ролей нет, ничего нет...
- Да мне хоть бабу Ягу для начала!
- Ничего нет. Ну, разве что роль оруженосца Волобуева... но это ж бред, Вы ж понимаете. Вы не возьметесь играть!
- А что за роль?
- Да бросьте. Заслуженные пробовались, не потянули... или Вы не слыхали про Волобуева???
- Не слыхал.

- Роль это эпизодическая. В финальной сцене нужно выйти на сцену, протянуть главному герою меч и сказать: Волобуев! Вот Ваш меч!!! Но над ролью висит тяжкое проклятие. Впервые в нашем театре Волобуева ставили в 1896 году в бытность в городе августейших особ. Подлец-гимназист, которому доверили вынести меч, то ли из шалости, то ли случайно, возопил: ВолоХ...ЕВ! Вот ваш меч!!! Ну, случился скандал. Режиссера в Сибирь сослали, труппу разогнали...

Другой раз уже при Советской России пьесу эту ставили. Актёр, игравший оруженосца, очень волновался, и конечно, тоже брякнул: Волох...ев! Режиссера расстреляли, труппу в лагеря. И при Брежневе ещё ставили, тоже ничего хорошего не вышло... Сейчас вот молодой главреж пришёл, хочет ставить... его отговаривают все, и за роль оруженосца не берется никто!

- Я согласен! - говорит новоприбывший актёр.

Репетиции идут - все хорошо, прогоны - все хорошо... с трепетом город ждёт премьеры. Зал полон. Второй акт, все как на иголках. Финальная сцена. Выходит Оруженосец Волобуева с мечом. В зале тишина...

Оруженосец собирается с мыслями... сам трепещет... в зале тишина... Оруженосец, отчетливо артикулируя, произносит:

- Волобуев!...

ПЯТИМИНУТНАЯ ОВАЦИЯ!!! ЗАЛ ВСТАЕТ!!! НА СЦЕНУ ЛЕТЯТ ЦВЕТЫ!!! Актёр чинно наслаждается своим триумфом, жизнь удалась, актёр расслабился... овация стихает... оруженосец продолжает:

- Волобуев! Вот Ваш ХУЙ!!!
	*/