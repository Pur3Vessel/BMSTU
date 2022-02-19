assume cs: code, ds: data

data segment
dummy db 0ah, '$'
info1 db "a: $"
info2 db "b: $"
info3 db "a + b:$"
info4 db "a - b:$"
info5 db "a * b:$"
foam dw 0 ; перенос
negative dw 0 ; отрицательный ответ при вычитании
negative1 dw 0 ; первое число отрицательное
negative2 dw 0 ; второе число отрицательное
equal dw 0 ; числа равны (для вычитания)
arg1 db 31, 32 dup (?)
arg2 db 31, 32 dup (?)
answer db 60 dup (23)
bufer db 60 dup (23)
data ends



stack segment Stack
    db 100h dup(?)  
stack ends



code segment

;ввод числа и преобразование строки
proc input
    mov bp, sp
    mov dx, [bp + 2]
    mov ax, 0
	mov ah, 0Ah
	int 21h
    mov di, [bp + 2]
    add di, 2
    mov cx, 0
    treatment:
        cmp byte ptr [di], 13
        je out1
        cmp byte ptr [di], 45
        je net
        sub byte ptr [di], '0'
        cmp cx, 1
        jne s
        mov al, byte ptr [di]
        mov byte ptr [di - 1], al
        s:
        inc di
        jmp treatment
    net:
    sub byte ptr [di - 1], 1
    mov cx, 1
    inc di
    jmp treatment
    out1:
    mov dx, offset dummy
	mov ah, 09h
	int 21h
    ret
endp input

; обратное преобразование строки и ее вывод
proc print
    mov di, offset answer
    mov cx, 60
    prepare:
        mov al, byte ptr [di]
        cmp al, 23
        je not0
        add al, '0'
        mov byte ptr [di], al
        jmp sk
        not0:
        sub al, 10
        mov byte ptr [di], al
        sk:
        inc di
        loop prepare 
    mov byte ptr [di], "$"
    mov dx, offset answer
    mov ah, 09h
	int 21h
    call restore
	ret	
endp
; восстановление answer 
 proc restore
    mov di, offset answer
    mov cx, 60
    rest:
        mov byte ptr [di], 23
        inc di
        loop rest
    ret    
endp
; Сравнение двух аргументов. В результате подача аргументов в функции для счета идет в порядке большее число - меньшее число
proc Compare
    mov di, offset arg1
    mov si, offset arg2
    mov dx, 0
    mov bx, 0
    mov dl, byte ptr [di + 1]
    mov bl, byte ptr [si + 1]
    cmp dx, bx 
    ja greater
    jl less
    add di, 2
    add si, 2
    cm:
        mov bl, byte ptr [di]
        mov dl, byte ptr [si]
        cmp bl, 13
        je equa
        cmp bl, dl
        ja greater
        jl less
        inc di
        inc si
        jmp cm
        equa: 
            mov ax, 1
            mov [equal], 1
            jmp out2
        greater:
            mov ax, 1
            jmp out2
        less:
            mov ax, 0
            mov [negative], 1
            jmp out2    
    out2:
    ret
endp
; первая фаза длится пока меньшее число не закончится, вторая фаза - обработка "переноса"
proc AddBig 
    mov bp, sp
    mov di, [bp + 2]
    mov si, [bp + 4]
    mov bx, offset answer
    add bx, 59
    mov dx, 0
    mov cx, 0
    mov dl, byte ptr [di + 1]
    mov cl, byte ptr [si + 1]
    add di, 2
    add di, dx
    dec di
    add si, 2
    add si, cx
    dec si
    mov [foam], 0
    sub dx, cx
    Addfase1:
        mov ax, 0
        mov al, byte ptr [di]
        add al, byte ptr [si]
        add ax, [foam]
        mov [foam], 0
        cmp ax, 10
        jl nf
        mov [foam], 1 
        push bx
        mov bl, 10
        div bl
        pop bx
        mov al, ah
        mov ah, 0
        nf:
        mov byte ptr [bx], al
        dec di
        dec si
        dec bx
        loop addfase1
    mov cx, dx
    cmp cx, 0
    je ska
    addfase2:
        mov ax, 0
        mov al, [di]
        add ax, [foam]
        mov [foam], 0
        cmp ax, 10
        jl nf2
        mov [foam], 1
        push bx
        mov bl, 10
        div bl
        pop bx
        mov al, ah
        mov ah, 0
        nf2:
        mov byte ptr [bx], al
        dec di
        dec bx
        loop addfase2
    ska:    
    cmp [foam], 1
    jne nf3
    mov byte ptr [bx], 1    
    nf3:
    ret    
