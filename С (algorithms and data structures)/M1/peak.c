unsigned long peak(unsigned long nel,
        int (*less)(unsigned long i, unsigned long j))
{
	if ((nel == 1) || (less (0, 1) == 0)) return 0;
	if (less (nel-1, nel-2) == 0) return (nel - 1);
	unsigned long left = 0;
	unsigned long right = nel - 1;
	unsigned long mid = left + (right - left) / 2;
	while (right - left > 2) {
		if (less(mid + 1, mid) == 1) right = mid + 1;
		else left = mid;
		mid = left + (right - left) / 2;	
	}
	if (((right - left == 2) && (less(left,left + 1) == 1)) || (right - left < 2)) return mid;
	else return mid + 1;
}
