assume CS:code, DS:data
; (f + s + t)/d + 2
data segment 

    f dw 000Ah
    s dw 0014h
    t dw 001Eh
    d dw 001Eh
    msg db "Done$"
data ends


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


    mov ah, 09h
    mov dx, offset msg
    int 21h

    mov ax, 4C00h
    int 21h


code ends

end start