endp
proc SubBig
    mov bp, sp
    mov di, [bp + 2]
    mov si, [bp + 4]
    mov bx, offset answer
    add bx, 59
    mov dx, 0
    mov cx, 0
    mov dl, byte ptr [di + 1]
    mov cl, byte ptr [si + 1]
    add di, 2
    add di, dx
    dec di
    add si, 2
    add si, cx
    dec si
    mov [foam], 0
    sub dx, cx
    mov ax, [equal]
    cmp ax, 1
    jne subfase1
    mov byte ptr [bx], 0
    ret
    Subfase1:
        mov ax, 0
        mov al, byte ptr [di]
        sub ax, [foam]
        mov [foam], 0
        mov ah, byte ptr [si]
        cmp al, ah 
        jae ff
        mov [foam], 1
        add al, 10
        ff:
        sub al, ah
        mov byte ptr [bx], al
        dec di
        dec si
        dec bx
        loop subfase1
    mov cx, dx
    cmp cx, 0
    je ska2
    subfase2:
    mov ax, 0
        mov ax, 0
        mov al, byte ptr [di]
        sub ax, [foam]
        mov [foam], 0
        cmp al, -1
        jne ff2
        mov [foam], 1
        add al, 10
        ff2:
        mov byte ptr [bx], al
        dec di
        dec bx
        loop subfase2
    ska2:
    call skip0   
    ret    
endp
; сносит нули в старших разрядах и добавляет "-" в начале, если negative = 1
proc skip0
    mov di, offset answer
    o1:
        mov al, byte ptr [di]
        cmp al, 23
        je o3
        cmp al, 0
        jne o2
        mov byte ptr [di], 23
        o3:
        inc di
        jmp o1
    o2:
        mov ax, 0
        mov ax, [negative]
        cmp al, 0
        je o4
        dec di
        mov byte ptr [di], -3
    o4:
    ret
endp

;  Первая фаза - умножение на младший разряд, далее идет умножение на следующие разряды и сложение с помощью вспомогательной функции
proc mulbig
    mov [foam], 0
    mov bp, sp
    mov di, [bp + 2]
    mov si, [bp + 4]
    mov bx, offset answer
    add bx, 59
    mov dx, 0
    mov cx, 0
    mov cl, byte ptr [di + 1]
    push cx
    mov dl, byte ptr [si + 1]
    add di, 2
    add di, cx
    dec di
    push di
    add si, 2
    add si, dx
    dec si
    dec cx
    cmp cx, 0
    je fasesk
    mulfase1:
        mov ax, 0
        mov al, byte ptr [di]
        mul byte ptr [si]
        add ax, [foam]
        mov [foam], 0
        cmp ax, 10
        jl m1
        push bx
        mov bl, 10
        div bl
        mov bx, 0
        mov bl, al
        mov [foam], bx
        pop bx
        mov al, ah
        mov ah, 0
        m1:
        mov byte ptr [bx], al
        dec di
        dec bx
        loop mulfase1  
    fasesk:    
    mov ax, 0
    mov al, byte ptr [di]
    mul byte ptr [si]
    add ax, [foam]
    mov [foam], 0  
    cmp ax, 10
    jae m2
    mov byte ptr [bx], al
    jmp m3   
    m2:
    push bx
    mov bl, 10
    div bl
    pop bx
    mov byte ptr [bx], ah
    dec bx
    mov byte ptr [bx], al 
    m3:
    dec dx
    dec si
    mulfase2:
        cmp dx, 0
        je endmul
        mov bx, offset bufer
        add bx, 59
        push si
        mov si, offset arg2
        mov cx, 0
        mov cl, byte ptr [si + 1]
        pop si
        sub cx, dx
        nuls:
            mov byte ptr [bx], 0
            dec bx
            loop nuls
        pop di    
        pop cx
        push cx
        push di
        dec cx    
        subfase:
            mov ax, 0
            mov al, byte ptr [di]
            mul byte ptr [si]
            add ax, [foam]
            mov [foam], 0
            cmp ax, 10
            jl m4
            push bx
            mov bl, 10
            div bl
            mov bx, 0
            mov bl, al
            mov [foam], bx
            pop bx
            mov al, ah
            mov ah, 0
            m4:
            mov byte ptr [bx], al
            dec di
            dec bx
            loop subfase 
        mov ax, 0
        mov al, byte ptr [di]
        mul byte ptr [si]
        add ax, [foam]
        mov [foam], 0  
        cmp ax, 10
        jae m5
        mov byte ptr [bx], al
        jmp m6   
        m5:
        push bx
        mov bl, 10
        div bl
        pop bx
        mov byte ptr [bx], ah
        dec bx
        mov byte ptr [bx], al
        m6:
        call mulad
        dec dx
        dec si    
        jmp mulfase2    
    endmul:
    pop cx
    pop di
    ret
