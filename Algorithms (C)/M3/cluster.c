#include <stdio.h>
#include <stdlib.h>
typedef struct prioque prio;

struct prioque {
    int *heap;
    int cap, count;
};

void prioinit(int n, prio *p)
{
    p->cap = n;
    p->count = 0;
    p->heap = (int*)malloc(n * sizeof(int));
}
void heapify (int i, int n, prio *p) 
{
    int j, l ,r, t;
    for (;;) {
        l = 2*i + 1;
        r = l + 1;
        j = i;
        if ((l < n) && (p->heap[i] > p->heap[l])) i = l;
        if ((r < n) && (p->heap[i] > p->heap[r])) i = r;
        if (i == j) break;
        t = p->heap[i];
        p->heap[i] = p->heap[j];
        p->heap[j] = t;
    }
}
int empty(prio *p)
{
    return p->count;
}
int pmax (prio *p)
{
    return p->heap[0];
}
void insert (prio *p, int v) 
{
    int t;
    int i = p->count++;
    p->heap[i] = v;
    while ((i > 0) && (p->heap[(i - 1)/2] > p->heap[i])) {
        t = p->heap[i];
        p->heap[i] = p->heap[(i-1)/ 2];
        p->heap[(i-1)/2] = t;
        i = (i - 1) / 2;  
    }
}
int extmax (prio *p)
{
    int v = pmax(p);
    p->count--;
    if (p->count > 0) {
        p->heap[0]= p->heap[p->count];
        heapify(0, p->count, p);
    }
    return v;
}
int main()
{
    int n, m, t1, t2, time, sum;
    scanf("%d", &n);
    scanf("%d", &m);
    prio p;
    prio *pp = &p;
    prioinit(m, pp);
    for (int i = 0; i < n; i++){
        scanf("%d%d", &t1, &t2);
        time = t1 + t2;
        insert(pp, time);
    }
    for (int i = n; i < m; i++) {
        scanf("%d%d", &t1, &t2);
        time = extmax(pp);
        if (t1 > time) time += t1 - time + t2;
        else time += t2;
        insert(pp, time);
    }
    while (empty(pp) != 0) time = extmax(pp);
    printf("%d", time);
    free(p.heap);
    return 0;
}