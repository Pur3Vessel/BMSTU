#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define alphabet 26
typedef struct trie trie;
typedef struct xi xi;

struct trie {
    int v[2];
    trie **arcs;
    trie *parent;
};

struct xi {
    trie *x;
    int i;
};
trie *init_trie(trie *t)
{
    t = (trie*)malloc(sizeof(trie));
    t->v[0] = 0;
    t->v[1] = 1;
    t->parent = NULL;
    t->arcs = (trie**)malloc(alphabet * sizeof(trie*));
    for (int i = 0; i < alphabet; i++) t->arcs[i] = NULL;
    return t;
}
xi descend(trie *t, char *k, int mode) {
    trie *x = t;
    int len = strlen(k);
    int i = 0;
    trie *y;
    while (i < len) {
        y = x->arcs[k[i] - 97];
        if (y == NULL) break;
        if (mode == 0) y->v[1]++;
        if (mode == 1) y->v[1]--;
        x = y;
        i++;
    }
    xi a;
    a.i = i;
    a.x = x;
    if (mode == 2 && a.i < len) a.x = NULL;
    return a;
}
trie *insert(trie *t, char *k) 
{
    int len = strlen(k);
    xi a = descend(t, k, 0);
    if (a.i == len && a.x->v[0] != 0) {
        a = descend(t, k, 1);
        return t;
    }
    while (a.i < len) {
        trie *y = init_trie(y);
        a.x->arcs[k[a.i] - 97] = y;
        y->parent = a.x;
        a.x = y;
        a.i++;
    }
    a.x->v[0] = 1;
    return t;
}
trie *delete(trie *t, char *k) 
{
    xi a = descend(t, k, 1);
    a.x->v[0] = 0;
    while (a.x->parent != NULL && a.x->v[0] == 0) {
        int j = 0;
        while (j< alphabet && a.x->arcs[j] == NULL) j++;
        if (j < alphabet) break;
        trie *y = a.x->parent;
        a.i--;
        y->arcs[k[a.i] - 97] = NULL;
        free(a.x->arcs);
        free(a.x);
        a.x = y;
    }
    return t;

}
void free_trie(trie *t) 
{
    if (t != NULL) {
        for (int i = 0; i < alphabet; i++) free_trie(t->arcs[i]);
        free(t->arcs);
        free(t);
    }
}
int main()
{
    int n;
    char op[6], k[100000];
    trie *t = init_trie(t);
    scanf("%d", &n);
    for (int i = 0; i < n; i++) {
        scanf("%s", op);
        if (strcmp(op, "INSERT") == 0) {
            scanf("%s", k);
            t = insert(t, k);
        }
        if (strcmp(op, "DELETE") == 0) {
            scanf("%s", k);
            t = delete(t, k);
        }
        if (strcmp(op, "PREFIX") == 0) {
            scanf("%s", k);
            xi a = descend(t, k, 2); 
            if (a.x == NULL) printf("0\n");
            else printf("%d\n", a.x->v[1]);
        }
    }
    free_trie(t);
    return 0;
}