endp 

proc mulad
    push di
    push si
    mov di, offset bufer
    mov si, offset answer
    add di, 59
    add si, 59
    mov [foam], 0
    mulAddfase1:
        mov ax, 0
        mov al, byte ptr [si]
        cmp al, 23
        je endmulad
        add al, byte ptr [di]
        add ax, [foam]
        mov [foam], 0
        cmp ax, 10
        jl nf333
        mov [foam], 1 
        push bx
        mov bl, 10
        div bl
        pop bx
        mov al, ah
        mov ah, 0
        nf333:
        mov byte ptr [si], al
        dec di
        dec si
        jmp muladdfase1
    endmulad:   
    muladdfase2:
        mov ax, 0
        mov al, byte ptr [di]
        cmp al, 23
        je ska3
        add ax, [foam]
        mov [foam], 0
        cmp ax, 10
        jl nf22
        mov [foam], 1
        push bx
        mov bl, 10
        div bl
        pop bx
        mov al, ah
        mov ah, 0
        nf22:
        mov byte ptr [si], al
        dec di
        dec si
        jmp muladdfase2
    ska3:    
    cmp [foam], 1
    jne nf33
    mov byte ptr [si], 1    
    nf33:
    pop si
    pop di
    ret  
endp

start:	
    mov ax, data
		
    mov ds, ax

    mov ax, offset arg1
    push ax
    mov dx, offset info1
	mov ah, 09h
	int 21h
	call input
    mov [negative1], cx

    mov ax, offset arg2
    push ax
    mov dx, offset info2
	mov ah, 09h
	int 21h
	call input
    mov [negative2], cx
    call compare
    cmp ax, 1
    jne l1
    g1:
        push offset arg2
        push offset arg1
        jmp out4
    l1:
        push offset arg1
        push offset arg2
        mov ax, [negative1]
        mov bx, [negative2]
        mov [negative1], bx
        mov [negative2], ax
    out4:

    
    mov ax, [negative1]
    mov bx, [negative2]
    cmp ax, bx
    jne see2
    see1:
    call addbig
    cmp [negative1], 1
    jne nxt
    mov [negative], 1
    call skip0
    jmp nxt

    see2:
    mov [negative], 0
    cmp [negative1], 1
    jne ls
    mov [negative], 1
    ls:
    call subbig
    nxt:

    mov dx, offset dummy
	mov ah, 09h
	int 21h
    mov dx, offset info3
	mov ah, 09h
    int 21h
    mov dx, offset dummy
	mov ah, 09h
	int 21h
    call print
    mov dx, offset dummy
	mov ah, 09h
	int 21h
    
    call mulbig
    mov ax, [negative1]
    mov bx, [negative2]
    cmp ax, bx
    je nn
    mov [negative], 1
    call skip0
    nn:
    mov dx, offset dummy
	mov ah, 09h
	int 21h
    mov dx, offset info5
	mov ah, 09h
	int 21h
    mov dx, offset dummy
	mov ah, 09h
	int 21h
    call print
    mov dx, offset dummy
	mov ah, 09h
	int 21h

	mov ah, 4ch
	int 21h
	code ends
	end start