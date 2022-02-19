
; Сначала вводится строка, потом символ
open macro file, handle
    mov dx, offset file
	mov ax, 0
	mov ah, 3dh
	int 21h
    mov handle, ax
endm
create macro file, handle
    mov cx, 0
    mov al, 1
    mov ah, 3ch
    mov dx, offset file
    int 21h
    mov handle, ax
endm
read macro handle, filesize, databuf
    mov ax, 0
    mov ah, 3fh
    mov bx, handle
    mov cx, filesize
    mov dx, offset databuf 
    int 21h
endm
 
input macro databuf, string, symbol
    mov di, offset databuf
    mov si, offset string
    inc si
    mov ax, 0
    mov cx, 0
    see:
        mov al, byte ptr [di]
        cmp al, 10
        je ou
        mov byte ptr [si], al
        inc si
        inc di 
        inc cx
        jmp see
    ou:
    inc di
    mov al, byte ptr [di]  
    mov symbol, al   
    mov si, offset string
    mov byte ptr [si], cl
endm

close macro handle
    mov bx, handle
    mov al, 0
    mov ah, 3eh
    int 21h
endm
write macro handle, filesize, databuf
    mov ax, 0
    mov ah,40h
    mov bx, handle
    mov cx, filesize
    mov dx, offset databuf 
    int 21h
endm

counting macro st, sym
local repet, skip
    mov dx, 0
    mov cx, 0
    mov di, offset st
    mov cl, byte ptr [di]
    inc di
    mov al, sym
    repet:
        mov bl, byte ptr [di]
        cmp al, bl
        jne skip
        inc dx
        skip:
        inc di
        loop repet
endm


print macro resmsg, res
mov di, offset resmsg ; "наводка" индексного регистра на буфер
    mov cx, 0 
    mov bx, 10
    mov ax, res
    ;; Cуть меток fillstack и fillstack2 - делить число на основание системы счисления и заносить результат (уже в виде символа Аски) в стак
    fillStack: 
        mov dx, 0
        div bx
        add dl, '0' ;  цифра становится этой же цифрой, только уже в Аски
        push dx
        inc cx ; накопление счетчика цикла
        test ax, ax ; проверка: рассмотрели уже все цифры или нет
        jnz fillstack  
    mov filesize, cx    
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
endm