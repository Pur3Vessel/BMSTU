#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define size 300
#define size_t int
int compare (const void *a, const void *b)
{
	size_t ca = 0;
	size_t cb = 0;
	size_t s1 = strnlen(a, size);
	size_t s2 = strnlen(b, size);
	for (size_t i = 0; i < s1; i++) {
		if ((*((char*)a + i) == 97)) ca++;
	}
	for (size_t i = 0; i < s2; i++) {
		if ((*((char*)b + i) == 97)) cb++;
	}

	return ca < cb ? 1 : 0;
}
void Heapify (size_t i, size_t n, void *base, int (*compare)(const void *a, const void *b), size_t width)
{
	size_t j, r1, l1;
	char z;
	char *l, *r, *t, *s;
	for (;;) {
		l = r = t = s = (char*)base;
		l1 = 2*i + 1;
		r1 = l1 + 1;
		l += l1 * width;
		r += r1 * width;
		t += i * width;
		j = i;
		if ((l1 < n) && (compare(t, l) == 1)) {
			i = l1;
			t = (char*)base;
			t += i * width;
			}
		if ((r1 < n) && (compare(t, r) == 1)) {
			i = r1;
			t = (char*)base;
			t += i * width;
			}
		if (i == j) break;
		s += j * width;
		for (size_t k = 0; k < width; k++) {
			z = *(char*)s;
			*(char*)s = *(char*)t;
			*(char*)t = z;
			s += 1;
			t += 1;
		}
	}
}
void BuildHeap (size_t n, void *base, int (*compare)(const void *a, const void *b), size_t width)
{
	size_t p = (n/2) - 1;
	while (p >= 0) {
		Heapify(p, n, base, compare, width);
		p--;
	}
}
void hsort(void *base, size_t nel, size_t width, 
	int (*compare)(const void *a, const void *b))
{
	char *t, *b;
	char o;
	BuildHeap(nel, base, compare, width);
	size_t i = nel - 1;
	t = (char*)base;
	t += i * width;
	b = (char*)base;
	while (i > 0) {
		for (size_t j = 0; j < width; j++) {
			o = *(char*)b;
			*(char*)b = *(char*)t;
			*(char*)t = o;
			t += 1;
			b += 1;
		}
		b = (char*)base;
		t -= 2 * width;
		Heapify(0, i, base, compare, width);
		i--;
	}
}
int main()
{
	size_t n;
	scanf("%d", &n);
	char arr[n][size];
	for (size_t i = 0; i < n ; i++) scanf("%s", arr[i]);
	hsort(arr, n, size , compare); 
	for (size_t i = 0; i < n; i++) printf("%s\n", arr[i]);
	return 0;
}