unsigned long binsearch(unsigned long nel, int (*compare)(unsigned long i)) 
{
	unsigned long index = nel;
	unsigned long right = nel - 1;
	unsigned long left = 0;
	unsigned long mid = (right + left) / 2;
	while (right >= left) {
		if (compare (mid) == 0) {
			index = mid;
			break;
			}
		if (compare (mid) > 0) right = mid - 1;
		else left = mid + 1;
		mid = (right + left) / 2;		
		}
	return index;
}