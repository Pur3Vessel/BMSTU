#include <stdio.h>
#include <stdlib.h>
#define size_t int
void swap (size_t *arr, size_t i, size_t j) 
{
	size_t t = arr[i];
	arr[i] = arr[j];
	arr[j] = t;	
}
void merger (size_t *array, size_t k, size_t l, size_t m)
{
	size_t temp[m - k + 1];
	size_t i, j, h;
	i = k;
	j = l + 1;
	h = 0;
	while (h < m - k + 1) {
		if ((j <= m) && ((i == l + 1) || (abs(array[j]) < abs(array[i])))) temp[h++] = array[j++];
		else temp[h++] = array[i++];	
	}
	for (size_t a = k, h = 0; a < m + 1; a++, h++) array[a] = temp[h];
} 
void insertsort (size_t *arr, size_t low, size_t high)
{
	size_t loc = 0;
	for (size_t i = low + 1; i < high + 1; i++) {
		loc = i - 1;
		while ((loc >= low) && (abs(arr[loc]) > abs(arr[loc+1]))) {
			swap(arr, loc, loc + 1);
			loc--;
		}
	} 
}
void mergesortrec(size_t low, size_t high, size_t *arr)
{
	if (low < high) {
		if ((high - low) <= 4) insertsort(arr, low, high);
		else {
			size_t mid = (low + high) / 2;
			mergesortrec(low, mid, arr);
			mergesortrec(mid + 1, high, arr);
			merger(arr, low, mid, high);
		}
	}
}
void mergesort (size_t *arr, size_t n)
{
	mergesortrec(0, n - 1, arr);
}
int main()
{
	size_t n;
	scanf("%d", &n);
	size_t array[n];
	for (size_t i = 0; i < n; i++) scanf("%d", &array[i]);
	mergesort(array, n);
	for (size_t i = 0; i < n; i++) printf("%d ", array[i]);
	return 0;
}