IDEAL
MODEL small
STACK 100h
LOCALS @@
DATASEG

isRunning db 1
; consts:
BsizeX dw 4
BsizeY dw 4
; ctrl locations
loc1 dw 50
loc2 dw 50

ctr1Up dw 0
ctr2Up dw 0

; ball location
BallX dw 50
BallY dw 120
; in order to avoid negetive numbers
BallUp db 1
BallLeft db 1

; ball speed
XSpeed dw 2
YSpeed dw 2
;scores:
Score1 db 0
Score2 db 0
; ball shuld update:
shouldIncSpeed dw 0
; messages:
Player1 db "Player 1 won!",10,13,'$'
Player2 db "Player 2 won!", 10, 13, '$'
; key codes:
NO_KEY equ 0
UP_CTRL_1 equ 1
DOWN_CTRL_1 equ 2
UP_CTRL_2 equ 3
DOWN_CTRL_2 equ 4
EXIT equ 5

CODESEG
proc startup
    ; set video mode: 
    mov ax, 13h
    int 10h
    ret
endp startup
proc printScores
; prints the points in the middle of the screen:

    ; set cursor to the middle:
    mov  dl, 170  
    mov  dh, 45   
    mov  bh, 0
    mov  ah, 02h  
    int  10h
    ; print scores, knowing it can be 0-9 (aka one char):
    mov al, [Score1]
    mov bl, 0Fh
    mov bh, 0
    mov ah, 0eh
    add al, '0'
    int 10H

    ; score1:score2
    mov al, ':'
    mov bl, 0Fh
    mov bh, 0
    mov ah, 0eh
    int 10H

    mov al, [Score2]
    mov bl, 0Fh
    mov bh, 0
    mov ah, 0eh
    add al, '0'
    int 10H
    ret
endp printScores
proc moveBall
; moves the ball in both axias
    ;if the ball should move up, move up, else move down
    mov ax, [YSpeed]
    cmp [BallUp], 0
    je @@goUp
    add [BallY], ax
    jmp @@nextX
    @@goUp:
        sub [BallY], ax
    @@nextX:
    ; if the ball should move left, move left. else move right
    mov bx, [XSpeed]
    cmp [BallLeft], 0
    jne @@moveRight
    sub [BallX], bx
    jmp @@checkNextRender
    @@moveRight:
        add [BallX], bx

    ; check if the ball should change diraction:
    @@checkNextRender:
    ; check if the ball is on upper edge
    cmp [BallY], 5h
    jg @@noHitWallUp
    mov [BallUp], 1
    jmp @@noHitWallUp
    ; check if the ball is on the lower edge
    @@noHitWallUp:
    cmp [BallY], 200d
    jl @@noHitWallDown
    mov [BallUp], 0
    @@noHitWallDown:
    ; check if the ball is on a contorller's side
    cmp [BallX], 10
    jl @@testCtrlLeft
    cmp [BallX], 310
    jg @@testCtrlRight
    ret
    ; load the location of the needed ctrl
    @@testCtrlLeft:
        mov ax, [loc1]
        jmp @@comp
    @@testCtrlRight:
        mov ax, [loc2]
    @@comp:
    ; make sure the ball hitted the ctrl
    mov bx, [BallY]
    cmp ax, bx
    jle @@fitRDwon
    ret
    @@fitRDwon:
    add ax, 45
    cmp ax, bx
    jge @@inCtrl
    ret
    ; if the hit-number is even, incerese the speed by 1 (until max-speed)
    @@inCtrl:
    cmp [shouldIncSpeed], 0
    je @@noInc
    cmp [XSpeed], 7
    je @@noInc
    inc [XSpeed]
    mov [shouldIncSpeed], 0
    jmp @@nextCheck
    @@noInc:
    mov [shouldIncSpeed], 1
    ; change the diraction of the ball: left = right, up = down
    @@nextCheck:
    mov [BallUp], 0
    cmp [BallLeft], 0
    je @@nextL
    mov [BallLeft], 0
    dec [BallX]
    ret
    @@nextL:
    inc [BallX]
    mov [BallLeft], 1
    ret
    
