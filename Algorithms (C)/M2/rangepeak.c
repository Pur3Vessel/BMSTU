#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define size_t long
#define size 5

int peak_pred (size_t *array, int r, int n)
{
    if (r >= n) return 0;
    if (n == 1) return 1;
    if ((n == 2) && (r == 0)) {
        if (array[r] >= array[r + 1]) return 1;
        else return 0;
    }
    if ((n == 2) && (r == 1)) {
        if (array[r] >= array[r - 1]) return 1;
        else return 0;
    }
    if (n >= 3) {
        if (r == 0) {
            if (array[r] >= array[r+1]) return 1;
            else return 0;
        }
        if (r == (n - 1)) {
            if (array[r] >= array[r-1]) return 1;
            else return 0;
        }
        if ((array[r] >= array[r+1]) && (array[r]>=array[r-1])) return 1;
        else return 0;
    }

}
void build(size_t *array, int a, int b, int tier, int *T, int n)
{
    if (a == b) T[tier] = peak_pred(array, a, n);
    else {
        int m = (a+b)/2;
        build(array, a, m, tier * 2, T, n);
        build(array, m + 1, b,  2 * tier + 1, T, n);
        T[tier] = T[tier * 2] + T[tier * 2 + 1];
    }
}
int* TreeBuild(size_t *array, int n)
{
    int *T = (int*)malloc(n * size * sizeof(int));
    for (int i = 0; i < size * n; i++) T[i] = 0;
    build(array, 0, n - 1, 1, T, n);
    return T;
}

void update(int *T, int i, int a, int b, size_t *array, int n, int tier)  
{
    if (a == b) T[tier] = peak_pred(array, a, n);
    else {
        int m = (a + b) / 2;
        if (i <= m) update(T, i, a, m, array, n, tier * 2);
        else update(T, i, m + 1, b, array, n, tier * 2 + 1);
        T[tier] = T[tier * 2] + T[tier * 2 + 1];
    }
} 
void tree_upd(int *T, int i, int v, size_t *array, int n)
{
    array[i] = v;
    update(T, i, 0, n - 1, array, n, 1);
    if (i != 0) update(T, i - 1, 0, n - 1, array, n, 1);
    if (i != (n-1)) update(T, i+1, 0, n - 1, array, n, 1);
}


int peak (int *T, int l, int r, int a, int b, int tier)
{
    if (l == a && r == b) return T[tier];
    else {
        int m = (a + b)/ 2;
        if (r <= m) return peak(T, l, r, a, m, 2 * tier);
        else {
            if (l > m) return peak(T, l, r, m + 1, b, 2 * tier + 1);
            else return peak(T, l , m, a, m, 2 * tier) + peak(T, m + 1, r, m + 1, b, tier * 2 + 1);
        }

    }
}
int main()
{
    int n,m, r, l;
    char op[4];
    scanf("%d", &n);
    size_t *array = (size_t*)malloc(n * sizeof(size_t));
    if (array == NULL) return -1;
    for (int i = 0; i < n; i++) scanf("%ld", &array[i]);
    int *T = TreeBuild(array, n);
    scanf("%d", &m);
    for (int i = 0; i < m; i++) {
        scanf("%s%d%d", op, &l, &r);
        if (strcmp(op, "PEAK") == 0) printf("%d\n", peak(T, l, r, 0, n - 1, 1));
        else tree_upd(T, l, r, array, n);    
    }
    free(array);
    free(T);
    return 0;
}