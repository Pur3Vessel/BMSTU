assume CS:code, DS:data, SS:stack

data segment 
    errMsg db "Wrong length$" 
    buf db 200 dup(?)  
    acc dw 0
    len dw ?
    maxLen dw 1000 ;; Максимальная длина - 1000
    min dw ?
    arr db 2000 dup(?)
data ends
stack segment Stack
    db 100h dup(?)
stack ends
code segment
    ;; Вариант 1 - поиск мин элемента массива. Решил сделать ввод массива посимвольно с клавиатуры
    start:
    
    mov ax, data
    mov ds, ax
    mov es, ax
    ;; Сначала посимвольно формируется число, задающее длину массива. Когда на ввод приходит enter начинается ввод самого массива
    xor ax, ax
    mov ah, 01h
    int 21h
    sub al, 30h
    mov ah, 0
    mov bx, 10
    mov cx, ax
    continue:
        mov ah, 01h
        int 21h
        cmp al, 0dh
        je ent
        sub al, 30h
        mov ah, 0
        xchg ax, cx
        mul bx
        add cx, ax
        jmp continue
    ent: 
    cmp cx, [maxlen]
    jbe noter
    mov dx, offset errmsg
    mov ah, 09h
    int 21h
    mov ax, 4C00h
    int 21h
    notER:
    mov [len], cx
    ;; Такой же посимвольный ввод самого массива. Пробел - текущее число закончилось, enter - ввод массива прекращается
    ;; Работу с массивом я осуществляю черех stosw и lodsw
    mov di, offset arr
    cld
    star:
        mov ah, 01h
        int 21h
        cmp al, 0dh
        je ent2
        cmp al, 20h
        je star
        sub al ,30h
        mov ah, 0
        mov bx, 10
        mov cx, ax
        cont2:
            mov ah, 01h
            int 21h
            cmp al, 20h
            je space
            cmp al, 0dh
            je ent3
            sub al, 30h
            mov ah, 0
            xchg ax, cx
            mul bx
            add cx, ax
            jmp cont2
            space:
                mov ax, cx
                stosw
                inc [acc]
                jmp star
            ent3:
                mov ax, cx
                stosw
                inc [acc]
                jmp ent2
    ent2:

    mov ax, [acc]
    mov bx, [len]
    cmp ax, bx
    jne errr ;; Если введенная длина не совпадает с фактической длиной
    mov si, offset arr
    mov cx, [len]
    cld
    lodsw
    mov [min], ax
    dec cx

    l:
        lodsw
        mov bx, [min]
        cmp bx, ax
        ja change
        loop l
        jmp en
        change:
            mov [min], ax
            loop l
    en:
    ;; Вывод числа делается так же, как и в доп задании к 1 лабе
    mov ax, [min]
    mov di, offset buf
    mov cx, 0 
    mov bx, 10
    
    fillStack: 
        mov dx, 0
        div bx
        add dl, '0' 
        push dx
        inc cx 
        test ax, ax
        jnz fillstack 
    makeAnswer:
        pop dx
        mov byte ptr [di], dl
        inc di
        loop makeanswer
   
    mov byte ptr [di], 10
    inc di
    mov byte ptr [di], 13
    inc di
    mov byte ptr [di], "$"

    mov ah, 09h

    mov dx, offset buf
    int 21h
    mov ax, 4C00h
    int 21h

    errr:
        mov dx, offset errmsg
        mov ah, 09h
        int 21h
        mov ax, 4C00h
        int 21h

code ends

end start