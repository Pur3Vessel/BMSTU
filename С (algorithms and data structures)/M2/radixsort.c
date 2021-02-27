#include <stdio.h>
#include <stdlib.h>
union Int32 {
	int x;
	unsigned char bytes[4];
};
union Int32* alt_distsort(int key, int n, union Int32 *array)
{
	int *count = (int*)malloc(256*sizeof(int));
	for (int j = 0; j < 256; j++) count[j] = 0;
	union Int32 *dest = (union Int32 *)malloc(n*sizeof(union Int32));
	int k, i;
	for (int j = 0; j < n; j++) {
		k = array[j].bytes[key];
		count[k & 128]++;
	}
	for (int j = 254; j >= 0; j--) count[j] += count[j+1];
	for (int j = n - 1; j >= 0; j--) {
		k = array[j].bytes[key];
		i = count[k&128] - 1;
		count[k&128] = i;
		dest[i].x = array[j].x;
	}
	free(array);
	free(count);
	return dest;
	
}
union Int32* distsort(int key, int n, union Int32 *array)
{
	int *count = (int*)malloc(256*sizeof(int));
	for (int j = 0; j < 256; j++) count[j] = 0;
	union Int32 *dest = (union Int32 *)malloc(n*sizeof(union Int32));
	int k, i;
	for (int j = 0; j < n; j++) {
		k = array[j].bytes[key];
		count[k]++;
	}
	for (int j = 1; j < 256; j++) count[j] += count[j-1];
	for (int j = n - 1; j>=0; j--) {
		k = array[j].bytes[key];
		i = count[k] - 1;
		count[k] = i;
		dest[i].x = array[j].x;
	}
	free(array);
	free(count);
	return dest;
	
}
union Int32* radixsort(union Int32 *array, int classes, int n)
{
	for (int i = 0; i < classes; i++) array = distsort(i, n, array);
	array = alt_distsort(3, n, array);
	return array;
}
int main()
{
	int n;
	scanf("%d", &n);
	union Int32 *array = (union Int32*)malloc(n*sizeof(union Int32));
	if (array == NULL) return -1;
	for (int i = 0; i < n; i++) scanf("%d", &array[i].x);
	array = radixsort(array, 4, n);
	for (int i = 0; i < n; i++) printf("%d ", array[i].x);
	free(array);
	return 0;
}