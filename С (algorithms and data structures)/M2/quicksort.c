#include <stdio.h>
#include <stdlib.h>
#define size_t int
void selectsort (size_t *arr, size_t left, size_t right)
{
	size_t i, k, t, j = right;
	while (j > left) {
		k = j;
		i = j - 1;
		while (i >= left) {	
			if (arr[k] < arr[i]) k = i;
			i--;
		}
		t = arr[j];
		arr[j--] = arr[k];
		arr[k] = t;
	}
} 
size_t partition (size_t left, size_t right, size_t *arr)
{
	size_t i, j, t;
	i = j = left;
	while (j < right) {
		if (arr[j] < arr[right]) {
			t = arr[j];
			arr[j] = arr[i];
			arr[i++] = t;
		}
		j++;
	}
	t = arr[i];
	arr[i] = arr[right];
	arr[right] = t;
	return i;
}
void quicksort (size_t *arr, size_t left, size_t right, size_t m)
{
	while((right-left) > 0) {
		if ((right - left + 1) < m) {
			selectsort(arr, left, right);
			break;
		} 
		size_t q = partition(left, right, arr);
		if ((right - q) >= (q - left)) {
			quicksort(arr, left, q-1, m);
			left = q + 1;
		}
		else {
			quicksort(arr, q+1, right, m);
			right = q - 1;
		}
	}
		
	
}
int main()
{
	size_t n, m;
	scanf("%d%d", &n, &m);
	size_t *arr = (size_t*)malloc(n*sizeof(size_t));
	if (arr == NULL) return -1;
	for (size_t i = 0; i < n; i++) scanf("%d", &arr[i]);
	quicksort(arr, 0, n-1, m);
	for (size_t i = 0; i < n; i++) printf("%d ", arr[i]);
	free(arr);
	return 0;
}