int maxarray(void *base, unsigned long nel, unsigned long width,
        int (*compare)(void  *a, void  *b))
{
	unsigned long index = 0;
	char *p, *t1, *t2;
	p = (char*)base;
	for (unsigned long i = 0; i < width; i++) (char*)base++;
	for (unsigned long i = 1; i < nel; i++) {
		t1 = (char*)base;
		t2 = p;
		for (unsigned long j = 0; j < width; j++) {
			if (compare (t1, t2) < 0) break;
			if (compare (t1, t2) > 0) {
				index = i;
				p = (char*)base;
				break;
				}
			t1++;
			t2++;
			}
		for (unsigned long j = 0; j < width; j++) (char*)base++;
		}
	return (int)index;
}