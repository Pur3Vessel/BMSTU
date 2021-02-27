void bubblesort(unsigned long nel, 
        int (*compare)(unsigned long i, unsigned long j), 
        void (*swap)(unsigned long i, unsigned long j))
{
	unsigned long bound[2];
	unsigned long c  = 0;
	unsigned long t  = 0;
	t = nel - 1;
	c = 0;
	bound[0] = t;
	bound[1] = c;
	t = 0;
	while (bound[0] > t) {
		for (unsigned long i = bound[1]; i < bound[0]; i++) {
			if ((compare(i,i+1)) > 0) {
				swap(i,i+1);
				t = i;
			}
		}
		c = t;
		for (unsigned long i = c; i > bound[1]; i--) {
			if (compare(i-1,i) > 0) {
				swap(i-1, i);
				c = i;
			}	
		}
		bound[1] = c;
		bound[0] = t;
		t = c;		 
	}
	
} 