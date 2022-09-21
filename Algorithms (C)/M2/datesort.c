#include <stdio.h>
#include <stdlib.h>
struct Date {
	int Day, Month, Year;
};
int key_based(int class)
{
	switch (class) {
		case 2:
			return 32;
		case 1:
			return 13;
		case 0: 
			return 61;
	}
}
int key(struct Date *dates, int class, int i)
{
	switch (class) {
		case 32:
			return dates[i].Day;
		case 13:
			return dates[i].Month;
		case 61: 
			return dates[i].Year - 1970;
	}
}
struct Date* distsort (int m, int n, struct Date *dates)
{
	int *count = (int*)malloc(m*sizeof(int));
	for (int j = 0; j < m; j++) count[j] = 0;
	struct Date *dest = (struct Date*)malloc(n*sizeof(struct Date));
	int k, i;
	for (int j = 0; j < n; j++) {
		k = key(dates, m, j);
		count[k]++;
	}
	for (int j = 1; j < m; j++) count[j] += count[j-1];	
	for (int j = n - 1; j>=0; j--) {
		k = key(dates, m, j);
		i = count[k] - 1;
		count[k] = i;
		dest[i].Day = dates[j].Day;
		dest[i].Month = dates[j].Month;
		dest[i].Year = dates[j].Year;
	}
	free(dates);
	free(count);
	return dest;
}
struct Date* datesort(struct Date *dates, int classes, int n)
{
	for (int i = classes - 1; i >=0 ; i--) dates = distsort(key_based(i), n, dates);
	return dates;
}

int main()
{
	int n;
	scanf("%d", &n);
	struct Date *dates = (struct Date*)malloc(n*sizeof(struct Date));
	if (dates == NULL) return -1;
	for (int i = 0; i < n; i++) scanf("%d%d%d", &dates[i].Year, &dates[i].Month, &dates[i].Day);
	dates = datesort(dates, 3, n);
	for (int i = 0; i < n; i++) printf("%d %d %d\n", dates[i].Year, dates[i].Month, dates[i].Day);
	free(dates);
	return 0;
}