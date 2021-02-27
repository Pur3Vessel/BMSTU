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
    int k, n;
    prio p;
    prio *pp = &p;
    scanf("%d", &k);
    int count = 0;
    for (int i = 0; i < k; i++) {
        scanf("%d", &n);
        count += n;
    }
    prioinit(count, pp);
    for (int i = 0; i < count; i++){
        scanf("%d", &n);
        insert(pp, n);
    }
    while (empty(pp) != 0) printf("%d ", extmax(pp));
    free(p.heap);
    return 0;
}