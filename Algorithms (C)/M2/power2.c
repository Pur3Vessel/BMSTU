#include <stdio.h> 
int power2 (int v)   /*является ли число степенью двойки (0, если да)*/
{
	if (v == 0) return 1;
	return v & (v - 1);
}
int rekur(int *num, int n, int ind, int ans, int sum)
{
	if (ind == n-1) {                                    
		sum += num[ind];
		if (power2(sum) == 0) ans++;
		return ans;    
		}                         /* последний шаг рекурсии */         
	else {
		sum += num[ind];
		if (power2(sum) == 0) ans++;
		ind ++;
		ans += rekur(num, n, ind, 0, sum);      /* сочетания с текущим элементом */
		ans += rekur(num, n, ind, 0, sum - num[ind - 1]); /* сочетания без текущего элемента */
		return ans;
	}	
}
int main()
{
	int n;
	scanf("%d", &n);
	int num[n];
	for (int i = 0; i < n; i++) scanf("%d", &num[i]);
	int ans = rekur(num, n, 0, 0, 0);
	printf("%d", ans);
	return 0;
}