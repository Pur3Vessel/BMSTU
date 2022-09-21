#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct dstack dstack;
struct dstack 
{
    int *data;
    int cap, top1, top2, maximum;
};

void ds_init(int n, dstack *s)
{
    s->data = (int*)malloc(n * sizeof(int));
    s->cap = n;
    s->top1 = 0;
    s->top2 = n - 1;
    s->maximum = -2000000001;
}

int ds_empty1(dstack *s)
{
    return s->top1;
}

int ds_empty2(dstack *s)
{
    if (s->top2 == s->cap - 1) return 0;
    else return 1;
}

void ds_push1(dstack *s, int val)
{
    if (s->top2 < s->top1) printf("error");
    s->data[s->top1++] = val;
    if (val > s->maximum) s->maximum = val;
}

void ds_push2(dstack *s, int val)
{
    if (s->top2 < s->top1) printf("error");
    s->data[s->top2--] = val;
}

int ds_pop1(dstack *s)
{
    return s->data[--s->top1];
}

int ds_pop2(dstack *s)
{
    return s->data[++s->top2];
}

int deque(dstack *s)
{
    if (ds_empty2(s) == 0) {
        while (ds_empty1(s) != 0) ds_push2(s, ds_pop1(s));
    }
    int x = ds_pop2(s);
    if (x == s->maximum) {
        s->maximum = -2000000001;
        for (int i = 0; i < s->top1; i++) {
            if (s->data[i] > s->maximum) s->maximum = s->data[i];
        }
        for (int i = s->top2 + 1; i < s->cap; i++) {
            if (s->data[i] > s->maximum) s->maximum = s->data[i];
        }
    }
    return x;
}

int s_max(dstack *s)
{
    return s->maximum;
}
int main()
{
    int n, x;
    char op[5];
    dstack s;
    dstack *sp = &s;
    scanf("%d", &n);
    ds_init(100000, sp);
    for (int i = 0; i < n; i++) {
        scanf("%s", op);
        if (strcmp(op, "EMPTY") == 0) {
            if ((ds_empty1(sp) == 0) && (ds_empty2(sp) == 0)) printf("true\n");
            else printf("false\n");
        }
        if (strcmp(op, "ENQ") == 0) {
            scanf("%d", &x);
            ds_push1(sp, x);
        }
        if (strcmp(op, "DEQ") == 0) printf("%d\n",deque(sp)); 
        if (strcmp(op, "MAX") == 0) printf("%d\n",s_max(sp)); 
    }
    free(s.data);
    return 0;
}