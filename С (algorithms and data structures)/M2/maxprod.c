#include <stdio.h>
#include <stdlib.h>
#include <math.h>
void Kadane (float *array, int n, int *ans)
{
	int l = 0, r = 0, start = 0, i = 0;
	float sum = 0, maxsum = array[0];
	while (i < n) {
		sum += array[i];
		if (sum > maxsum) {
			maxsum = sum;
			l = start;
			r = i;
		}
		i++;
		if (sum < 0) {
			sum = 0;
			start = i;
		}
	}
	ans[0] = l;
	ans[1] = r;
	
	
}
int main ()
{
	int n, ans[2];
	float a, b;
	scanf("%d", &n);
	float *array = (float*)malloc(n*sizeof(float));
	if (array == NULL) return -1;
	for (int i = 0; i < n; i++) {
		scanf("%f/%f", &a, &b);
		if (a == 0) array[i] = -100000000;
		else array[i] = logf(a/b);
		}
	Kadane (array, n, ans);
	printf("%d %d", ans[0], ans[1]);
	free(array); 
	return 0;
}