#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int NOD(int a, int b)
{
	while (a > 0 && b > 0) {
		if (a > b) a %= b;
		else b %= a;
	}
	return a + b;
		
}
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
int main(int argc, char **argv)
{
	char no = 0;
	int *pi = prefix(argv[1]);
	for (int i = 0; i < strlen(argv[1]); i++) {
		if (pi[i] == 0) continue;
		no = 0;
		for (int j = 0; j + NOD(i+1, pi[i]) < i + 1; j++) {
			if (argv[1][j] != argv[1][j + NOD(i+1,pi[i])]) no = 1;
		}
		if (no == 0) printf("%d %d\n", i+1, (i+1) / NOD (i+1, pi[i]));	
		
	}
	free(pi);
	return 0;
}