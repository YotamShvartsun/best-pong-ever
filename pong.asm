IDEAL
MODEL small
STACK 100h
DATASEG
; consts:
BsizeX dw 4
BsizeY dw 4
; ctrl locations
loc1 dw 50
loc2 dw 50

; ball location
BallX dw 50
BallY dw 120
; in order to avoid negetive numbers
BallUp db 1
BallLeft db 1

; ball speed
XSpeed dw 5
YSpeed dw 5

; ball shuld update:
nextUpdate db 0
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
proc moveBall
; moves the ball in both axias
    cmp BallUp, 0 ; if ballUp=0, add
    je ballU
    mov bx, YSpeed
    sub BallY, bx
    jmp next_b_x
    BallU:
        mov bx, YSpeed 
        add BallY, bx
    next_b_x:
    cmp BallLeft, 0
    je BallL
    mov bx, XSpeed
    sub BallX, bx
    ret
    BallL:
        mov bx, XSpeed
        add BallX, bx
    ret
endp moveBall
proc checkScore ; checks if player scored and prints a message
    mov ax, [BallX]
    cmp ax, 2
    js Scored1
    cmp ax, 315
    jg Scored2
    ret
    Scored1:
        mov ax, 1
        jmp pMsg
    Scored2:
        mov ax, 0
    pMsg:
    call shutdown
    ; print message:
    cmp ax, 0
    je msg1
    jne msg2
    msg1:
        mov dx, offset msg1
        jmp printM
    msg2:
        mov dx, offset msg2
    printM:
    mov ah, 09
    int 16h
    ; wait for key
    mov ah, 07
    int 21h
    ret
endp checkScore

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
    mov dx, [bp + 8] ; color
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
    mov ah, 1
    int 16h
    jz next_k
    mov ah, 0
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
    next_k:
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
    mov ah,08h              
    int 21h
    ret
    die:
        call shutdown
        jmp d ; exit the program
    up1:
        ; make sure ctrl can go up
        cmp loc1, 5h
        js nu1
        sub loc1, 5
        nu1:
        ret
    up2:
        ; make sure ctrl2 can go up
        cmp loc2, 5h
        js nu2
        sub loc2, 5
        nu2:
        ret
    down1:
        ; make sure ctrl1 can go down
        cmp loc1, 155d
        jg nd1
        add loc1, 5
        nd1:
        ret
    down2:
        cmp loc2, 155d
        jg nd2
        add loc2, 5
        nd2:
        ret
endp handle_input

proc draw_board
    push bp
    mov bp, sp
    push ax
    draw_b:
        push 400
        push BallY
        push BallX
        call draw_ball
        pop ax
        pop ax
        pop ax
    ; draw ctrl1
    draw_1:
        push 500
        push 2
        push loc1
        call draw_ctrl
        pop ax
        pop ax
        pop ax
    ; draw ctrl2
    draw_2:
        push 500
        push 315
        push loc2
        call draw_ctrl
        pop ax
        pop ax
        pop ax
    pop ax
    pop bp
    ret
endp draw_board
proc shouldUpadteLoad
    mov ah, 2Ch
    int 21h
    mov nextUpdate, dl
    add nextUpdate, 50
    ret
endp shouldUpadteLoad
proc updateBall
    mov ah, 2Ch
    int 21h
    cmp dl, nextUpdate
    jb endF
    call moveBall
    call shouldUpadteLoad
    endF:
    ret
endp updateBall
proc delay
    mov cx, 00
    mov dx, 0F230h
    mov al, 0
    mov ah, 86h
    int 15h
    ret
endp delay
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	call startup
    call shouldUpadteLoad

    game_l:
<<<<<<< HEAD
        ; render?
        cmp shuoldRender, 0
        jne renderAll
        je noRender
        renderAll:
            call draw_board
            mov [shuoldRender], 0
        noRender:

        ; draw ball:
        push 0Bh
        push BallY
        push BallX
        call draw_ball
        pop ax
        pop ax
        pop ax

        ; get input:
=======
        call draw_board 
>>>>>>> parent of 3cde92b... Changed the rander life-span, now it randers only when needed
        call getInput
        push ax
        call handle_input
        pop ax

        ;call moveBall
        call delay
        call refrash
    jmp game_l   
        
    
	;call shutdown
	
d:
	mov ax, 4c00h
	int 21h
END start