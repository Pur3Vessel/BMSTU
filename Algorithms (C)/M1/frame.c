#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
	
	if (argc != 4) {
		printf("Usage: frame <height> <width> <text>");
		return 0;
		}
	int height = atoi(argv[1]);
	int width = atoi(argv[2]);
	if ((height < 3) || (strnlen(argv[3], 1000) > (width - 2))) {
		printf("Error");
		return 0;
		}
	for (int i = 0; i < width; i++) printf("*");
	printf("\n");
	int word = (height + 1)/ 2;
	for (int i = 0; i < word - 2; i++) {
		printf("*");
		for (int j = 0; j < width - 2; j++) printf(" ");
		printf("*\n");
	} 
	printf("*");
	int mid = (width -  2 - (strnlen(argv[3], 1000)))/ 2;
	for (int i = 0; i < mid; i++) printf(" ");
	for (int i = 0; i < (strnlen(argv[3], 1000)); i++) printf("%c", argv[3][i]);
	for (int i = 0; i < (width -  2 - (strnlen(argv[3], 1000))) - mid; i++) printf(" ");
	printf("*\n");
	for (int i = 0; i < (height - word - 1) ; i++) {
		printf("*");
		for (int j = 0; j < width - 2; j++) printf(" ");
		printf("*\n");
	} 
	for (int i = 0; i < width; i++) printf("*");
	
	return 0;
} 