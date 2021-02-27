#include <stdio.h>

int main()
{
	unsigned int n;
	unsigned char num_young, num_old, num_current_1, num_current_2 ;
	scanf("%u", &n);
	switch (n) {
	case 1:
		scanf("%hhu", &num_current_1);
		if (num_current_1 == 0) printf("1");
		else printf("0 1");
		break;
	case 2:
		scanf("%hhu%hhu", &num_young, &num_old);
		if (num_young == 0) num_young = 1;
		else {
			num_young = 0;
			num_old = 1;
			}
		if (num_young == 1 && num_old == 1) printf("0 0 1");
		else printf("%hhu %hhu ", num_young, num_old);
		break;
	case 3:
		scanf("%hhu%hhu%hhu", &num_young, &num_old, &num_current_1);
		if (num_young == 0) num_young = 1;
		else {
			num_young = 0;
			num_old = 1;
			}
		if (num_young == 1 && num_old == 0) printf("%hhu %hhu %hhu ", num_young, num_old, num_current_1);
		if (num_young == 0 && num_old == 1 & num_current_1 == 1) printf("0 0 0 1");
		if (num_young == 0 && num_old == 1 & num_current_1 == 0) printf("%hhu %hhu %hhu ", num_young, num_old, num_current_1);
		if (num_young == 1 && num_old == 1) printf ("0 0 1");
		break;
		
	default:
		scanf("%hhu%hhu", &num_young, &num_old);
		if (num_young == 0) num_young = 1;
		else {
			num_young = 0;
			num_old = 1;
			}
		for (unsigned int i = 2; i < n; i = i + 2) {
			if (i == (n - 1)){
				scanf("%hhu", &num_current_1);
				printf("%hhu ", num_young);
				if (num_young == 1 && num_old == 1) {
					num_young = num_old = 0;
					num_current_1 = 1;
					}
				num_young = num_old;
				num_old = num_current_1;
				}
			else {
				scanf("%hhu%hhu", &num_current_1, &num_current_2);
				if (num_young == 1 && num_old == 1) {
					num_young = num_old = 0;
					num_current_1 = 1;
					}
				if (num_old == 1 && num_current_1 == 1) {
					num_old = num_current_1 = 0;
					num_current_2 = 1;
					}
				printf("%hhu %hhu ", num_young, num_old);
				num_young = num_current_1;
				num_old = num_current_2;
				}
			}
		if (num_young == 1 && num_old == 1) printf ("0 0 1");
		else printf("%hhu %hhu ", num_young, num_old);	
		break;
		}		
	return 0;
}