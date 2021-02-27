void revarray(void *base, unsigned long nel, unsigned long width)
{
	char t;
	for (unsigned long i = 0; i < (nel / 2); i++) {
		for (unsigned long j = 0; j < width; j++) {
			t = *((char*)base);
			*((char*)base) = *((char*)(base + (nel*width - width - i * 2 * width)));
			*((char*)(base + (nel*width - width - i * 2 * width))) = t;
			(char*)base++;
			}
		}
	
}