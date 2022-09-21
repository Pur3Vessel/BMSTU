#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#define str_size 10000000
#define size 4
#define min(a,b) (a < b) ? a : b
int MinPower2 (int n)
{
    int pow = 1;
    while (pow <= n) pow *= 2;
    return pow;
}
int build(char *array, int l, int r, int n, int*T)
{
        int sum = 0;
        int bound = min(r ,n);
        while (l < bound) {
            int m = (l+r) / 2;
            sum ^= build(array, l, m, n, T);
            l = m + 1;
        }
        if (r < n) {
            sum ^= 1 << (array[r] - 97);
            T[r] = sum;
        }
        return sum;
}
int* FenwickTreeBuild(char* array, int n)
{
    int *T = (int*)malloc(size * n * sizeof(int));
    int r = MinPower2(n);
    int s = build(array, 0, r - 1, n ,T);
    return T;
}
int query (int *T, int i)
{
    int v = 0;
    while (i >= 0) {
        v ^= T[i];
        i = (i & (i + 1)) - 1;
    }
    return v;
}
int FenwickTreeQuery(int *T, int l, int r) 
{
    return query (T,r) ^ query (T, l - 1);
}
void FenwickTreeUpdate (int i, int vs, int *T, int n) 
{
    while (i < n) {
        T[i] ^= vs;
        i = i|(i + 1);
    }
}
int main()
{
    int n,m, r, l, len, vs;
    char op[3];
    char *array = (char*)malloc(str_size * sizeof(char));
    char *bufer = (char*)malloc(str_size *sizeof(char));
    if (array == NULL || bufer == NULL) return -1;
    scanf("%s", array);
    n = strlen(array);
    int *T = FenwickTreeBuild(array, n);
    //for (int i = 0; i < n; i++) printf("%d ", T[i]);
    scanf("%d", &m);
    for (int i = 0; i < m; i++) {
        scanf("%s", op);
        if (strcmp(op, "HD") == 0){
            scanf("%d%d", &l, &r);
            len = r - l + 1;
            int v = FenwickTreeQuery(T, l, r);
            //printf("%d %d %d\n",len % 2 , v, (v & (v - 1)));
            if (((len % 2 == 0) && (v == 0)) || ((len % 2 == 1) && ((v & (v - 1)) == 0))) printf("YES\n");
            else printf ("NO\n");
        }
        else {
            scanf("%d%s", &l, bufer);
            len = strlen(bufer);
            r = 0;
            while (r < len) {
                vs = (1 << (bufer[r] - 97)) ^ (1 << (array[l] - 97));
                FenwickTreeUpdate(l, vs, T , n);
                array[l++] = bufer[r++];
            }
            r = 0;
        }

    }
    free(array);
    free(T);
    free(bufer);
    return 0;
}