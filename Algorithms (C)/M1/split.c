int split(char *s, char ***words)
{
	int n = 0;
	int i = 0;
	int k;
	char **w = (char**)malloc(100000 * sizeof(char*));
	while (s[i] != '\0' && s[i] != '\n') {
		while (s[i] == ' ') i++;
		w[n] = (char*)malloc(50 * sizeof(char));
		k = 0;
		while (s[i] != ' ' && s[i] != '\0') {
			w[n][k] = s[i];
			k++;
			i++;
		}
		w[n][k] = 0;
		n++;	
		while (s[i] == ' ') i++;		 			
	}
	*words = w;
	return n;
}