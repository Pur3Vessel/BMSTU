#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int overlap(char *s1, char *s2, int size_m)  /* По-скольки символам конец s1 совпадает с началом s2 */
{
	char *suf;
	int o = 0;
	int s1_last = strnlen(s1, size_m) - 1;
	int s2_len = strnlen(s2, size_m);
	for (int i = s1_last, j = 1; i > 0 && j < s2_len; i--, j++) {
		char *start = (char*)malloc(size_m * sizeof(char));
		char *end = (char*)malloc(size_m * sizeof(char));
		start[j] = 0;
		strncpy(start, s2, j);
		suf = &s1[i];
		strcpy(end, suf);
		if (strcmp(start, end) == 0) o = j;
		free(start);
		free(end); 
	}
	return o;
}
void merger(char *s1, char *s2, int o, char *dop, int size_m)  /* Соединяет s2 и s1 с учетом их overlap */
{
	char *one = (char*)malloc(size_m * sizeof(char));
	char *ov = &s2[o];
	strcpy(one, ov);
	strcpy(dop, s1);
	strcat(dop, one);
	free(one);
	
}

int main()
{
	int size = 30;
	char n = 0; 
	char ind1 = 0;
	char ind2 = 0;
	char *mer1, *mer2;
	scanf("%hhu", &n);
	char len = n;
	int size_m = size * n;
	size_m++;
	char *str_sizes = malloc(n * size_m * sizeof(char));
	if (str_sizes == NULL) return -1;
	char **strings = (char**)malloc(n * size_m * sizeof(char*));
	if (strings == NULL) return -1;
	for (char i = 0; i < n; i++){ 
		strings[i] = str_sizes + (i * size_m);
		scanf("%s", strings[i]);
	}
	int maxo = 0;
	while (len > 1) {
		for (char i = 0; i < n; i++) {
			if (strnlen(strings[i], size_m) == 0) continue;
			for (char j = 0; j < n; j++) {
				if ((i == j) || (strnlen(strings[j], size_m) == 0)) continue;
				if ((overlap(strings[i], strings[j], size_m) > maxo) || (maxo == 0)) {
					maxo = overlap(strings[i], strings[j], size_m);
					mer1 = strings[i];
					mer2 = strings[j];
					ind1 = i;
					ind2 = j;
				}
		
			}
		}
	char *dop = (char*)malloc(10000 * sizeof(char));
	if (dop == NULL) return -1;
	merger(mer1, mer2, maxo, dop, size_m);
	strcpy(strings[ind1], dop);
	strings[ind2][0] = 0;
	len--;
	free(dop);
	maxo = 0;
	}
	for (char i = 0; i < n; i++) {
		if (strings[i][0] != 0) ind1 = i;
	}
	unsigned long ans = strnlen(strings[ind1], 100000);
	printf("%lu", ans);
	free(str_sizes);
	free(strings);
	return 0;
}