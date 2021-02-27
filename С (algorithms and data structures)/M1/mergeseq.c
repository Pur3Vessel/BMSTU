#include <stdio.h>
#include <stdlib.h>
int main()
{
	int n1, n2, i, j;
	scanf("%d", &n1);
	int *p1 = (int*)malloc(n1 * sizeof(int));
	if (p1 == NULL) return -1;
	for (i = 0; i < n1; i++) scanf("%d", &p1[i]);
	scanf("%d", &n2);
	int *p2 = (int*)malloc(n2 * sizeof(int));
	if (p2 == NULL) return -1;
	for (i = 0; i < n2; i++) scanf("%d", &p2[i]);	
	i = j = 0;
	while ((i != n1) && (j != n2)) {
		if (p1[i] >= p2[j]) {
			printf("%d ", p2[j]);
			j++;
			}
		else {
			printf("%d ", p1[i]);
			i++;
			}
		}
	if (i == n1) {
		for (int k = j; k < n2; k++) printf("%d ", p2[k]);
		}
	else {
		for (int k = i; k < n1; k++) printf("%d ", p1[k]);
		}
	free(p1);
	free(p2);
	return 0;
}