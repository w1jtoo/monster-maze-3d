wait_frame:
    push    dx
    mov     dx, 0x03DA

_wait:
    ;; wait while it renders all the pixels on the screen
    in      al, dx
    test    al, 0x08
    jnz     _wait

_end:
    in      al, dx
    test    al, 0x08
    jz      _end
    pop     dx
    ret

init_video:
    ;; setting VGA 320x200 mode
    mov     ax, 0x13
    int     0x10

    ;; keep pointer to video memory
    mov     ax, 0xA000
    mov     es, ax

    ret

restore_video:
    ;; back to text mode
    ;; TODO: run back to last lunched mode
    mov     ax, 0x03
    int     0x10
    ret

update_screen:
    ;; in this game we have field 80 x 50 blocks
    ;;          each block
    ;;              1) 4 x 4 pixels
    ;;              2) has texture from table
    ;; this function should redraw blocks from the list

    ;; test draw of 3 white block
    mov     ax, 0x1
    mov     bx, 0x0
    mov     cx, 0x1
    call    .draw_block

    mov     ax, 0x2
    mov     bx, 0x1
    mov     cx, 0x1
    call    .draw_block

    mov     ax, 0x1
    mov     bx, 0x3
    mov     cx, 0x1
    call    .draw_block

    ret

    ;; ax - x
    ;; bx - y
    ;; cx - id
.draw_block:
    push    ax
    push    bx
    push    cx

    ;; find pixel number by x
    ;; x_offset = 4 * x
    shl     ax, 2       ;; ax *= 4

    ;; find pixel number by y
    ;; y_offset = 4 * 320 * y
    mov     dx, bx      ;; 
    shl     bx, 10
    shl     dx, 8

    ;; pos = x_offset + y_offset
    add     ax, bx
    add     ax, dx

    mov     di, ax          ;; put offset to block to di
    cmp     cx, 0x0         ;; if id == 0 fast draw black
    je      .draw_black

    cmp     cx, 0x1         ;; if id == 1 fast draw white
    je      .draw_white

    mov     ax, 0x0f0f
    mov     cx, 0x4
    rep     stosw

.ret:
    pop     cx
    pop     bx
    pop     ax
    ret

.draw_black:

%rep 4
    mov     ax, 0x0000
    mov     cx, 0x2
    rep     stosw

    add     di, (0x140 - 4)
%endrep

    jmp     .ret

.draw_white:
%rep 4
    mov     ax, 0x0f0f
    mov     cx, 0x2
    rep     stosw

    add     di, (0x140 - 4)
%endrep

    jmp     .ret

whiteb: db 0x0f dup (64)
