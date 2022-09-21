#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define size 10
#define max(a, b) ((a) > (b) ? (a) : (b))
int* TreeBuild(int *array, int n)
{
	int *T = (int*)malloc(n * size * sizeof(int));
	build(array, 0, n-1, 1, T);
	return T;
}
void build(int *array, int a, int b, int tier ,int * T)
{
	if (a == b) T[tier] = array[a];
	else {
		int middle = (a+b)/2;
		build (array, a, middle, 2 * tier, T);
		build (array, middle + 1, b, 2 * tier + 1, T);
		T[tier] = max(T[2*tier], T[2*tier + 1]);
	}
}
void Update (int *T, int v, int i, int a, int b, int tier)
{
	if (a == b) T[tier] = v;
	else {
		int middle = (a+b)/2;
		if (i <= middle) Update(T, v, i, a, middle, 2 * tier);
		else Update(T, v, i, middle + 1, b, 2 * tier + 1);
		T[tier] = max(T[2*tier], T[2*tier + 1]);
	}
}
int Maximum (int *T, int l, int r, int a, int b, int tier)
{
	if (l == a && r == b) return T[tier];
	else {
		int middle = (a+b)/ 2;
		if (r <= middle) return Maximum(T, l, r, a, middle, 2 * tier);
		else {
			if (l > middle) return Maximum(T, l, r, middle + 1, b, 2 * tier + 1);
			else return max(Maximum(T, l, middle, a, middle, 2 * tier), Maximum(T, middle + 1, r, middle + 1, b, 2 * tier + 1));
		}
	}
}
int main()
{
	char op1[3], op2[3];
	int n, m, l1, r1, l2, r2, v;
	scanf("%d", &n);
	int *array = (int*)malloc(n * sizeof(int));
	if (array == NULL) return -1;
	for (int i = 0; i < n; i = i + 2) {
		if (i == (n - 1)) scanf("%d", &array[i]);
		else scanf("%d%d", &array[i], &array[i+1]);	
	}
	int *T = TreeBuild(array, n);
	scanf("%d", &m);
	for (int i = 0; i < m; i = i + 2) {
		if (i == (m - 1)){
			scanf("%s%d%d", op1, &l1, &r1);
			if (strcmp(op1, "MAX") == 0) printf("%d\n",Maximum(T, l1, r1, 0, n - 1, 1));
			else Update (T, r1, l1, 0, n - 1, 1);
		}
		else {
			scanf("%s%d%d", op1, &l1, &r1);
			if (strcmp(op1, "MAX") == 0) printf("%d\n",Maximum(T ,l1, r1, 0, n - 1, 1));
			else Update (T, r1, l1, 0, n - 1, 1);
			scanf("%s%d%d", op2, &l2, &r2);
			if (strcmp(op2, "MAX") == 0) printf("%d\n",Maximum(T, l2, r2, 0, n - 1, 1));
			else Update (T, r2, l2, 0, n - 1, 1);
			
		}			
	}
	free(T);
	free(array);
	return 0;
}