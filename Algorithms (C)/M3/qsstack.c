#include <stdio.h>
#include <stdlib.h>
typedef struct task task;
typedef struct stack stack;
struct task {
    int low, high;
};
struct stack 
{
    task *data;
    int cap, top;
};
void init(stack *s,int n)
{
    s->cap = n;
    s->top = 0;
    s->data = (task*)malloc(n*sizeof(task));
}
int empty(stack *s)
{
    return s->top;
}
void push (stack *s, task val)
{
    s->data[s->top++] = val;
}
task pop(stack *s)
{
    return s->data[--s->top];
}
int partition (int left, int right, int* array)
{
    int i = left, j = left, t;
    while (j < right) {
        if (array[j] < array[right]) {
            t = array[j];
            array[j] = array[i];
            array[i++] = t;
        }
        j++;
    }
    t = array[i];
    array[i]= array[right];
    array[right] = t;
    return i;
}
void qsstack(int* array, int n)
{
    int q;
    stack s;
    stack *sp = &s;
    init(sp, 2 * n);
    task current_task, start_task, new_task;
    start_task.low = 0;
    start_task.high = n - 1;
    push(sp, start_task);
    while (empty(sp) != 0) {
        current_task = pop(sp);
        q = partition(current_task.low, current_task.high, array);
        if (q - 1 > current_task.low) {
            new_task.low = current_task.low;
            new_task.high = q - 1;
            push(sp, new_task);
        }
        if (current_task.high > q + 1) {
            new_task.high = current_task.high;
            new_task.low = q + 1;
            push(sp, new_task);
        }
    }

    free(s.data);
}
int main()
{
    int n;
    scanf("%d", &n);
    int* array = (int*)malloc(n * sizeof(int));
    if (array == NULL) return -1;
    for (int i = 0; i < n; i++) scanf("%d", &array[i]);
    qsstack(array, n);
    for (int i = 0; i < n; i++) printf("%d ", array[i]);
    free(array);
    return 0;
}