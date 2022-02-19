assume CS:code, DS:data, SS:stack
; (f + s + t)/d + 2
; Ответ - 202 или CA
data segment 

    f dw 0064h
    s dw 00C8h
    t dw 012Ch
     d dw 0003h
    res dw ?
    msg db 'base-10: $'
    msg2 db 'base-16: $'
    resMsg db 1Dh dup(?)  ; буфер на 30 символов
data ends
stack segment Stack
    db 100h dup(?)
stack ends
code segment

    start:
    
    mov ax, data
    mov ds, ax

    mov ax, [f]
    add ax, [s]
    add ax, [t]
    mov bx, [d]
    cwd
    div bx
    add ax, 0002h
    mov [res], ax

    mov di, offset resmsg ; "наводка" индексного регистра на буфер
    mov cx, 0 
    mov bx, 10
    ;; Cуть меток fillstack и fillstack2 - делить число на основание системы счисления и заносить результат (уже в виде символа Аски) в стак
    fillStack: 
        mov dx, 0
        div bx
        add dl, '0' ;  цифра становится этой же цифрой, только уже в Аски
        push dx
        inc cx ; накопление счетчика цикла
        test ax, ax ; проверка: рассмотрели уже все цифры или нет
        jnz fillstack 
    makeAnswer:
        pop dx
        mov byte ptr [di], dl
        inc di
        loop makeanswer
    ; Добавление перевода строки, возврата каретки и символа конца строки
    mov byte ptr [di], 10
    inc di
    mov byte ptr [di], 13
    inc di
    mov byte ptr [di], "$"

    mov AH, 09h
    mov DX, offset msg
    int 21h
    mov DX, offset resmsg
    int 21h
    
    mov ax, [res]
    mov di, offset resmsg
    mov cx, 0
    mov bx, 16

    fillStack2:
        mov dx, 0
        div bx
        cmp dl, 9  ; Если результат больше 9, то это символы A-F и тогда нужно прибавить еще 7 (чтоб прийти на соответствующие символы в Аски)
        jbe skip
        add dl, 7
    skip:
        add dl, '0'
        push dx
        inc cx
        test ax, ax
        jnz fillstack2
    makeAnswer2:
        pop dx
        mov byte ptr [di], dl
        inc di
        loop makeanswer2

    mov byte ptr [di], 10
    inc di
    mov byte ptr [di], 13
    inc di
    mov byte ptr [di], "$"

   
    

    mov AH, 09h
    mov dx, offset msg2
    int 21h
    mov DX, offset resmsg
    int 21h

    mov ax, 4C00h
    int 21h


code ends

end start