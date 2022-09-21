#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct queue que;
struct queue {
    int* data;
    int cap, count, head, tail;
};
void initque (que *q, int n)
{
    q->cap = n;
    q->count = q->head = q->tail = 0;
    q->data = (int*)malloc(q->cap * sizeof(int));
}
int queempty (que *q) 
{
    return q->count;
}
void enque (que *q, int val)
{
    if (q->count == q->cap) {
        int *bufer = (int*)malloc(q->cap * sizeof(int));
        if (q->tail > q->head) {
            for (int i = 0; i < q->count; i++) bufer[i] = q->data[i]; 
        }
        else {
            int j = 0;
            for (int i = q->head; i < q->count; i++, j++) bufer[j]= q->data[i];
            for (int i = 0; i < q->tail; i++, j++) bufer[j]= q->data[i];
        }
        q->cap *= 2;
        free(q->data);
        q->data = (int*)malloc(q->cap * sizeof(int));
        for (int i = 0; i < q->count; i++) q->data[i] = bufer[i];
        free(bufer);
        q->head = 0;
        q->tail = q->count;
        
    }
    q->data[q->tail++] = val;
    if (q->tail == q->cap) q->tail = 0;
    q->count++;
}
int deque (que *q)
{
    int x = q->data[q->head++];
    if (q->head == q->cap) q->head = 0;
    q->count--;
    return x;
}
int main()
{
    int n, x;
    que q;
    que *qp = &q;
    char op[5];
    scanf("%d", &n);
    initque(qp, 4);
    for (int i = 0; i < n; i++) {
        scanf("%s", op);
        if (strcmp(op, "EMPTY") == 0) {
            if (queempty(qp) == 0) printf("true\n");
            else printf("false\n");
        }
        if (strcmp(op, "ENQ") == 0) {
            scanf("%d", &x);
            enque(qp, x);
        }
        if (strcmp(op, "DEQ") == 0) printf("%d\n",deque(qp));       
    }
    free(q.data);
    return 0;
}