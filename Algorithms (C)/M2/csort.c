#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define size 300
#define size_t int
size_t words_counter(char *src)
{
	size_t count = 0;
	for (size_t i = 0; i < strnlen(src, size); i++) {
		if (src [i] == ' ') continue;
		else {
			count++;
			while ((src [i] != ' ') && (src[i] != 0)) i++;
		}
	}
	return count;
}

void csort(char *src, char *dest) 
{
	size_t n = 0;
	n = words_counter(src);
	size_t wordslength[n];
	size_t count[2][n];
	for (size_t i = 0; i < n; i++) {
		count[0][i] = 0;
		count[1][i] = 0;
		wordslength[i] = 0;
	}
	size_t w = 0;
	for (size_t i = 0; i < strnlen(src, size); i++) {
		if (src[i] == ' ') continue;
		else {
			count[0][w] = i;
			while (src[i] != ' ' && src[i] != 0) {
				wordslength[w]++;
				i++;
			}
			w++;
		}
	}
	//for (size_t i = 0; i < n; i++) printf("%d ", wordslength[i]);
	w = 0;
	for (size_t j = 0; j < n - 1; j++) {
		w = j + 1;
		while (w < n) {
			if (wordslength[w] < wordslength[j]) count[1][j]++;
			else count[1][w]++;
			w++;
		}
	}
	w = 0;
	size_t k = 0;
	for (size_t i = 0; i < n; i++) {
		if (count[1][i] == k) {
			for (size_t j = count[0][i]; j < count[0][i] + wordslength[i]; j++) dest[w++] = src[j];
			if ((k + 1) != n) dest[w++] = ' ';
			k++;
			i = -1;
		}
	}
	dest[w] = 0;
	
}
int main()
{
	char src[size];
	gets(src);
	char dest[size];
	if (dest == NULL) return -1;
	csort(src, dest);
	printf("%s", dest);
	return 0;
}