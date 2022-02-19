assume cs: code, ds: data
; Задача - посчитать количество вхождений символа в строку
; Аргументы в agr.txt, результаты в ans.txt
include macros.asm
data segment
    databuf db 100 dup (?)
    string db 0 ,100 dup(?)
    resmsg db 20 dup(?)
    symbol db 0
    filename db 'arg.txt', 0
    filename2 db 'ans.txt', 0
    filesize dw 512
    handle dw ?
    handle2 dw ?
    res dw 0
data ends
 
stack segment Stack
    db 100h dup(?)
stack ends

code segment
start:	mov ax, data
		mov ds, ax

        open filename, handle
        create filename2, handle2
        read handle, filesize, databuf
        input databuf, string, symbol

        counting string, symbol
        mov [res], dx
        print resmsg, res


        write handle2, filesize, resmsg
    
        close handle
        close handle2
		mov ah, 4ch
		int 21h
		code ends
		end start