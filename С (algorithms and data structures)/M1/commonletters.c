#include <stdio.h>

int main()
{
	unsigned long str;
	unsigned long str1 = 0;
	unsigned long str2 = 0;
	char sym = 0;
	while (sym != 32) {
		scanf("%c", &sym);
		if (sym != 32) {
			if (sym <= 90) str1 = (str1 | (1UL << (unsigned long)(sym - 65)));
			else str1 = (str1 | (1UL << (unsigned long)(sym - 71)));
			}
		}
	sym = 0;

	while (sym != 10) {
		scanf("%c", &sym);
		if (sym != 10) {
			if (sym <= 90) str2 = (str2 | (1UL << (unsigned long)(sym - 65)));
			else str2 = (str2 | (1UL << (unsigned long)(sym - 71)));
			}
		}
	str = str1 & str2;
	for (char i = 0; i <= 51; i++) {
		if ((str & (1UL << (unsigned long)i)) != 0) {
			if (i < 26) printf("%c", i + 65);
			else printf("%c", i + 71);
			}
		}
	return 0;
}