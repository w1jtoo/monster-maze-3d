default_keyboard_handler:       dw  0
keyboard_segment:               dw  0

init_keyboard:
    push    es
    push    bx
    push    dx

    ;; getting the info about keyboard handler
    mov     ax, 0x3509
    int     0x21

    ;; save old handler
    mov     [default_keyboard_handler], bx
    mov     [keyboard_segment], es

    ;; bind new handler
    mov     ah, 0x25
    mov     dx, keyboard_handler
    int     0x21

    pop     dx
    pop     bx
    pop     es

    ret

restore_keyboard:
    push    dx
    push    ds

    ;; getting back to default handler
    mov     ax, 0x2509
    mov     dx, [default_keyboard_handler]
    mov     ds, [keyboard_segment]
    int     0x21

    pop     ds
    pop     dx

    ret

keyboard_handler:
    push    ax

    in      al, 0x60        ;; pressed key -> al
    cmp     al, 0x01        ;; if al == ESC
    jne      .ret
    mov     [quit], al      ;; then set quit flag

.ret:
    mov     al, 0x20        ;; else tell the keyboard
    out     0x20, al        ;;  that we handled the interuption

    pop ax
    iret
