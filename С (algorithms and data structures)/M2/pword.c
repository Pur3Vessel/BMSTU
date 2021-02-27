#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
	char* amalgama = (char*)malloc((strlen(argv[1]) + strlen(argv[2])) * 2 * sizeof(char));
	if (amalgama == NULL) return -1;
	strcpy(amalgama, argv[1]);
	strcat(amalgama, argv[2]);
	int *pi = prefix(amalgama);
	for (int i = strlen(argv[1]); i < strlen(amalgama); i++) {
		if (pi[i] == 0) {
			printf("no");
			free(pi);
			free(amalgama);
			return 0;
		}	
	}
	printf("yes");
	free(pi);
	free(amalgama);
	return 0;
}