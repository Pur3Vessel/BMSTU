#include <stdio.h>

int main ()
{
	int n, k, a;
	int ind = 0;
	long sum = 0;
	scanf("%d%d", &n, &k);
	int last [k];
	for (int i = 0; i < k; i = i + 2) {
		if (i == (k - 1)) {
			scanf("%d", &last[i]);
			sum += last[i];
			}
		else {
			scanf("%d%d", &last[i], &last[i+1]);
			sum += (last[i] + last[i+1]);
			}
		}
	long max_sum = sum;
	for (int i = k; i < n; i++) {
		scanf("%d", &a);
		if (max_sum < sum - last[i%k] + a) {
			max_sum = (sum - last[i%k] + a);
			ind = i - k + 1;
			}	
		sum = (sum - last[i%k] + a);
		last[i%k] = a;
		}
	
	printf("%d", ind);
	return 0;
}