endp moveBall
proc checkScore ; checks if player scored and prints a message
    ;checks if the ball is on the right contorller's area (assuming it can't reach there if there is a ctrler)
    mov ax, [BallX]
    cmp ax, 2
    js Scored1
    cmp ax, 315
    jg Scored2
    ret
    ; move to bx the player who won:
    Scored1:
        ; check if someone won
        mov [XSpeed], 2
        inc [Score2]
        cmp [Score2], 10
        je @@p1Won
        jmp @@waitI
        @@p1Won:
        mov [isRunning], 0
        mov bx, 1
        jmp pMsg
    Scored2:
    mov [XSpeed], 2
        inc [Score1]
        cmp [Score1], 10
        je @@p2Won
        jmp @@waitI
        @@p2Won:
        mov [isRunning], 0
        mov bx, 0
    pMsg:
    ; reset the speed
    mov [XSpeed], 2 
    ; print message:
    cmp bx, 0
    je @@msg1
    jne @@msg2
    ; load the message:
    @@msg1:
        mov [BallLeft], 1
        mov dx, offset Player1
        jmp @@printM
    @@msg2:
        mov [BallLeft], 0
        mov dx, offset Player2
    @@printM:
    mov ah, 13h
    push es
    push bp
    mov bx, ds
    mov es, bx
    mov bp, dx
    mov cx, 15
    xor dx, dx
    mov bl, 0Fh
    int 10h
    pop bp
    pop es
    ; wait for key
    @@waitI:
    ; find out if there is a key
    mov ah, 1
    int 16h
    jz @@waitI
    ; get key:
    mov ah, 0
    int 16h
    ; check if \r\n is pressed
    cmp al,13d
    jne @@waitI
    ; reset ball location:
    mov [BallX], 120
    mov [BallY], 150
    ret
endp checkScore

proc draw_pixle
; draws a pixle in the loction spacified in params
; changes ax, bx, cx and dx.
    push bp
    mov bp, sp
    
    mov ax, [bp + 4] ; color
    mov bl, 0 ; page shuold be 0 to make sure it writes to the right location in the VGA memory
    mov cx, [bp + 6] ; X
    mov dx, [bp + 8] ; Y
    mov ah, 0ch
    int 10h

    pop bp
    retn 6
endp draw_pixle

proc draw_line
    ; draw a vertical line in ([bp + 4], [bp + 6]) in size of [bp + 8] and in color [bp + 10]
    push bp
    mov bp ,sp

    mov ax, [bp + 4] ; X
    mov bx, [bp + 6]; Y
    mov cx, [bp + 8];LEN
    mov dx, [bp + 10];color

    @@loop:
        push ax
        push bx
        push cx
        push dx
        ;draw a pixle in the loaction needed
        push ax
        push bx
        push dx
        call draw_pixle

        pop dx
        pop cx
        pop bx
        pop ax

        inc ax ; y += 1
        loop @@loop
    pop bp
    ret

endp draw_line

proc draw_ball
    ;draw the ball in ([bp + 4], [bp + 6])
    push bp
    mov bp, sp

    mov ax, [bp + 4] ; X
    mov bx, [bp + 6] ; Y
    mov dx, [bp + 8] ; color
    mov cx, [BsizeX] ; load the ball size
    @@loop:
        push ax
        push bx
        push cx

        push dx ; color
        push [BsizeY] ; size
        push bx ; Y
        push ax ; X
        call draw_line
        ; pop params:
        pop ax
        pop bx
        pop ax
        pop bx
        pop cx
        pop bx
        pop ax
        inc bx
    loop @@loop ; draw [BsizeX] lines


    pop bp
    ret
endp draw_ball


