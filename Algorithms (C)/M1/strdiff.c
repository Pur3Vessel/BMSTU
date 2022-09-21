int strdiff(char *a, char *b)
{
	unsigned long i = 0;
	while ((a[i] != 0) || (b[i] != 0)) {
		for (unsigned long j = 0; j < 8; j++) {
			if ((a[i] & (1 << j)) != (b[i] & (1 << j))) return (i*8 + j);
			}		
		i++;
		}
	return -1;
	
}