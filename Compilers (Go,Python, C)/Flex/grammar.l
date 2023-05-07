%option noyywrap bison-bridge bison-locations

%{
#include <stdio.h>
#include <stdlib.h>

#define TAG_IDENT 1
#define TAG_SYMBOL 2
#define TAG_KEY 3

char *tag_names[] = {
    "END_OF_PROGRAM", "IDENT", "SYMBOL", "KEY"
};

struct Position {
    int line, pos, index;
};

void print_pos(struct Position *p) {
    printf("(%d,%d)", p->line, p->pos);
}

struct Fragment {
    struct Position starting, following;
};

typedef struct Fragment YYLTYPE;

void print_frag(struct Fragment *f) {
    print_pos(&(f->starting));
    printf("-");
    print_pos(&(f->following));
}

union Token {
    int ident_code;
    char *key_token;
    int symbol_token;
};

typedef union Token YYSTYPE;

int continued;
struct Position cur;

#define YY_USER_ACTION                       \
{                                            \
    int i;                                   \
    if (!continued)                          \
        yylloc->starting = cur;              \
    continued = 0;                           \
                                             \
    for (i = 0; i < yyleng; i++) {           \
        if (yytext [i] == '\n') {            \
            cur.line++;                      \
            cur.pos = 1;                     \
        } else {                             \
            cur.pos++;                       \
        }                                    \
        cur.index++;                         \
    }                                        \
    yylloc->following = cur;                 \
}

typedef struct
{
    char **names;
    int *codes;
    int size;
} Map;

void init_map(Map * map)
{
    map->size = 0;
    map->names = NULL;
    map->codes = NULL;
}

int add_name(Map * map, char *name)
{
    int code = -1;
    for (int i = 0; i < map->size; i++)
    {
        if (strcmp(name, map->names[i]) == 0)
        {
            code = map->codes[i];
            break;
        }
    }
    if (code == -1)
    {
        code = map->size;
        map->size++;
        map->names = (char **)realloc(map->names, sizeof(char *) * map->size);
        map->codes = (int *)realloc(map->codes, sizeof(int) * map->size);
        map->names[map->size - 1] = strdup(name);
        map->codes[map->size - 1] = code;
    }
    return code;
}

void clear_map(Map * map)
{
    for (int i = 0; i < map->size; i++)
    {
        free(map->names[i]);
    }
    free(map->names);
    free(map->codes);
    map->size = 0;
    map->names = NULL;
    map->codes = NULL;
}

void print_map(Map * map)
{
    for (int i = 0; i < map->size; i++)
    {
        printf("code %d: %s\n", map->codes[i], map->names[i]);
    }
}
Map ident_codes;

void init_scanner(const char *path) {
    continued = 0;
    cur.line = 1;
    cur.pos = 1;
    cur.index = 0;
    init_map(&ident_codes);
    yyin = fopen(path, "r");
}

void err(char *msg, char *lexem) {
    printf("Error");
    print_pos(&cur);
    printf(": %s %s\n", msg, lexem);
}
%}

IDENT [a-zA-Z][a-zA-Z0-9]{0,8}[a-zA-Z]
KEY z|for|forward
SYMBOL '((\\[\\'n]|\\[0-9A-Fa-f]{4})|([^'\\\n]))'
SPACE [ \t\r\n\v\f]+
%%
{KEY} {
	yylval->key_token = yytext;
	return TAG_KEY;
}
{IDENT} {
    int code = add_name(&ident_codes, yytext);
    yylval->ident_code = code;
	return TAG_IDENT;
}
{SYMBOL} {
    yytext[strlen(yytext) - 1] = '\0';
    yytext++;
    int c = -1;
    if (strlen(yytext) == 1)  c = (int)yytext[0];
    else {
        if (strcmp(yytext, "\\\\") == 0) c = '\\';
        if (strcmp(yytext, "\\'") == 0) c = 39;
        if (strcmp(yytext, "\\n") == 0) c = 10;
        if (strlen(yytext) == 5) {
            yytext++;
            sscanf(yytext, "%x", &c);
        }
    }
	yylval->symbol_token = c;
	return TAG_SYMBOL;
}
{SPACE} 

. err("лексема не распознана", yytext);
%%

int main(int argc, const char **argv) {
    int tag;
    YYSTYPE value;
    YYLTYPE coords;
    init_scanner(argv[1]);

    while(1) {
        tag = yylex(&value, &coords);
        if (tag == 0) {
            printf("\n");
            break;
        }
        else {
            printf("%s ", tag_names[tag]);
            print_frag(&coords);
            if (tag == TAG_IDENT) {
                printf(": %d\n", value.ident_code);
            }
            if (tag == TAG_SYMBOL) {
                printf(": %d\n", value.symbol_token);
            }
            if (tag == TAG_KEY) {
                printf(": %s\n", value.key_token);
            }
        }
    }
    print_map(&ident_codes);
    clear_map(&ident_codes);
    return 0;
}