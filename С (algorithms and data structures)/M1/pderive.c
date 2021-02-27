#include <stdio.h>

int main ()
{
	char k;
	int n;
	long x0, ai;
	long ans = 0;
	scanf("%d%hhd%ld", &n, &k, &x0);
	for (int i = n; i >= k; i--) {
		scanf("%ld", &ai);
		for (char j = 0; j < k; j++) ai *= (i-j);
		ans += ai;
		if (i != k) ans *= x0;	
		}
	printf("%ld", ans);
	return 0;
}