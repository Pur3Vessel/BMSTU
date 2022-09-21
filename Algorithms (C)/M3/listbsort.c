  #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #define size 10000
 #define o_size 100
typedef struct Elem el;
struct Elem {
    struct Elem *next;
    char *word;
};
el* initlist (el *l)
{
    l = (el*)malloc(sizeof(el));
    l->word = (char*)malloc(o_size * sizeof(char));
    l->next = NULL;
    return l;
}
el* insert(el *l, char *word)
{
    el *nl;
    nl = initlist(nl);
    strcpy(nl->word, word);
    l->next = nl;
    return nl;
}
int length (el *l) 
{
    int len = 0;
    el *x = l;
    while (x != NULL) {
        len++;
        x = x->next;
    }
    return len;

}
void swap(el *z1, el *z2) 
{
    char *t;
    t = z1->word;
    z1->word = z2->word;
    z2->word = t;
}

el *bsort(el *list)
{
    int n = length(list);
    int t = n - 1;
    while (t > 0) {
        int bound = t;
        t = 0;
        int i = 0;
        el *z = list;
        while (i < bound) {
            if (strlen(z->word) > strlen(z->next->word)) {
                swap(z, z->next);
                t = i;
            }
            i++;
            z = z->next;
        }
        
    }
    return list;
}
 int main()
 {
    char *string = (char*)malloc(size * sizeof(char));
    el *list;
    el *start;
    list = initlist(list);
    start = list;
    gets(string);
    int i = 0, j = 0;
    while (string[i] != '\0') {
        char *word = (char*)malloc(o_size * sizeof(char));
        j = 0;
        while (string[i] == ' ') i++;
        while (string[i] != ' ' && string[i] != '\0') word[j++] = string[i++];
        word[j] = '\0';
        list = insert(list, word);
        while (string[i] == ' ') i++;
        free(word);
    }
    list = start;
    list = list->next;
    free(start->word);
    free(start);
    list = bsort(list);
    while (list != NULL) {
        printf("%s ", list->word);
        free(list->word);
        start = list;
        list = list->next;
        free(start);
    }
    free(string);
    return 0;
 }