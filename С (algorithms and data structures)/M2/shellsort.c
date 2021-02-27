void shellsort(unsigned long nel, 
        int (*compare)(unsigned long i, unsigned long j), 
        void (*swap)(unsigned long i, unsigned long j))
{
	unsigned long d, i;
	unsigned long f1 = 1;
	unsigned long f2 = 2;
	while (f2 < nel) {
		d = f2;
		f2 = f2 + f1;
		f1 = d;	
	}
	d = f1;
	while (d > 0) {
		for (long i = d; i < nel; i++) {
			for (long j = i - d; (j >= 0) && (compare(j, j + d) > 0); j -= d ){
				swap(j, j + d);
			}
		}
		if (d == 1) f1 = f2;
		d = f2 - f1;
		f2 = f1;
		f1 = d;
	} 
} 