#include <stdio.h>

int main()
{
	int m, n, x;
	int sedl[2];
	int max_str = -2147483648;
	scanf("%d%d", &m, &n);
	int min_stl[n];
	char control = 0;
	
	for (int i = 0; i < n; i++)
	{
		scanf("%d", &min_stl[i]);
		if (min_stl[i] == max_str) control = 0;
		if (min_stl[i] > max_str) {
			sedl[1] = i;
			sedl[0] = 0;
			control = 1;
			max_str = min_stl[i];
			}
		
		}
	for (int i = 1; i < m; i++) {
		max_str = -2147483648;
		for (int j = 0; j < n; j++) {
			scanf("%d", &x);
			if (((x >= max_str) && (i == sedl[0])) || ((x <= min_stl[j]) && (j == sedl[1]))) control = 0;
			if ((x > max_str) && (x < min_stl[j])) {
				sedl[0] = i;
				sedl[1] = j;
				control = 1;
				}
			if (x > max_str) max_str = x;
			if (x < min_stl[j]) min_stl[j] = x;
			}
		}
	if (control == 0) printf("none");
	else printf("%d %d", sedl[0], sedl[1]);
	
		
	return 0;
}