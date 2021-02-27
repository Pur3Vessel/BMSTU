#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct on_list ol;

struct on_list {
    int v, k;
    struct on_list *next;
};

ol** hash_init (int m)
{
    ol **t = (ol**)malloc(m * sizeof(ol*));
    for (int i = 0; i < m; i++) {
        t[i] = (ol*)malloc(sizeof(ol));
        t[i]->k = 0;
        t[i]->v = 0;
        t[i]->next = NULL;
    }
    return t;
}
ol *initlist(ol *l, int k, int v)
{
    l = (ol*)malloc(sizeof(ol));
    l->v = v;
    l->k = k;
    return l;
}

ol *ins_bh(ol *l, int k, int v) 
{
    ol *new = initlist(new, k, v);
    new->next = l;
    l = new;
    return l;
}
ol** insert (ol **t, int k, int v, int n) 
{
    t[abs(k) % n] = ins_bh(t[abs(k) % n], k, v);
    return t;
} 

ol *list_s(ol *l, int k)
{
    ol *x = l;
    while (x != NULL && x->k != k) x = x->next;
    return x;
}
ol *lookup (ol **t, int k, int n) 
{
    ol *p = list_s(t[abs(k) % n], k);
    if (p == NULL) return NULL;
    else return p;
}
void fork_l (ol *l) 
{
    ol *x;
    while (l != NULL) {
        x = l;
        l = l->next;
        free(x);
    }
}
void fork_t (ol **t, int m)
{
    for (int i = 0; i < m; i++) {
        fork_l(t[i]);
    }
    free(t);
}
int main()
{
    int n, count = 0, cur_res_key = 0;
    scanf("%d", &n);
    ol *tem;
    int *arr = (int*)malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) scanf("%d", &arr[i]);
    ol **t = hash_init(n);
    for (int i = 0; i < n; i++) {
        cur_res_key ^= arr[i];
        tem = lookup(t, cur_res_key, n);
        if (tem == NULL) insert(t, cur_res_key, 0, n);  
        else tem->v++;
    }
    for (int i = 0; i < n; i++) {
        tem = t[i];
        while (tem != NULL) {
            count += tem->v * (tem->v + 1) / 2;
            tem = tem->next;
        }
    }
    printf("%d\n", count);
    fork_t(t, n);
    free(arr);
    return 0;

}