#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct tier tier;
typedef struct ans_for_num ans_n;
typedef struct ans_for_val ans_v;
struct tier {
    int k, val, balance;
    struct tier *parent, *left, *right;
};
struct ans_for_num {
    int ind, cons;
};
struct ans_for_val {
    int ind, val;
};
tier *init_tree (tier* t) 
{
    t = NULL;
    return t;
}
tier *insert(tier **t, int k, int val)
{
    tier *y = (tier*)malloc(sizeof(tier));
    y->left = NULL;
    y->right = NULL;
    y->parent = NULL;
    y->k = k;
    y->val = val;
    if (*t == NULL) *t = y;
    else {
        tier *x = *t;
        for (;;) {
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
    return y;
}
tier *look(tier *t, int k) {
    tier *x = t;
    while (x != NULL && x->k != k) {
        if (k < x->k) x = x->left;
        else x = x->right ;
    }
    return x;
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

tier *rotate_left(tier *t, tier *x)
{
    tier *y = x->right;
    t = replace(t, x, y);
    tier *b = y->left;
    if (b != NULL) b->parent = x;
    x->right = b;
    x->parent = y;
    y->left = x;
    x->balance--;
    if (y->balance > 0) x->balance -= y->balance;
    y->balance--;
    if (x->balance < 0) y->balance += x->balance;
    return t;
}
tier *rotate_right(tier *t, tier *x) 
{
    tier *y = x->left;
    t = replace(t, x, y);
    tier *b = y->right;
    if (b != NULL) b->parent = x;
    x->left = b;
    x->parent = y;
    y->right = x;
    x->balance++;
    if (y->balance < 0) x->balance -= y->balance;
    y->balance++;
    if (x->balance > 0) y->balance += x->balance;
    return t;
}
tier *insert_AVL (tier *t, int k, int val) 
{
    tier *a = insert(&t, k, val);
    a->balance = 0;
    for (;;) {
        tier *x = a->parent;
        if (x == NULL) break;
        if (a == x->left) {
            x->balance--;
            if (x->balance == 0) break;
            if (x->balance == -2) {
                if (a->balance == 1) t = rotate_left(t, a);
                t = rotate_right(t, x);
                break;
            }
        }
        else {
            x->balance++;
            if (x->balance == 0) break;
            if (x->balance == 2) {
                if (a->balance == -1) t = rotate_right(t,a);
                t = rotate_left(t, x);
                break;
            }
        }
        a = x;
    }
    return t;
}
void free_tree(tier *t) 
{
    if (t != NULL) {
        free_tree(t->left); 
        free_tree(t->right);
        free(t);
    }
}
ans_n getnum(char *sentence, int i) 
{
    ans_n ans;
    char *temp = (char*)malloc(15 * sizeof(char));
    int tm = 0;
    ans.cons = 0;
    while (sentence[i] != '+' && sentence[i] != '-' && sentence[i] != '*' && sentence[i] != '/' && sentence[i] != '(' && sentence[i] != ')' && sentence[i] != ' ' && sentence[i] != '\0') {
        temp[tm++] = sentence[i++];
    }
    ans.ind = i;
    tm--;
    int size = 1;
    for (int j = tm; j>=0; j--) {
        ans.cons += (temp[j] - 48) * size;
        size *= 10;
    }
    free(temp);
    return ans;
}
ans_v getv(char *sentence, int i)
{
    ans_v ans;
    ans.val = 0;
    int size = 1;
    while (sentence[i] != '+' && sentence[i] != '-' && sentence[i] != '*' && sentence[i] != '/' && sentence[i] != '(' && sentence[i] != ')' && sentence[i] != ' ' && sentence[i] != '\0') {
        ans.val += sentence[i++] * size;
        size *= 36;
    }
    ans.ind = i;
    return ans;
}
int main ()
{
    tier *t = init_tree(t);
    tier *h;
    int n, id = 0;
    scanf("%d \n", &n);
    char *sentence = (char*)malloc((n+5) * sizeof(char));
    int i = 0;
    gets(sentence);
    while (sentence[i] != '\0') {
        if (sentence[i] == ' ') {
            i++;
            continue;
        }
        switch (sentence[i]) 
        {
            case '+':
            {
                printf("SPEC 0\n");
                i++;
                break;
            }
            case '-':
            {
                printf("SPEC 1\n");
                i++;
                break;
            }
            case '*':
            {
                printf("SPEC 2\n");
                i++;
                break;
            }
            case '/':
            {
                printf("SPEC 3\n");
                i++;
                break;
            }
            case '(':
            {
                printf("SPEC 4\n");
                i++;
                break;
            }
            case ')':
            {
                printf("SPEC 5\n");
                i++;
                break;
            }
            default:
            {
                if (sentence[i] > 47 && sentence[i] < 58) {
                    ans_n ans_n = getnum(sentence, i);
                    printf("CONST %d\n", ans_n.cons);
                    i = ans_n.ind;
                }
                else {
                    ans_v ans_v = getv(sentence, i);
                    i = ans_v.ind;
                    h = look(t, ans_v.val);
                    if (h == NULL || h->k != ans_v.val) {;
                        printf("IDENT %d\n", id);
                        t = insert_AVL(t, ans_v.val, id);
                        id++;
                    }
                    else printf("IDENT %d\n", h->val);
                }
                break;
            }
            
            
        }
    }
    free(sentence);
    free_tree(t);
    return 0;
}