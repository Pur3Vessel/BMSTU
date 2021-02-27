#include <stdio.h>
#include <stdlib.h>

int main()
{
	int mn = 2;
	char k;
	int n;
	scanf("%hhd%d", &k, &n);
	char *resheto = (char*)malloc((n-1) * sizeof(char));
	if (resheto == 0) return -1;
	for (int i = 0; i < (n - 1); i++) resheto[i] = 1;
	for (int i = 2; i <= n; i++) {
		if (resheto[i-2] == 1) {	
			for (int j = mn * i; j <= n; mn ++, j = mn * i) {
				resheto[j-2] = resheto[(j/i) - 2] + 1;
				}
			mn = 2;
			}
		if (resheto[i-2] == k) printf("%d ", i);
		}
	free(resheto);
	return 0;
}