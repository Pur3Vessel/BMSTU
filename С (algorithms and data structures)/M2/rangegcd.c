#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int NOD(int a, int b)
{
	int c;
	while (b != 0) {
		c = a % b;
		a = b;
		b = c;
		
	}
	return abs(a);
		
}
int *computelogarithms(int m)
{
	int *lg = (int*)malloc(1000000 *m * sizeof(int));
	int i = 1, j = 0;
	while (i < m+1) {
		while (j < pow(2,i)) lg[j++] = i - 1;
		i++;
	}
	return lg;
}
int **sparsetable_build(int *array, int *lg, int n)
{
	int m = lg[n] + 1;
	int **ST = (int**)malloc(n * m * sizeof(int*));
	for (int i = 0; i < n; i++) ST[i] = (int*)malloc(m*sizeof(int));
	for (int i = 0; i < n; i++) ST[i][0] = array[i];
	for (int j = 1; j < m; j++) {
		for (int i = 0; i <= (n - pow(2,j)); i++) ST[i][j] = NOD(ST[i][j - 1], ST[i + (int)pow(2, j-1)][j - 1]);
	}
	return ST;
	
}
void sparsetable_querry(int **ST, int l, int r, int *lg)
{
	int j = lg[r-l+1];
	int v = NOD(ST[l][j], ST[r - (int)pow(2,j) + 1][j]);
	printf("%d\n", v);
}
int main()
{
	int n, m, l, r;
	scanf("%d", &n);
	int *array = (int*)malloc(n*sizeof(int));
	if (array == NULL) return -1;
	for (int i = 0; i < n; i++) scanf("%d", &array[i]);
	int *lg = computelogarithms(20);
	int **ST = sparsetable_build(array, lg, n);
	scanf("%d", &m);
	for (int i = 0; i < m; i++) {
		scanf("%d%d", &l, &r);
		sparsetable_querry(ST, l, r, lg);
	}
	for (int i = 0; i < n; i++) free(ST[i]);
	free(array);
	free(lg);
	free(ST);
	return 0;
}
