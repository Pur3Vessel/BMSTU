#include <stdio.h>

int main()
{
	unsigned int n;
	long a, b, an, bn;
	scanf("%u", &n);
	scanf("%ld%ld", &a, &b);
	for (unsigned int i = 0; i < (n - 1); i++) {
		scanf("%ld%ld", &an, &bn);
		if (an > (b + 1)) {
			printf("%ld %ld\n", a, b);
			a = an;
			b = bn;
			}
		if (bn > b) b = bn;
	}
	printf("%ld %ld", a, b);
	
	return 0;
}