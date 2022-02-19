assume CS:code, DS:data, SS:stack
;; Задача - реализация функции strcpy: копирование нуль-терменированной строки
;; Реализация этой функции в C предполагает, что программист предусмотрел, что длина источника >= длина приемника
data segment
dummy db 0ah, 'Copied: $'
; источник
string db 100, 103 dup (?) ;; 100 - максимальное количество символов + 1 - на фактическую длину, 1 - на CR, 1 - на 0 (конец строки)
; приемник
string2 db 101 dup(?)
data ends

stack segment Stack
    db 100h dup(?)
stack ends

code segment
;; Передаваемые параметры - на вершине стака - dest, следующий элемент src. Эти аргументы, смещения соответствующих областей в ds. Функция возвращает dest
strcpy proc 
    push bp
    push di
    push si
	mov bp, sp
    
    mov di, [bp + 8] ; dest
    mov si, [bp + 10] ; src
    next:
        cmp byte ptr [si], 0
        je notnext 
        push ax
        mov al, byte ptr [si]
        mov byte ptr [di], al
        pop ax
        inc di
        inc si
        jmp next
    notNext:
        mov byte ptr [di], 0
        push ax
        mov ax, word ptr [bp + 10]
        mov word ptr [bp + 12], ax
        pop ax
        pop si
        pop di
        pop bp
    ret 2 ; В результате на вершине стека останется адрес dest в ds
strcpy endp


start:	mov ax, data
		mov ds, ax
		mov dx, offset string
		mov ax, 0
		mov ah, 0Ah
		int 21h	
		mov dx, offset dummy
		mov ah, 09h
		int 21h
		
		mov di, offset string
		mov bx, 0
		mov bl, byte ptr [di + 1] 
		mov byte ptr [di + bx + 2], "$"
        mov byte ptr [di + bx + 3], 0
        mov dx, offset string
        add dx, 2

        push dx
        push offset string2
        call strcpy



        pop dx
		mov ah, 09h
        int 21h
		mov ah, 4ch
		int 21h
		code ends
		end start