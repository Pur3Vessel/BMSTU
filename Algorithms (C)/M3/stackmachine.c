#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define max(a,b) ((a) > (b) ? (a) : (b))
#define min(a,b) ((a) < (b) ? (a) : (b))
typedef struct stack stack;

struct stack 
{
    int *data;
    int cap, top;
};
void init(stack *s,int n)
{
    s->cap = n;
    s->top = 0;
    s->data = (int*)malloc(n*sizeof(int));
}
int empty(stack *s)
{
    return s->top;
}
void push (stack *s, int val)
{
    s->data[s->top++] = val;
}
int pop(stack *s)
{
    return s->data[--s->top];
}
int main()
{
    int n, x, a, b;
    char op[5];
    stack s;
    stack *sp = &s;
    init(sp, 10000000);
    scanf("%d", &n); 
    for (int i = 0; i < n; i++) {
        scanf("%s", op);
        if (strcmp(op, "CONST") == 0) {
            scanf("%d", &x);
            push(sp, x);
        }
        if (strcmp(op, "ADD") == 0) {
            a = pop(sp);
            b = pop(sp);
            x = a + b;
            push(sp,x);
        }
        if (strcmp(op, "SUB") == 0) {
            a = pop(sp);
            b = pop(sp);
            x = a - b;
            push(sp,x);
        }
        if (strcmp(op, "MUL") == 0) {
            a = pop(sp);
            b = pop(sp);
            x = a * b;
            push(sp,x);
        }
        if (strcmp(op, "DIV") == 0) {
            a = pop(sp);
            b = pop(sp);
            x = a / b;
            push(sp,x);
        }
        if (strcmp(op, "MAX") == 0) {
            a = pop(sp);
            b = pop(sp);
            x = max(a, b);
            push(sp,x);
        }
        if (strcmp(op, "MIN") == 0) {
            a = pop(sp);
            b = pop(sp);
            x = min(a, b);
            push(sp,x);
        }
        if (strcmp(op, "NEG") == 0) {
            x = pop(sp);
            x *= -1;
            push(sp, x);
        }
        if (strcmp(op, "DUP") == 0) {
            x = pop(sp);
            push(sp, x);
            push(sp, x);
        }
        if (strcmp(op, "SWAP") == 0) {
            a = pop(sp);
            b = pop(sp);
            push(sp, a);
            push(sp, b);
        } 
    }
    
    x = pop(sp);
    printf("%d", x);
    free(s.data);
    return 0;
}