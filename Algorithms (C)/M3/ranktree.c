#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct tier tier;
struct tier {
    int k, count;
    struct tier *parent, *left, *right;
    char w[10];
};
tier *init_tree (tier* t) 
{
    t = NULL;
    return t;
}
tier *insert(tier *t, int k)
{
    tier *y = (tier*)malloc(sizeof(tier));
    y->left = NULL;
    y->right = NULL;
    y->parent = NULL;
    y->count = 0;
    y->k = k;
    scanf("%s", y->w);
    if (t == NULL) t = y;
    else {
        tier *x = t;
        for (;;) {
            x->count++;
            if (x->k > k) {
                if (x->left == NULL) {
                    x->left = y;
                    y->parent = x;
                    break;
                }
                x = x->left;
            }
            else {
                if (x->right == NULL) {
                    x->right = y;
                    y->parent = x;
                    break;
                }
                x = x->right;
            }
        }
    }
    return t;
}
tier *look(tier *t, int k, int delete_mode) {
    tier *x = t;
    while (x != NULL && x->k != k) {
        if (delete_mode == 1) x->count--;
        if (k < x->k) x = x->left;
        else x = x->right ;
    }
    return x;
}
tier *minimum(tier *t){
    tier *x;
    if (t == NULL) x = NULL;
    else {
        x = t;
        while (x->left != NULL) {
            x->count--;
            x = x->left;
        }
    }
    return x;
}
tier *succ(tier *x) 
{
    tier *y;
    if (x->right != NULL) y = minimum(x->right);
    else {
        y = x->parent;
        while (y!=NULL && x == y->right) {
            x = y;
            y = y->parent;
        }
    }
    return y;
}
tier *replace(tier *t, tier *x,tier *y)
{
    if (x == t) {
        t = y;
        if (y != NULL) y->parent = NULL;
    }
    else {
        tier *p = x->parent;
        if (y != NULL) y->parent = p;
        if (p->left == x) p->left = y;
        else p->right = y;
    }
    return t;
}
tier *delete (tier *t, int k) {
    tier *x = look(t, k, 1);
    if (x->left == NULL && x->right ==NULL) t = replace(t, x, NULL);
    else {
        if (x->left == NULL) t = replace(t, x , x->right);
        else {
            if (x->right == NULL) t = replace(t, x, x->left);
            else {
                tier *y = succ(x);
                t = replace(t, y, y->right);
                x->left->parent = y;
                y->left = x->left;
                if (x->right != NULL) x->right->parent = y;
                y->right = x->right;
                y->count = x->count - 1;
                t = replace(t, x, y);
            }
        }
    }
    free(x);
    return t;
}
tier *search(tier *t, int n) 
{
    tier *x = t;
    for (;;) {
        if (x->left == NULL) {
            if (n == 0) return x;
            else {
                x = x->right;
                n--;
            }
        }
        else {
            if (x->left->count + 1 == n) return x;
            else {
                if (x->left->count + 1 > n) x = x->left;
                else {
                    n -= x->left->count + 2;
                    x = x->right;
                }
            }
   
        }
    }
}
void free_tree(tier *t) 
{
    if (t != NULL) {
        free_tree(t->left); 
        free_tree(t->right);
        free(t);
    }
}
int main ()
{
    tier *t = init_tree(t);
    tier *x;
    int n, k;
    scanf("%d", &n);
    char op[6];
    for (int i = 0; i < n; i++) { 
        scanf("%s", op);
        if (strcmp(op, "INSERT") == 0) {
            scanf("%d", &k);
            t = insert(t, k);
        }
        if (strcmp(op, "SEARCH") == 0) {
            scanf("%d", &k);
            x = search(t, k);
            printf("%s\n", x->w);
        }
        if (strcmp(op, "LOOKUP") == 0) {
            scanf("%d", &k);
            x = look(t, k, 0);
            printf("%s\n", x->w);
        }
        if (strcmp(op, "DELETE") == 0) {
            scanf("%d", &k);
            t = delete(t, k);
        }

    }
    free_tree(t);
    return 0;
}