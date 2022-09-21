
#include <wchar.h>
#include <locale.h>
#include <string.h>
#include <stdio.h>

static int scanverbatim(char *fmt)
{
	return scanf(fmt);
}

static int scanuint(char *fmt, unsigned long long *res)
{
	return scanf(fmt, res);
}

static int scanint(char *fmt, long long *res)
{
	return scanf(fmt, res);
}

static int scandouble(char *fmt, double *res)
{
	return scanf(fmt, res);
}

static int scanchar(char *fmt, wchar_t *res)
{
	setlocale(LC_ALL, "");
	return scanf(fmt, res);
}

static int scanstring(char *fmt, char **res)
{
	return scanf(fmt, res);
}

#define INITIAL_SIZE 128

static char *getstring()
{
	char *s;
	int flag, len = 0, size = INITIAL_SIZE;

	s = (char*)malloc(INITIAL_SIZE);
	if (s == NULL) return NULL;

	do {
		if (fgets(s+len, size-len, stdin) == NULL) {
			free(s);
			return NULL;
		}

		len += (int)strlen(s+len);
		flag = s[len-1] != '\n';

		if (flag) {
			char *new_s = (char*)malloc(size *= 2);
			if (new_s == NULL) {
				free(s);
				return NULL;
			}

			memcpy(new_s, s, len);
			free(s);
			s = new_s;
		}
	} while (flag);

	s[len-1] = 0;
	return s;
}