proc draw_ctrl
    ; draw a ctrl in ([bp + 4], [bp + 6])
    push bp
    mov bp, sp

    mov ax, [bp + 4] ; X
    mov bx, [bp + 6] ; Y
    mov cx, 2
    @@loop:
        push ax
        push bx
        push cx

        push 15 ; color
        push 40 ; size
        push bx ; Y
        push ax ; X
        call draw_line
        ; pop params
        pop ax
        pop bx
        pop ax
        pop bx
        pop cx
        pop bx
        pop ax
        inc bx
    loop @@loop ; draw 2 lines
    pop bp
    ret
endp draw_ctrl

proc shutdown
    ; return to text mode
    mov ah, 00
    mov al, 2
    int 10h
    ret
endp shutdown
proc refrash
    ; clear the screen by scrolling up

    mov AH, 06h
    xor AL, AL
    xor CX, CX
    mov DX, 184FH 
    mov BH, 00
    int 10H
    ret
endp refrash
proc getInput
    ; get input from the user (if there is any), and parse it to command for HandleInput
    ; any input?
    mov ah, 1
    int 16h
    jz next_k
    ; get value:
    mov ah, 0
    int 16h

    ; parse the input:
    cmp ah, 1 ; esc
    je esc_pressed
    cmp ah, 1bh ; esc
    je esc_pressed
    cmp ah, 48h ; up arrow
    je up_pressed
    cmp ah, 50h ; down arrow
    je down_pressed
    cmp al, 'w'
    je w_pressed
    cmp al, 's'
    je s_pressed
    ret
    ; load the command codes:
    esc_pressed:
        mov ax, EXIT
        ret
    up_pressed:
        mov ax, UP_CTRL_2
        ret
    down_pressed:
        mov ax, DOWN_CTRL_2
        ret
    w_pressed:
        mov ax, UP_CTRL_1
        ret
    s_pressed: 
        mov ax, DOWN_CTRL_1
        ret
    next_k:
        ret
endp getInput

proc handle_input
    ; given input in [bp + 4], do somthing
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
    ; if no input given, return
    ret
    ; set the isRunning to false
    die:
        mov [isRunning], 0
        ret
    ; ctrl movement:
    up1:
        ; make sure ctrl can go up
        cmp [loc1], 5h
        js nu1
        sub [loc1], 5
        nu1:
        ret
    up2:
        ; make sure ctrl2 can go up
        cmp [loc2], 5h
        js nu2
        sub [loc2], 5
        nu2:
        ret
    down1:
        ; make sure ctrl1 can go down
        cmp [loc1], 155d
        jg nd1
        add [loc1], 5
        nd1:
        ret
    down2:
        ; make sure ctrl2 can go down
        cmp [loc2], 155d
        jg nd2
        add [loc2], 5
        nd2:
        ret
    ret
endp handle_input

proc draw_board
    ; draw everything that should be drawed on the screen
    push bp
    mov bp, sp
    push ax
    ; print the scores:
    call printScores
    ; draw the ball on the screen
    @@draw_ball:
        ; color
        push 300
        push [BallX]
        push [BallY]
        call draw_ball
        pop ax
        pop ax
        pop ax
    ; draw ctrl1
    @@draw_1:
    ;color
        push 500
        push 2
        push [loc1]
        call draw_ctrl
        pop ax
        pop ax
        pop ax
    ; draw ctrl2
    @@draw_2:
    ;color
        push 500
        push 315
        push [loc2]
        call draw_ctrl
        pop ax
        pop ax
        pop ax
    pop ax
    pop bp
    ret
endp draw_board

proc delay
; pause the program for 0.125 seconds, to slow down the object movement to the right speed
    mov cx, 00
    mov dx, 08235h
    mov al, 0
    mov ah, 86h
    int 15h
    ret
endp delay
start:
    ; main function:
	mov ax, @data
	mov ds, ax
    ; set the video mode
	call startup

    game_l:
        call draw_board 
        call getInput
        push ax
        call handle_input
        pop ax
        call moveBall
        call checkScore
        call delay
        call refrash
        ;if the isRunning flag is up, the program will contine doing this
    cmp [isRunning], 0
    jne game_l
    ; finish the game:
	call shutdown
	mov ax, 4c00h
	int 21h
END start