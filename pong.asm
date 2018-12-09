IDEAL
MODEL small
STACK 100h
DATASEG
BsizeX dw 4
BsizeY dw 4
loc1 dw 50
loc2 dw 50

; key codes:
NO_KEY equ 0
UP_CTRL_1 equ 1
DOWN_CTRL_1 equ 2
UP_CTRL_2 equ 3
DOWN_CTRL_2 equ 4
EXIT equ 5

CODESEG
proc startup
    mov ax, 13h
    int 10h
    ret
endp startup

proc draw_pixle
; draws a pixle in the loction spacified in params
; changes ax, bx, cx and dx.
    push bp
    mov bp, sp
    
    mov al, [bp + 2] ; color
    mov bl, 0 ; page shuold be 0 for some reason
    mov cx, [bp + 4] ; X
    mov dx, [bp + 6] ; Y
    mov ah, 0ch
    int 10h

    pop bp
    retn 6
endp draw_pixle

proc draw_line
    push bp
    mov bp ,sp

    mov ax, [bp + 4] ; X
    mov bx, [bp + 6]; Y
    mov cx, [bp + 8];LEN
    mov dx, [bp + 10];color

    d_l:
        push ax
        push bx
        push cx
        push dx

        push dx
        push ax
        push bx
        call draw_pixle

        pop dx
        pop cx
        pop bx
        pop ax
        inc ax
        loop d_l
    pop bp
    ret

endp draw_line

proc draw_ball
    push bp
    mov bp, sp

    mov ax, [bp + 4] ; X
    mov bx, [bp + 6] ; Y
    mov dx, [bp + 8]
    mov cx, [BsizeX]
    b_l:
        push ax
        push bx
        push cx

        push dx ; color
        push [BsizeY] ; size
        push bx ; Y
        push ax ; X
        call draw_line
        pop ax
        pop bx
        pop ax
        pop bx
        pop cx
        pop bx
        pop ax
        inc bx
    loop b_l


    pop bp
    ret
endp draw_ball


proc draw_ctrl
    push bp
    mov bp, sp

    mov ax, [bp + 4] ; X
    mov bx, [bp + 6] ; Y
    mov dx, [bp + 8]
    mov cx, 2
    ctrl_l:
        push ax
        push bx
        push cx

        push dx ; color
        push 40 ; size
        push bx ; Y
        push ax ; X
        call draw_line
        pop ax
        pop bx
        pop ax
        pop bx
        pop cx
        pop bx
        pop ax
        inc bx
    loop ctrl_l
    pop bp
    ret
endp draw_ctrl

proc shutdown
    mov ah, 00
    mov al, 2
    int 10h
    ret
endp shutdown
proc refrash
    push ax
    push cx
    push di 
    push es
    mov ax, 0A000h
    mov es, ax
    xor di, di
    xor ax, ax
    mov cx, 32000d
    cld
    rep stosw
    pop es
    pop di
    pop cx
    pop ax
    ret
endp refrash
proc getInput ; result will be in ax
    mov ah, 00
    int 16h
    cmp ah, 1 ; esc
    je esc_pressed
    cmp ah, 48h
    je up_pressed
    cmp ah, 50h
    je down_pressed
    cmp al, 'w'
    je w_pressed
    cmp al, 's'
    je s_pressed
    ret
    esc_pressed:
        mov ax, EXIT
        ret
    up_pressed:
        mov ax, UP_CTRL_1
        ret
    down_pressed:
        mov ax, DOWN_CTRL_1
        ret
    w_pressed:
        mov ax, UP_CTRL_2
        ret
    s_pressed: 
        mov ax, DOWN_CTRL_2
        ret
endp getInput

proc handle_input
    push bp
    mov bp, sp
    mov ax, [bp + 4] ; input
    pop bp
    cmp ax, EXIT
    je die
    cmp ax, UP_CTRL_1
    je up1
    cmp ax, UP_CTRL_2
    je up2
    cmp ax, DOWN_CTRL_1
    je down1
    cmp ax, DOWN_CTRL_2
    je down2
    ret
    die:
        call shutdown
        jmp d ; exit the program
    up1:
        sub loc1, 5
        ret
    up2:
        sub loc2, 5
        ret
    down1:
        add loc1, 5
        ret
    down2:
        add loc2, 5
        ret
endp handle_input

proc draw_board
    push bp
    mov bp, sp
    push ax
    ; draw ctrl1
    push 500
    push 2
    push loc1
    call draw_ctrl
    pop ax
    pop ax
    pop ax
    ; draw ctrl2
    push 500
    push 298
    push loc2
    call draw_ctrl
    pop ax
    pop ax
    pop ax
    pop ax
    pop bp
    ret
endp draw_board

start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	call startup
    
    game_l:
        call draw_board 
        call getInput
        push ax
        call handle_input
        pop ax
        call refrash
    jmp game_l   
        
    
	;call shutdown
	
d:
	mov ax, 4c00h
	int 21h
END start