#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define VH 100
int* prefix(char *str)
{
	int *pi=(int*)malloc(strlen(str) * sizeof(int));
	pi[0] = 0;
	int t = 0;
	for (int i = 1; i < strlen(str); i++) {
		while ((t > 0) && (str[t] != str[i])) t = pi[t-1];
		if (str[t] == str[i]) t++;
		pi[i] = t;
	}	
	return pi;
}
int *KMP(char *S, char *T)
{
	int *indexes = (int*)malloc(VH * sizeof(int));
	for (int k = 0; k < VH; k++) indexes[k] = -1;
	int *pi = prefix(S);
	int i = 0, q = 0 ;
	for (int k = 0; k < strlen(T); k++) {
		while ((q > 0) && (S[q] != T[k])) q = pi[q-1];
		if (S[q] == T[k]) q++;
		if (q == strlen(S)) {
			indexes[i++] = k - strlen(S) + 1;
			q = pi[q-1];
		}
	}
	free(pi);
	return indexes;
}
int main (int argc, char **argv)
{
	int *indexes = KMP(argv[1],argv[2]);
	int i = 0;
	while (indexes[i] != -1) printf("%d ", indexes[i++]);
	free(indexes);
	return 0;
}